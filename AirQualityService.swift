import Foundation
import CoreLocation

final class AirQualityService {
    private let session: URLSession
    private let token: String

    init(session: URLSession = .shared, token: String = "c502f7ef476a3957d755b7adc855edf7f9c0100e") {
        self.session = session
        self.token = token
    }

    func fetchAQI(for coordinate: CLLocationCoordinate2D) async throws -> Int {
        //feed/geo::lat;:lng/?token=:token

        let urlString = "https://api.waqi.info/feed/geo:\(coordinate.latitude);\(coordinate.longitude)/?token=\(token)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await session.data(from: url)
        let response = try JSONDecoder().decode(AQICNResponse.self, from: data)
        guard response.status == "ok", let aqi = response.data?.aqi else {
            throw AQIError.invalidResponse
        }

        return aqi
    }
}

extension AirQualityService {
    struct AQICNResponse: Codable {
        let status: String
        let data: AQIData?
    }

    struct AQIData: Codable {
        let aqi: Int?
    }

    enum AQIError: Error {
        case invalidResponse
    }
}

final class LocationInfoService {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchCityName(for coordinate: CLLocationCoordinate2D) async throws -> String? {
        let urlString = "https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=\(coordinate.latitude)&longitude=\(coordinate.longitude)&localityLanguage=en"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await session.data(from: url)
        let response = try JSONDecoder().decode(BigDataCloudResponse.self, from: data)
        return response.city
    }
}

extension LocationInfoService {
    struct BigDataCloudResponse: Codable {
        let city: String?
    }
}
