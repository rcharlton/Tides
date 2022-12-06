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
    private var requestLocationContinuation: CheckedContinuation<CLLocation, Error>?

    override init() {
        super.init()
        locationManager.delegate = self
    }

    private func requestLocation() async throws -> CLLocation {
        try await withCheckedThrowingContinuation {
            self.requestLocationContinuation = $0

            if locationManager.authorizationStatus == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            } else {
                locationManager.requestLocation()
            }
        }
    }
}

extension CoreLocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print(#function, manager.authorizationStatus)

        if requestLocationContinuation != nil {
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function, error)
        requestLocationContinuation?.resume(throwing: error)
        requestLocationContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            requestLocationContinuation?.resume(returning: location)
            requestLocationContinuation = nil
        }
    }
}
