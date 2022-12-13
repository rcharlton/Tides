//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import Combine

typealias LocationService = LocationProviding

protocol LocationProviding {
    var availability: AnyPublisher<LocationAvailability, Never> { get }

    var location: AnyPublisher<Coordinate?, Error> { get }

    func requestAuthorization()
    
    func requestLocation()
}
