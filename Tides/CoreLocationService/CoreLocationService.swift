//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import Combine
import CoreLocation

class CoreLocationService: NSObject, LocationService {
    var currentLocation: Coordinate {
        get async throws {
            let location = try await requestLocation()
            return Coordinate(with: location.coordinate)
        }
    }

    lazy var authorization: AnyPublisher<CLAuthorizationStatus, Never> =
        $authorizationSubject.eraseToAnyPublisher()

    lazy var location: AnyPublisher<Coordinate?, Never> =
        $locationSubject.eraseToAnyPublisher()

    @Published private var authorizationSubject = CLAuthorizationStatus.notDetermined

    @Published private var locationSubject: Coordinate? = nil

    private let locationManager = CLLocationManager()

    private var requestLocationContinuation: CheckedContinuation<CLLocation, Error>?

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestAuthorization() -> AnyPublisher<CLAuthorizationStatus, Never> {
        if authorizationSubject == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        return $authorizationSubject.eraseToAnyPublisher()
    }

    func requestLocation2() {
        locationManager.requestLocation()
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

        authorizationSubject = manager.authorizationStatus

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
        print(#function, locations)
        locations.forEach { locationSubject = Coordinate(with: $0.coordinate) }

        if let location = locations.last {
            requestLocationContinuation?.resume(returning: location)
            requestLocationContinuation = nil
        }
    }
}
