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
    private let airQualityLabel = UILabel()
    private let airQualityService = AirQualityService()
    private let locationInfoService = LocationInfoService()
    private let booksInfoService = BooksInfoService()
    private var lastAQILocation: CLLocation?
    private var currentAQI: Int?
    private var labelA = UILabel()
    private var labelB = UILabel()
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
        vstack.spacing = 5
        return vstack
    }()
    
    private lazy var hStack: UIStackView = {
        let hstack = UIStackView()
        hstack.translatesAutoresizingMaskIntoConstraints = false
        hstack.axis = .horizontal
        hstack.spacing = 10
        hstack.alignment = .center
        hstack.distribution = .fill
        return hstack
    }()

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
        airQualityLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        airQualityLabel.textColor = .white
        airQualityLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        airQualityLabel.textAlignment = .center
        airQualityLabel.layer.cornerRadius = 8
        airQualityLabel.clipsToBounds = true
        airQualityLabel.text = "AQI --"

        view.addSubview(airQualityLabel)

        NSLayoutConstraint.activate([
            airQualityLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            airQualityLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            airQualityLabel.heightAnchor.constraint(equalToConstant: 32),
            airQualityLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])
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
                    self.airQualityLabel.text = "AQI \(aqi)"
                }
            } catch {
                await MainActor.run {
                    self.airQualityLabel.text = "AQI--"
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
                    onSuccess(address, airQuality, coordinate)
                }
            } catch {
                
            }
        }
    }

    private func setupBottomLabels() {
        labelA.text = "A Label"
        labelA.textColor = .white
        labelA.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        labelA.isUserInteractionEnabled = true
        let labelATap = UITapGestureRecognizer(target: self, action: #selector(handleLabelATap))
        labelA.addGestureRecognizer(labelATap)

        labelB.text = "B Label"
        labelB.textColor = .white
        labelB.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        labelB.isUserInteractionEnabled = true
        let labelBTap = UITapGestureRecognizer(target: self, action: #selector(handleLabelBTap))
        labelB.addGestureRecognizer(labelBTap)

        vstack.addArrangedSubview(labelA)
        vstack.addArrangedSubview(labelB)

        buttonV.setTitle("Set A", for: .normal)
        buttonV.setTitleColor(.white, for: .normal)
        buttonV.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.9)
        buttonV.layer.cornerRadius = 10
        buttonV.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        buttonV.addTarget(self, action: #selector(buttonVAction), for: .touchUpInside)

        hStack.addArrangedSubview(vstack)
        hStack.addArrangedSubview(buttonV)

        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true

        containerView.addSubview(hStack)
        view.addSubview(containerView)

        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            hStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            hStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            hStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),

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
                self.buttonV.setTitle("Set B", for: .normal)
                self.hasSetA = true
            }
            return
        }

        if hasSetB == false {
            fetchLocationAndAir(for: coordinate) { [weak self] address, airQuality, coordinate in
                guard let self else { return }
                self.locationInfoB = (address: address, airQuality: airQuality, coordinate: coordinate)
                self.labelB.text = address
                self.buttonV.setTitle("Book", for: .normal)
                self.hasSetB = true
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
        guard let locationInfoA else { return }
        navigateToDetails(address: ((nicknameA == nil ? locationInfoA.address : nicknameA) ?? locationInfoA.address), airQuality: locationInfoA.airQuality, slot: .a)
    }

    @objc private func handleLabelBTap() {
        guard let locationInfoB else { return }
        navigateToDetails(address: (nicknameB == nil ? locationInfoB.address : nicknameB) ?? locationInfoB.address, airQuality: locationInfoB.airQuality, slot: .b)
    }

    private func navigateToDetails(address: String, airQuality: Int, slot: LocationSlot) {
        let viewController = DetailsViewController(address: address, airQuality: airQuality)
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

    private func resetSelections() {
        locationInfoA = nil
        locationInfoB = nil
        nicknameA = nil
        nicknameB = nil
        hasSetA = false
        hasSetB = false
        labelA.text = "A Label"
        labelB.text = "B Label"
        buttonV.setTitle("Set A", for: .normal)
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
