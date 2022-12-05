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
                        selectedStation: $viewModel.selectedStation
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

        case let .ready(station, tides):
            VStack {
                TidesPredictionView(station: station, tides: tides)
                Spacer()
            }
            .padding(24)

        case .welcome:
            Text("No station is selected")
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        Preview.viewFactory.makeTidesView {
            $0.viewState = .failed(Preview.presentableError)
        }
        .previewDisplayName("failure")

        Preview.viewFactory.makeTidesView {
            $0.viewState = .loading(Preview.stationList[0])
        }
        .previewDisplayName("loading")

        Preview.viewFactory.makeTidesView {
            $0.viewState = .ready(Preview.stations[0], Preview.tides)
        }
        .previewDisplayName("ready")

        Preview.viewFactory.makeTidesView {
            $0.viewState = .welcome
        }
        .previewDisplayName("welcome")
    }
}
