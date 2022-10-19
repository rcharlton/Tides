//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

@MainActor
enum Preview {
}

extension Preview {
    static let viewFactory = ViewFactory(
        locationService: LocationService(),
        tidesService: TidesService()
    )

    class LocationService: Tides.LocationService {
        let currentLocation = Coordinate(latitude: 51.4, longitude: 0)
    }

    class TidesService: Tides.TidesService {
        func station(for id: String) async throws -> Station {
            await Preview.stations[0]
        }

        func locateStations(from location: Coordinate) async throws -> [StationSummary] {
            await Preview.stationSummaries
        }

        func tidesPrediction() async throws -> TidesPrediction {
            await Preview.tidesPrediction
        }
    }

    static var stations: [Station] {
        [
            Station(id: "1", name: "Sheerness", provider: "Provided by Preview"),
            Station(id: "2", name: "Newhaven", provider: "Provided by Preview"),
            Station(id: "3", name: "Portsmouth", provider: "Provided by Preview")
        ]
    }

    static var stationSummaries: [StationSummary] {
        stations.enumerated().map {
            StationSummary(id: $0.1.id, name: $0.1.name, distance: Double($0.0 * 10000))
        }
    }

    static var tidesPrediction: TidesPrediction {
        TidesPrediction()
    }

    static let presentableError = PresentableError(endpointError)

    static let endpointError = MareaTidesService.LocateStationsError.statusCodeIsFailure(
        500,
        error: Marea.Error(error: "Marea API is down", status: 500)
    )
}
