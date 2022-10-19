//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

typealias LocationService = LocationProviding

protocol LocationProviding {
    var currentLocation: Coordinate { get async throws }
}
