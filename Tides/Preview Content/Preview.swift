//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import Foundation
import Marea

@MainActor
enum Preview {
}

extension Preview {
    static let viewFactory = ViewFactory(
        locationService: PreviewLocationService(),
        tidesService: PreviewTidesService()
    )

    class PreviewLocationService: LocationService {
        let currentLocation = Coordinate(latitude: 51.4, longitude: 0)
    }

    class PreviewTidesService: TidesService {
        func station(for id: String) async throws -> Station {
            await Preview.stations[0]
        }

        func locateStations(from location: Coordinate) async throws -> [StationSummary] {
            await Preview.stationSummaries
        }

        func tides(for stationId: String) async throws -> Tides {
            await Preview.tides
        }
    }

    static var stations: [Station] {
        [
            Station(id: "1", name: "Sheerness", provider: provider),
            Station(id: "2", name: "Newhaven", provider: provider),
            Station(id: "3", name: "Portsmouth", provider: provider)
        ]
    }

    static var provider: String {
        "National Oceanic and Atmospheric Administration (NOAA)"
    }

    static var stationSummaries: [StationSummary] {
        stations.enumerated().map {
            StationSummary(id: $0.1.id, name: $0.1.name, distance: Double($0.0 * 10000))
        }
    }

    static var tides: Tides {
        Tides(
            date: Date(),
            height: 1,
            tides: [
                .init(position: .high, date: Date(), height: -1.2345),
                .init(position: .low, date: Date(timeIntervalSinceNow: 8 * 60 * 60), height: 1.2345)
            ],
            lat: -2,
            hat: 2,
            unit: "m",
            disclaimer: "NOT SUITABLE FOR NAVIGATIONAL PURPOSES. Marea API does not warrant that the provided data will be free from errors or omissions. Provided data are NOT suitable for usage where someone could be harmed or suffer any damage.",
            copyright: "©2021 Marea | Generated using AVISO+ Products. FES2014 was produced by Noveltis, Legos and CLS and distributed by Aviso+, with support from Cnes (https://www.aviso.altimetry.fr/)"
        )
    }

    static let presentableError = PresentableError(endpointError)

    static let endpointError = StationsError.statusCodeIsFailure(
        500,
        error: Marea.Error(message: "Marea API is down", statusCode: 500)
    )
}
