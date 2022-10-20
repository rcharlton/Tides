//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import Bricolage
import Foundation

class MareaTidesService: TidesService {

    typealias LocateStationsError = EndpointError<Marea.ListStations>
    typealias StationError = EndpointError<Marea.GetStation>
    typealias TidesError = EndpointError<Marea.GetTides>

    private let mareaClient: EndpointInvoking

    private let shouldReturnBundledData: Bool

    init(mareaClient: EndpointInvoking = Marea.makeClient(), shouldReturnBundledData: Bool = false) {
        self.mareaClient = mareaClient
        self.shouldReturnBundledData = shouldReturnBundledData
    }

    func locateStations(from coordinate: Coordinate) async throws -> [StationSummary] {
        let stationsList: Marea.ListStations.Success
        if shouldReturnBundledData, let bundledStationsList = try Marea.bundledStationsList {
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
        if shouldReturnBundledData, let bundledStation = try Marea.bundledStation {
            station = bundledStation
        } else {
            station = try await mareaClient.invoke(endpoint: Marea.GetStation(id: id))
        }

        return Station(from: station)
    }

    func tides(for stationId: String) async throws -> Tides {
        let tides: Marea.GetTides.Success
        if shouldReturnBundledData, let bundledTides = try Marea.bundledTidesForStation {
            tides = bundledTides
        } else {
            tides = try await mareaClient.invoke(endpoint: Marea.GetTides(stationId: stationId))
        }

        return Tides(from: tides)
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

private extension Tides {
    init(from success: Marea.GetTides.Success) {
        self.init(
            tides: success.extremes.map { Tide(from: $0) },
            disclaimer: success.disclaimer,
            copyright: success.copyright
        )
    }
}

private extension Tides.Tide {
    init(from extreme: Marea.GetTides.Success.Extreme) {
        self.init(
            position: Position(from: extreme.state),
            date: Date(timeIntervalSince1970: TimeInterval(extreme.timestamp)),
            height: extreme.height
        )
    }
}

private extension Tides.Tide.Position {
    init(from state: Marea.GetTides.Success.Extreme.State) {
        switch state {
        case .lowTide:
            self = .low
        case .highTide:
            self = .high
        }
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
