//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import SwiftUI

@MainActor
protocol TidesViewFactory {
    func makeTidesView() -> AnyView
}

extension ViewFactory: TidesViewFactory {
    func makeTidesView() -> AnyView {
        AnyView(
            TidesView(
                viewFactory: self,
                viewModel: TidesViewModel(
                    stationProvider: tidesService,
                    tidesPredictionProvider: tidesService
                )
            )
        )
    }
}
