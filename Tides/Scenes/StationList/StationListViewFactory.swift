//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import SwiftUI

@MainActor
protocol StationListViewFactory {
    func makeStationListView(
        isPresented: Binding<Bool>,
        station: Binding<Optional<StationSummary>>
    ) -> AnyView
}

extension ViewFactory: StationListViewFactory {
    func makeStationListView(
        isPresented: Binding<Bool>,
        station: Binding<Optional<StationSummary>>
    ) -> AnyView {
        AnyView(
            StationListView(
                isPresented: isPresented,
                station: station,
                viewModel: StationListViewModel(
                    locationProvider: locationService,
                    stationLocator: tidesService
                )
            )
        )
    }
}
