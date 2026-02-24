import Foundation
import CoreLocation

protocol AirQualityServing {
    func fetchAQI(for coordinate: CLLocationCoordinate2D) async throws -> Int
}

protocol LocationInfoServing {
    func fetchCityName(for coordinate: CLLocationCoordinate2D) async throws -> String?
}

protocol BooksInfoServing {
    func bookLocations(_ request: BooksInfoService.BookRequest) async throws -> BooksInfoService.BookResponse
}

protocol LocationCaching {
    func upsert(address: String, coordinate: CLLocationCoordinate2D, airQuality: Int) -> LocationCache.Entry
    func allEntries() -> [LocationCache.Entry]
}

extension AirQualityService: AirQualityServing {}
extension LocationInfoService: LocationInfoServing {}
extension BooksInfoService: BooksInfoServing {}
extension LocationCache: LocationCaching {}
