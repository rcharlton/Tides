//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import CoreLocation

extension CLAuthorizationStatus: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .notDetermined:
            return "notDetermined"
        case .restricted:
            return "restricted"
        case .denied:
            return "denied"
        case .authorizedAlways:
            return "authorizedAlways"
        case .authorizedWhenInUse:
            return "authorizedWhenInUse"
        @unknown default:
            return "default"
        }
    }
}
