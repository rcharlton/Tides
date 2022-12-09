//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

typealias TidesService = StationLocating & StationProviding & TidesPredictionProviding

protocol StationLocating {
    func listStations() async throws -> [StationListing]
    func listStations(around location: Coordinate) async throws -> [StationListing]
}

protocol StationProviding {
    func station(for id: String) async throws -> Station
}

protocol TidesPredictionProviding {
    func tides(for stationId: String) async throws -> Tides
}
