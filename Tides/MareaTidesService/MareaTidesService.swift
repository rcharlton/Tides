//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import Bricolage
import Foundation
import Marea

class MareaTidesService: TidesService {

    typealias ListStationsError = Marea.StationsError
    typealias StationError = Marea.StationError
    typealias TidesError = Marea.TidesError

    private enum Constant {
        static let apiToken = "a29026b6-f2ce-4143-b2de-ee566fbfd3cb"
    }

    private let marea: MareaClient

    private let shouldReturnBundledData: Bool

    init(
        marea: MareaClient = makeMareaClient(token: Constant.apiToken),
        shouldReturnBundledData: Bool = false
    ) {
        self.marea = marea
        self.shouldReturnBundledData = shouldReturnBundledData
    }

    func listStations() async throws -> [StationListing] {
        let stationsList: Marea.ListStations.Success
        if shouldReturnBundledData, let bundledStationsList = try Bundle.main.stationsList {
            stationsList = bundledStationsList
        } else {
            stationsList = try await marea.stations
        }

        return stationsList
            .map {
                StationListing(
                    id: $0.id,
                    name: $0.name,
                    location: Coordinate(latitude: $0.latitude, longitude: $0.longitude),
                    distance: nil
                )
            }
            .sorted { $0.name < $1.name }
    }

    func listStations(around coordinate: Coordinate) async throws -> [StationListing] {
        let stationsList: Marea.ListStations.Success
        if shouldReturnBundledData, let bundledStationsList = try Bundle.main.stationsList {
            stationsList = bundledStationsList
        } else {
            stationsList = try await marea.stations
        }

        return stationsList
            .map { StationListing(from: $0, coordinate: coordinate) }
            .sorted { ($0.distance ?? .infinity) < ($1.distance ?? .infinity) }
    }

    func station(for id: String) async throws -> Station {
        let station: Marea.GetStation.Success
        if shouldReturnBundledData, let bundledStation = try Bundle.main.station {
            station = bundledStation
        } else {
            station = try await marea.station(for: id)
        }

        return Station(from: station)
    }

    func tides(for stationId: String) async throws -> Tides {
        let tides: Marea.GetTides.Success
        if shouldReturnBundledData, let bundledTides = try Bundle.main.tidesForStation {
            tides = bundledTides
        } else {
            let startOfTodayDate = Calendar.current.startOfDay(for: Date())
            let startOfDate = Calendar.current.date(
                byAdding: .day,
                value: -2,
                to: startOfTodayDate
            ) ?? startOfTodayDate
            let startTime = UInt(startOfDate.timeIntervalSince1970)
            let sevenDays: UInt = 10080

            tides = try await marea.tides(
                duration: sevenDays,
                timestamp: startTime,
                stationId: stationId
            )
        }

        return Tides(from: tides)
    }
}

// MARK: -

private extension StationListing {
    init(from stationListing: Marea.StationListing, coordinate: Coordinate) {
        let distance = stationListing.distance(from: coordinate)
        self.init(
            id: stationListing.id,
            name: stationListing.name,
            location: Coordinate(latitude: stationListing.latitude, longitude: stationListing.longitude),
            distance: distance
        )
    }
}

private extension Station {
    init(from station: Marea.Station) {
        self.init(
            id: station.id,
            name: station.name,
            provider: station.provider,
            location: Coordinate(latitude: station.latitude, longitude: station.longitude)
        )
    }
}

private extension Tides {
    init(from tides: Marea.Tides) {
        let currentDate = Date()
        let timestamp = UInt(currentDate.timeIntervalSince1970)

        let height = zip(tides.heights, tides.heights[1...])
            .first(where: { $0.timestamp <= timestamp && timestamp <= $1.timestamp })
            .map { heights in
                let m = (heights.1.height - heights.0.height) / Double(heights.1.timestamp - heights.0.timestamp)
                let x = Double(timestamp - heights.0.timestamp)
                let b = heights.0.height
                return (m * x) + b
            }

        self.init(
            date: currentDate,
            height: height ?? 0,
            tides: tides.extremes.map { Tide(from: $0) },
            lat: tides.datums.lat,
            hat: tides.datums.hat,
            unit: tides.unit,
            disclaimer: tides.disclaimer,
            copyright: tides.copyright
        )
    }
}

private extension Tides.Tide {
    init(from extreme: Marea.Tides.Extreme) {
        self.init(
            position: Position(from: extreme.state),
            date: Date(timeIntervalSince1970: TimeInterval(extreme.timestamp)),
            height: extreme.height
        )
    }
}

private extension Tides.Tide.Position {
    init(from state: Marea.Tides.Extreme.State) {
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

private extension Marea.StationListing {
    func distance(from coordinate: Coordinate) -> Double {
        CLLocation(latitude: latitude, longitude: longitude).distance(
            from: CLLocation(with: coordinate)
        )
    }
}

extension Coordinate {
    init(with coordinate: CLLocationCoordinate2D ) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }

    func distance(from coordinate: Coordinate) -> Double {
        let result = CLLocation(with: self).distance(from: CLLocation(with: coordinate))
        return result
    }
}

extension CLLocation {
    convenience init(with coordinate: Coordinate) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}
