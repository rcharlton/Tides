//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import Combine
import CoreLocation
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

    private class PreviewLocationService: LocationService {
        lazy var availability: AnyPublisher<LocationAvailability, Never> =
            Just(.undetermined).eraseToAnyPublisher()

        lazy var location: AnyPublisher<Coordinate?, Swift.Error> =
            Just(Coordinate(latitude: 51.4, longitude: 0))
                .setFailureType(to: Swift.Error.self)
                .eraseToAnyPublisher()

        func requestAuthorization() {
        }

        func requestLocation() {
        }
    }

    private class PreviewTidesService: TidesService {
        func station(for id: String) async throws -> Station {
            await Preview.stations[0]
        }

        func listStations() async throws -> [StationListing] {
            await Preview.stationList
        }

        func listStations(around location: Coordinate) async throws -> [StationListing] {
            await Preview.stationList
        }

        func tides(for stationId: String) async throws -> Tides {
            await Preview.tides
        }
    }

    static var stations: [Station] {
        [
            Station(id: "1", name: "Sheerness", provider: provider, location: Coordinate(latitude: 0, longitude: 0)),
            Station(id: "2", name: "Newhaven", provider: provider, location: Coordinate(latitude: 0.5, longitude: 0.5)),
            Station(id: "3", name: "Portsmouth", provider: provider, location: Coordinate(latitude: 1, longitude: 1))
        ]
    }

    static var provider: String {
        "National Oceanic and Atmospheric Administration (NOAA)"
    }

    static var stationList: [StationListing] {
        stations.enumerated().map {
            StationListing(id: $0.1.id, name: $0.1.name, location: $0.1.location, distance: Double($0.0 * 10000))
        }
    }

    static var tides: Tides {
        Tides(
            date: Date(),
            height: 1,
            tides: (1...10).map { (value: Int) in
                Tides.Tide(
                    position: (value % 2) == 0 ? .low : .high,
                    date: Date(timeIntervalSinceNow: Double(value) * 60 * 60),
                    height: Double(-1 + (2 * (value % 2))) * 1.2345
                )
            },
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
