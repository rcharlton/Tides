//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import SwiftUI

@MainActor
protocol MainViewFactory {
    func makeMainView() -> AnyView
}

extension ViewFactory: MainViewFactory {
    func makeMainView() -> AnyView {
        AnyView(
            MainView(
                viewFactory: self,
                viewModel: MainViewModel(
                    stationProvider: tidesService,
                    tidesPredictionProvider: tidesService
                )
            )
        )
    }
}
