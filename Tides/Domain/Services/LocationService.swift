//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import Combine
import CoreLocation

typealias LocationService = LocationProviding

protocol LocationProviding {
    var authorizationStatus: AnyPublisher<CLAuthorizationStatus, Never> { get }

    var location: AnyPublisher<Coordinate?, Error> { get }

    func requestAuthorizationIfNotDetermined()

    func requestLocation()
}
