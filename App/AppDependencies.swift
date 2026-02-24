import Foundation

struct AppDependencies {
    let airQualityService: AirQualityServing
    let locationInfoService: LocationInfoServing
    let booksInfoService: BooksInfoServing
    let locationCache: LocationCaching

    init(
        airQualityService: AirQualityServing = AirQualityService(),
        locationInfoService: LocationInfoServing = LocationInfoService(),
        booksInfoService: BooksInfoServing = BooksInfoService(),
        locationCache: LocationCaching = LocationCache.shared
    ) {
        self.airQualityService = airQualityService
        self.locationInfoService = locationInfoService
        self.booksInfoService = booksInfoService
        self.locationCache = locationCache
    }
}
