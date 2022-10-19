//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

typealias TidesService = StationLocating & StationProviding & TidesPredictionProviding

protocol StationLocating {
    func locateStations(from location: Coordinate) async throws -> [StationSummary]
}

protocol StationProviding {
    func station(for id: String) async throws -> Station
}

protocol TidesPredictionProviding {
    func tides(for stationId: String) async throws -> Tides
}
