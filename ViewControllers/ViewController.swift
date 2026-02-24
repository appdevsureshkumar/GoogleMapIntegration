//
//  ViewController.swift
//  TATATask
//
//  Created by sureshkumar on 18/02/26.
//

import UIKit
import GoogleMaps
import CoreLocation

class ViewController: UIViewController {

    private let mapView = GMSMapView()
    private let locationMarker = GMSMarker()
    private let locationManager = CLLocationManager()
    private let airQualityLabel = PaddedLabel()
    private let airQualityService = AirQualityService()
    private let locationInfoService = LocationInfoService()
    private let booksInfoService = BooksInfoService()
    private var lastAQILocation: CLLocation?
    private var currentAQI: Int?
    private var labelA = PaddedLabel()
    private var labelB = PaddedLabel()
    private var buttonV = UIButton()
    private var locationInfoA: (address: String, airQuality: Int, coordinate: CLLocationCoordinate2D)?
    private var locationInfoB: (address: String, airQuality: Int, coordinate: CLLocationCoordinate2D)?
    private var nicknameA: String?
    private var nicknameB: String?
    private var hasSetA = false
    private var hasSetB = false
    private var shouldResetOnAppear = false
    private enum LocationSlot {
        case a
        case b
    }

    private lazy var vstack: UIStackView = {
        let vstack = UIStackView()
        vstack.translatesAutoresizingMaskIntoConstraints = false
        vstack.axis = .vertical
        vstack.spacing = 10
        vstack.distribution = .fillEqually
        return vstack
    }()
    
    private lazy var hStack: UIStackView = {
        let hstack = UIStackView()
        hstack.translatesAutoresizingMaskIntoConstraints = false
        hstack.axis = .horizontal
        hstack.spacing = 12
        hstack.alignment = .fill
        hstack.distribution = .fill
        return hstack
    }()

    private final class PaddedLabel: UILabel {
        var textInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)

        override func drawText(in rect: CGRect) {
            super.drawText(in: rect.inset(by: textInsets))
        }

        override var intrinsicContentSize: CGSize {
            let size = super.intrinsicContentSize
            return CGSize(width: size.width + textInsets.left + textInsets.right,
                          height: size.height + textInsets.top + textInsets.bottom)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupMap()
        setupLocationMarker()
        setupAirQualityLabel()
        setupBottomLabels()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if shouldResetOnAppear {
            resetSelections()
            shouldResetOnAppear = false
        }
    }

    private func setupMap() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self

        // Default position (will change later when we add current location)
        let camera = GMSCameraPosition(latitude: 13.0827, longitude: 80.2707, zoom: 19) // Chennai
        mapView.camera = camera

        view.addSubview(mapView)

        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupLocationMarker() {
        let pinImageView = UIImageView(image: UIImage(named: "icon-pin"))
        pinImageView.tintColor = .systemRed
        pinImageView.contentMode = .scaleAspectFit
        pinImageView.frame = CGRect(x: 0, y: 0, width: 32, height: 54)

        locationMarker.iconView = pinImageView
        locationMarker.groundAnchor = CGPoint(x: 0.5, y: 1.0) // Bottom center
        locationMarker.map = mapView
    }

