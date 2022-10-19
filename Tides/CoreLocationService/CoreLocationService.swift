//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import CoreLocation

class CoreLocationService: NSObject, LocationService {
    var currentLocation: Coordinate {
        get async throws {
            let location = try await requestLocation()
            return Coordinate(coordinate: location.coordinate)
        }
    }

    private let locationManager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation, Error>?
    private var shouldRequestLocation = false

    override init() {
        super.init()
        locationManager.delegate = self
    }

    private func requestLocation() async throws -> CLLocation {
        try await withCheckedThrowingContinuation {
            self.continuation = $0

            if locationManager.authorizationStatus == .notDetermined {
                shouldRequestLocation = true
                locationManager.requestWhenInUseAuthorization()
            } else {
                locationManager.requestLocation()
            }
        }
    }
}

extension CoreLocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if shouldRequestLocation {
            shouldRequestLocation = false
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard manager.authorizationStatus != .notDetermined else { return }
        continuation?.resume(throwing: error)
        continuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            continuation?.resume(returning: location)
            continuation = nil
        }
    }
}
