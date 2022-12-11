//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import Combine
import CoreLocation

class CoreLocationService: NSObject, LocationService {
    private(set) lazy var authorizationStatus: AnyPublisher<CLAuthorizationStatus, Never> =
        $authorizationStatusSubject.eraseToAnyPublisher()

    private(set) lazy var location: AnyPublisher<Coordinate?, Error> = locationSubject.eraseToAnyPublisher()

    @Published private var authorizationStatusSubject = CLAuthorizationStatus.notDetermined

    private let locationSubject = CurrentValueSubject<Coordinate?, Error>(nil)

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestAuthorizationIfNotDetermined() {
        if authorizationStatusSubject == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func requestLocation() {
        locationManager.requestLocation()
    }
}

extension CoreLocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print(#function, manager.authorizationStatus)
        authorizationStatusSubject = manager.authorizationStatus

        if !manager.authorizationStatus.isAuthorized {
            locationSubject.value = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function, error)
        locationSubject.send(completion: .failure(error))
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(#function, locations)
        locations.forEach { locationSubject.value = Coordinate(with: $0.coordinate) }
    }
}

private extension CLAuthorizationStatus {
    var isAuthorized: Bool {
        [.authorizedAlways, .authorizedWhenInUse].contains(self)
    }
}
