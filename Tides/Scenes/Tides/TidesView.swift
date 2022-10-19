//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import SwiftUI

struct TidesView: View {
    let viewFactory: StationListViewFactory

    @ObservedObject var viewModel: TidesViewModel

    @State private var isStationListPresented = false

    @State private var isAlertPresented = true

    var body: some View {
        NavigationView {
            contentView
                .navigationTitle("Tides")
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button {
                            isStationListPresented.toggle()
                        } label: {
                            Image(systemName: "location.circle")
                        }
                    }
                }
                .sheet(isPresented: $isStationListPresented) {
                    viewFactory.makeStationListView(
                        isPresented: $isStationListPresented,
                        station: $viewModel.stationSummary
                    )
                }
        }
    }

    @ViewBuilder var contentView: some View {
        switch viewModel.viewState {
        case let .failed(error):
            Color.clear
                .alert(error, isPresented: $isAlertPresented)

        case let .loading(stationSummary):
            ProgressView {
                Text("Loading tides for \(stationSummary.name)")
            }

        case let .ready(station, _):
            TidesPredictionView(station: station)

        case .welcome:
            Text("No station is selected")
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        Preview.viewFactory.makeTidesView()
    }
}
