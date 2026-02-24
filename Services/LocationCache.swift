import Foundation
import CoreLocation

final class LocationCache {
    static let shared = LocationCache()

    struct Entry {
        let key: String
        var address: String
        var coordinate: CLLocationCoordinate2D
        var airQuality: Int
        var updatedAt: Date
    }

    private var entriesByKey: [String: Entry] = [:]
    private var orderedKeys: [String] = []

    private init() {}

    func upsert(address: String, coordinate: CLLocationCoordinate2D, airQuality: Int) -> Entry {
        let key = Self.makeKey(for: coordinate)
        let entry = Entry(
            key: key,
            address: address,
            coordinate: coordinate,
            airQuality: airQuality,
            updatedAt: Date()
        )

        if entriesByKey[key] == nil {
            orderedKeys.append(key)
        }
        entriesByKey[key] = entry
        return entry
    }

    func allEntries() -> [Entry] {
        orderedKeys.compactMap { entriesByKey[$0] }
    }

    static func makeKey(for coordinate: CLLocationCoordinate2D) -> String {
        let lat = roundToThreeDecimals(coordinate.latitude)
        let lon = roundToThreeDecimals(coordinate.longitude)
        return "\(lat),\(lon)"
    }

    private static func roundToThreeDecimals(_ value: Double) -> Double {
        (value * 1000).rounded() / 1000
    }
}
