//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import SwiftUI

@MainActor
protocol StationListViewFactory {
    func makeStationListView(
        isPresented: Binding<Bool>,
        selectedStation: Binding<Optional<StationListing>>
    ) -> AnyView
}

extension ViewFactory: StationListViewFactory {
    func makeStationListView(
        isPresented: Binding<Bool>,
        selectedStation: Binding<Optional<StationListing>>
    ) -> AnyView {
        AnyView(
            StationListView(
                isPresented: isPresented,
                viewModel: StationListViewModel(
                    selectedStation: selectedStation,
                    locationProvider: locationService,
                    stationLocator: tidesService
                )
            )
        )
    }
}