    private func setupAirQualityLabel() {
        airQualityLabel.translatesAutoresizingMaskIntoConstraints = false
        airQualityLabel.textColor = .secondaryLabel
        airQualityLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        airQualityLabel.textAlignment = .right
        airQualityLabel.text = "aqi --"

        NSLayoutConstraint.activate([
            airQualityLabel.heightAnchor.constraint(equalToConstant: 24),
            airQualityLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 70)
        ])

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: airQualityLabel)
    }

    private func updateAirQuality(for coordinate: CLLocationCoordinate2D) {
        let currentLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        if let lastAQILocation, currentLocation.distance(from: lastAQILocation) < 100 {
            return
        }
        lastAQILocation = currentLocation

        Task { [weak self] in
            guard let self else { return }
            do {
                let aqi = try await airQualityService.fetchAQI(for: coordinate)
                await MainActor.run {
                    self.currentAQI = aqi
                    self.airQualityLabel.text = "aqi \(aqi)"
                }
            } catch {
                await MainActor.run {
                    self.airQualityLabel.text = "aqi --"
                }
            }
        }
    }
    
    private func fetchLocationAndAir(
        for coordinate: CLLocationCoordinate2D,
        onSuccess: @escaping (_ address: String, _ airQuality: Int, _ coordinate: CLLocationCoordinate2D) -> Void
    ) {
        Task { [weak self] in
            guard let self else { return }
            do {
                let address = try await locationInfoService.fetchCityName(for: coordinate) ?? "Unknown"
                let airQuality = currentAQI ?? 0

                await MainActor.run {
                    _ = LocationCache.shared.upsert(
                        address: address,
                        coordinate: coordinate,
                        airQuality: airQuality
                    )
                    onSuccess(address, airQuality, coordinate)
                }
            } catch {
                
            }
        }
    }

    private func setupBottomLabels() {
        labelA.text = "A"
        labelA.textColor = .black
        labelA.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        labelA.backgroundColor = .systemGray5
        labelA.layer.cornerRadius = 10
        labelA.clipsToBounds = true
        labelA.textAlignment = .left
        labelA.isUserInteractionEnabled = true
        let labelATap = UITapGestureRecognizer(target: self, action: #selector(handleLabelATap))
        labelA.addGestureRecognizer(labelATap)

        labelB.text = "B"
        labelB.textColor = .black
        labelB.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        labelB.backgroundColor = .systemGray5
        labelB.layer.cornerRadius = 10
        labelB.clipsToBounds = true
        labelB.textAlignment = .left
        labelB.isUserInteractionEnabled = true
        let labelBTap = UITapGestureRecognizer(target: self, action: #selector(handleLabelBTap))
        labelB.addGestureRecognizer(labelBTap)

        vstack.addArrangedSubview(labelA)
        vstack.addArrangedSubview(labelB)

        buttonV.setTitle("V", for: .normal)
        buttonV.setTitleColor(.black, for: .normal)
        buttonV.backgroundColor = .systemYellow
        buttonV.layer.cornerRadius = 12
        buttonV.addTarget(self, action: #selector(buttonVAction), for: .touchUpInside)

        hStack.addArrangedSubview(vstack)
        hStack.addArrangedSubview(buttonV)

        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.clipsToBounds = true

        containerView.addSubview(hStack)
        view.addSubview(containerView)

        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            hStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            hStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            hStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),

            labelA.heightAnchor.constraint(equalToConstant: 44),
            labelB.heightAnchor.constraint(equalToConstant: 44),
            buttonV.widthAnchor.constraint(equalToConstant: 64),
            buttonV.heightAnchor.constraint(equalTo: vstack.heightAnchor),

            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
    }
    
    @objc private func buttonVAction() {
        let coordinate = mapView.camera.target
        if hasSetA == false {
            fetchLocationAndAir(for: coordinate) { [weak self] address, airQuality, coordinate in
                guard let self else { return }
                self.locationInfoA = (address: address, airQuality: airQuality, coordinate: coordinate)
                self.labelA.text = address
                self.hasSetA = true
                self.updateButtonTitleForState()
            }
            return
        }

        if hasSetB == false {
            fetchLocationAndAir(for: coordinate) { [weak self] address, airQuality, coordinate in
                guard let self else { return }
                self.locationInfoB = (address: address, airQuality: airQuality, coordinate: coordinate)
                self.labelB.text = address
                self.hasSetB = true
                self.updateButtonTitleForState()
            }
            return
        }

        guard let locationInfoA, let locationInfoB else { return }
        let request = BooksInfoService.BookRequest(
            locationA: .init(
                latitude: locationInfoA.coordinate.latitude,
                longitude: locationInfoA.coordinate.longitude,
                airQuality: locationInfoA.airQuality,
                name: nicknameA ?? locationInfoA.address
            ),
            locationB: .init(
                latitude: locationInfoB.coordinate.latitude,
                longitude: locationInfoB.coordinate.longitude,
                airQuality: locationInfoB.airQuality,
                name: nicknameB ?? locationInfoB.address
            )
        )

        buttonV.isEnabled = false
        Task { [weak self] in
            guard let self else { return }
            do {
                let response = try await booksInfoService.bookLocations(request)
                await MainActor.run {
                    self.buttonV.isEnabled = true
                    self.showBookDetails(response)
                }
            } catch {
                await MainActor.run {
                    self.buttonV.isEnabled = true
                }
            }
        }
    }

    @objc private func handleLabelATap() {
        guard let locationInfoA else {
            showCachedLocations(for: .a)
            return
        }
        navigateToDetails(address: ((nicknameA == nil ? locationInfoA.address : nicknameA) ?? locationInfoA.address), airQuality: locationInfoA.airQuality, slot: .a)
    }

    @objc private func handleLabelBTap() {
        guard let locationInfoB else {
            showCachedLocations(for: .b)
            return
        }
        navigateToDetails(address: (nicknameB == nil ? locationInfoB.address : nicknameB) ?? locationInfoB.address, airQuality: locationInfoB.airQuality, slot: .b)
    }

    private func navigateToDetails(address: String, airQuality: Int, slot: LocationSlot) {
        let viewController = DetailsViewController(address: address, airQuality: airQuality, slotTitle: slot == .a ? "A" : "B")
        viewController.completionNickName = { [weak self] nickName in
            guard let self else { return }
            switch slot {
            case .a:
                self.nicknameA = nickName
                self.labelA.text = nickName ?? address
            case .b:
                self.nicknameB = nickName
                self.labelB.text = nickName ?? address
            }
        }
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func showBookDetails(_ response: BooksInfoService.BookResponse) {
        let viewController = BookDetailsViewController(response: response)
        viewController.onBackToRoot = { [weak self] in
            self?.shouldResetOnAppear = true
        }
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func showCachedLocations(for slot: LocationSlot) {
        let entries = LocationCache.shared.allEntries()
        guard entries.isEmpty == false else {
            let alert = UIAlertController(
                title: "No cached locations",
                message: "Move the map and set a location first.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let viewController = CachedLocationsViewController(entries: entries)
        viewController.onSelectEntry = { [weak self] entry in
            self?.applyCachedEntry(entry, to: slot)
        }
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func applyCachedEntry(_ entry: LocationCache.Entry, to slot: LocationSlot) {
        switch slot {
        case .a:
            locationInfoA = (address: entry.address, airQuality: entry.airQuality, coordinate: entry.coordinate)
            labelA.text = entry.address
            hasSetA = true
        case .b:
            locationInfoB = (address: entry.address, airQuality: entry.airQuality, coordinate: entry.coordinate)
            labelB.text = entry.address
            hasSetB = true
        }
        updateButtonTitleForState()
    }

    private func updateButtonTitleForState() {
        if hasSetA == false && hasSetB == false {
            buttonV.setTitle("V", for: .normal)
            return
        }
        if hasSetA == false && hasSetB == true {
            buttonV.setTitle("Set A", for: .normal)
            return
        }
        if hasSetA == true && hasSetB == false {
            buttonV.setTitle("Set B", for: .normal)
            return
        }
        buttonV.setTitle("Book", for: .normal)
    }

    private func refreshAirQualityForSelectedLocations() {
        if let infoA = locationInfoA {
            Task { [weak self] in
                guard let self else { return }
                do {
                    let aqi = try await airQualityService.fetchAQI(for: infoA.coordinate)
                    await MainActor.run {
                        self.locationInfoA?.airQuality = aqi
                        _ = LocationCache.shared.upsert(
                            address: infoA.address,
                            coordinate: infoA.coordinate,
                            airQuality: aqi
                        )
                    }
                } catch {
                    
                }
            }
        }

        if let infoB = locationInfoB {
            Task { [weak self] in
                guard let self else { return }
                do {
                    let aqi = try await airQualityService.fetchAQI(for: infoB.coordinate)
                    await MainActor.run {
                        self.locationInfoB?.airQuality = aqi
                        _ = LocationCache.shared.upsert(
                            address: infoB.address,
                            coordinate: infoB.coordinate,
                            airQuality: aqi
                        )
                    }
                } catch {
                    
                }
            }
        }
    }

    func applyHistorySelection(from item: UserUsageHistory.BookItemResponse) {
        shouldResetOnAppear = false
        locationInfoA = (
            address: item.locationA.name,
            airQuality: item.locationA.aqi,
            coordinate: CLLocationCoordinate2D(
                latitude: item.locationA.latitude,
                longitude: item.locationA.longitude
            )
        )
        locationInfoB = (
            address: item.locationB.name,
            airQuality: item.locationB.aqi,
            coordinate: CLLocationCoordinate2D(
                latitude: item.locationB.latitude,
                longitude: item.locationB.longitude
            )
        )

        labelA.text = item.locationA.name
        labelB.text = item.locationB.name
        hasSetA = true
        hasSetB = true
        updateButtonTitleForState()
        _ = LocationCache.shared.upsert(
            address: item.locationA.name,
            coordinate: locationInfoA?.coordinate ?? CLLocationCoordinate2D(),
            airQuality: item.locationA.aqi
        )
        _ = LocationCache.shared.upsert(
            address: item.locationB.name,
            coordinate: locationInfoB?.coordinate ?? CLLocationCoordinate2D(),
            airQuality: item.locationB.aqi
        )
        refreshAirQualityForSelectedLocations()
    }

    private func resetSelections() {
        locationInfoA = nil
        locationInfoB = nil
        nicknameA = nil
        nicknameB = nil
        hasSetA = false
        hasSetB = false
        labelA.text = "A Label"
        labelB.text = "B Label"
        updateButtonTitleForState()
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }
        locationMarker.position = lastLocation.coordinate
        mapView.animate(to: GMSCameraPosition(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude, zoom: 19))
        updateAirQuality(for: lastLocation.coordinate)
    }
}

extension ViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        locationMarker.position = position.target // Camera centered coordinate
        updateAirQuality(for: position.target)
    }
}
