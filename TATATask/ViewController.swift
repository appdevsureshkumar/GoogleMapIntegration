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
    private var lastAQILocation: CLLocation?
    private var currentAQI: Int?
    private var labelA = UILabel()
    private var labelB = UILabel()
    private var buttonV = UIButton()
    private var locationInfo: (address: String, airQuality: Int)?
    private var hasSetA = false

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
        let pinImageView = UIImageView(image: UIImage(systemName: "mappin.circle.fill"))
        pinImageView.tintColor = .systemRed
        pinImageView.contentMode = .scaleAspectFit
        pinImageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)

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
    
    private func fetchLocationAndAir(for coordinate: CLLocationCoordinate2D) {
        Task { [weak self] in
            guard let self else { return }
            do {
                let address = try await locationInfoService.fetchCityName(for: coordinate) ?? "Unknown"
                let airQuality = currentAQI ?? 0

                await MainActor.run {
                    self.locationInfo = (address: address, airQuality: airQuality)
                    self.labelA.text = address
                    self.buttonV.setTitle("Set B", for: .normal)
                    self.hasSetA = true
                }
            } catch {
                
            }
        }
    }

    private func setupBottomLabels() {
        labelA.text = "A Label"
        labelA.textColor = .white
        labelA.font = UIFont.systemFont(ofSize: 16, weight: .semibold)

        labelB.text = "B Label"
        labelB.textColor = .white
        labelB.font = UIFont.systemFont(ofSize: 16, weight: .semibold)

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
        guard hasSetA == false else { return }
        let coordinate = mapView.camera.target
        fetchLocationAndAir(for: coordinate)
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

