//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import SwiftUI

@MainActor
class ViewFactory {
    let locationService: LocationService
    let tidesService: TidesService

    init(
        locationService: LocationService = CoreLocationService(),
        tidesService: TidesService = MareaTidesService()
    ) {
        self.locationService = locationService
        self.tidesService = tidesService
    }
}
