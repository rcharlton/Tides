//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import Combine
import CoreLocation
import UIKit

class CoreLocationService: NSObject, LocationService {
    private(set) lazy var availability: AnyPublisher<LocationAvailability, Never> =
        $availabilitySubject.eraseToAnyPublisher()

    private(set) lazy var location: AnyPublisher<Coordinate?, Error> =
        locationSubject.eraseToAnyPublisher()

    @Published private var availabilitySubject = LocationAvailability.unknown

    private let locationSubject = CurrentValueSubject<Coordinate?, Error>(nil)

    private let locationManager = CLLocationManager()

    private var cancellables: [AnyCancellable] = []

    override init() {
        super.init()
        locationManager.delegate = self

        NotificationCenter.Publisher(
            center: .default,
            name: UIApplication.willEnterForegroundNotification
        )
        .sink { [weak self] _ in
            self?.updateAuthorizationStatus()
        }
        .store(in: &cancellables)
    }

    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func requestLocation() {
        locationManager.requestLocation()
    }
}

extension CoreLocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        updateAuthorizationStatus()
    }

    private func updateAuthorizationStatus() {
        let status = locationManager.authorizationStatus

        DispatchQueue.global().async {
            let isEnabled = CLLocationManager.locationServicesEnabled()

            DispatchQueue.main.async {
                let availability = LocationAvailability(
                    isLocationServicesEnabled: isEnabled,
                    authorizationStatus: status
                )
                if availability != self.availabilitySubject {
                    self.availabilitySubject = availability
                    if !availability.isAvailable {
                        self.locationSubject.value = nil
                    }
                }
            }
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

// MARK: -

private extension CLAuthorizationStatus {
    var isAuthorized: Bool {
        [.authorizedAlways, .authorizedWhenInUse].contains(self)
    }
}

// MARK: -

private extension LocationAvailability {
    init(isLocationServicesEnabled: Bool, authorizationStatus: CLAuthorizationStatus) {
        switch (isLocationServicesEnabled, authorizationStatus) {
        case (false, _):
            self = .disabled
        case (true, .authorizedAlways),
            (true, .authorizedWhenInUse):
            self = .authorized
        case (true, .denied):
            self = .denied
        case (true, .restricted):
            self = .restricted
        case (true, .notDetermined):
            self = .undetermined
        case (true, _):
            self = .unknown
        }
   }

    var isAvailable: Bool {
        self == .authorized
    }
}
