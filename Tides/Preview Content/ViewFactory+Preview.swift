//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import Bricolage
import SwiftUI

extension ViewFactory {
    func makeStationListView(
        isPresented: Binding<Bool>,
        station: Binding<Optional<StationSummary>>,
        configure closure: (StationListViewModel) -> Void
    ) -> StationListView {
        configure(
            StationListView(
                isPresented: isPresented,
                station: station,
                viewModel: StationListViewModel(
                    locationProvider: locationService,
                    stationLocator: tidesService
                )
            )
        ) {
            closure($0.viewModel)
        }
    }
}
