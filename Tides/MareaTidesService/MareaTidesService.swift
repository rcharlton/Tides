//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import Bricolage
import Foundation

class MareaTidesService: TidesService {

    typealias LocateStationsError = EndpointError<Marea.ListStations>
    typealias StationError = EndpointError<Marea.GetStation>
    typealias TidesPredictionError = EndpointError<Marea.GetTides>

    private let mareaClient: EndpointInvoking

    init(mareaClient: EndpointInvoking = Marea.makeClient()) {
        self.mareaClient = mareaClient
    }

    func locateStations(from coordinate: Coordinate) async throws -> [StationSummary] {
        let stationsList: Marea.ListStations.Success
        if let bundledStationsList = try Marea.bundledStationsList {
            stationsList = bundledStationsList
        } else {
            stationsList = try await mareaClient.invoke(endpoint: Marea.ListStations())
        }

        return stationsList
            .map { StationSummary(from: $0, coordinate: coordinate) }
            .sorted { $0.distance < $1.distance }
    }

    func station(for id: String) async throws -> Station {
        let station: Marea.GetStation.Success
        if let bundledStation = try Marea.bundledStation {
            station = bundledStation
        } else {
            station = try await mareaClient.invoke(endpoint: Marea.GetStation(id: id))
        }

        return Station(from: station)
    }

    func tidesPrediction(for stationId: String) async throws -> TidesPrediction {
        let tides: Marea.GetTides.Success
        if let bundledTides = try Marea.bundledTidesForStation {
            tides = bundledTides
        } else {
            tides = try await mareaClient.invoke(endpoint: Marea.GetTides(stationId: stationId))
        }

        return TidesPrediction(from: tides)
    }
}

// MARK: -

private extension StationSummary {
    init(from success: Marea.ListStations.Success.Element, coordinate: Coordinate) {
        let distance = success.distance(from: coordinate)
        self.init(id: success.id, name: success.name, distance: distance)
    }
}

private extension Station {
    init(from success: Marea.GetStation.Success) {
        self.init(id: success.id, name: success.name, provider: success.provider)
    }
}

private extension TidesPrediction {
    init(from success: Marea.GetTides.Success) {
        self.init()
    }
}

// MARK: -

import CoreLocation

private extension Marea.ListStations.Element {
    func distance(from coordinate: Coordinate) -> Double {
        CLLocation(latitude: latitude, longitude: longitude).distance(
            from: CLLocation(coordinate: coordinate)
        )
    }
}

extension Coordinate {
    init(coordinate: CLLocationCoordinate2D ) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

extension CLLocation {
    convenience init(coordinate: Coordinate) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}
