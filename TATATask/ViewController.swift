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
    private var lastAQILocation: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupMap()
        setupLocationMarker()
        setupAirQualityLabel()

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
                    self.airQualityLabel.text = "AQI \(aqi)"
                }
            } catch {
                await MainActor.run {
                    self.airQualityLabel.text = "AQI --"
                }
            }
        }
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
        locationMarker.position = position.target
        updateAirQuality(for: position.target)
    }
}

