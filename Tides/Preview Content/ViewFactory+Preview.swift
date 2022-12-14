//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import Bricolage
import SwiftUI

extension ViewFactory {
    func makeTidesView(configure closure: (TidesViewModel) -> Void) -> TidesView {
        configure(
            TidesView(
                viewFactory: self,
                viewModel: TidesViewModel(
                    stationProvider: tidesService,
                    tidesPredictionProvider: tidesService
                )
            )
        ) {
            closure($0.viewModel)
        }
    }

    func makeStationListView(
        isPresented: Binding<Bool>,
        selectedStation: Binding<Optional<StationListing>>,
        configure closure: (StationListViewModel) -> Void
    ) -> StationListView {
        configure(
            StationListView(
                isPresented: isPresented,
                viewModel: StationListViewModel(
                    selectedStation: selectedStation,
                    locationProvider: locationService,
                    stationLocator: tidesService
                )
            )
        ) {
            closure($0.viewModel)
        }
    }
}
