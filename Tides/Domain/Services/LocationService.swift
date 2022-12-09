//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import Combine
import CoreLocation

typealias LocationService = LocationProviding

protocol LocationProviding {
    var currentLocation: Coordinate { get async throws }

    var authorization: AnyPublisher<CLAuthorizationStatus, Never> { get }

    var location: AnyPublisher<Coordinate?, Never> { get }

    func requestLocation2()
    
    func requestAuthorization() -> AnyPublisher<CLAuthorizationStatus, Never>
}
