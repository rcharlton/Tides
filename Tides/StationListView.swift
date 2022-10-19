//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import Bricolage
import SwiftUI

struct StationListView: View {

    @Environment(\.isPreview) var isPreview

    @Binding var isPresented: Bool

    @Binding var station: StationSummary?

    @ObservedObject var viewModel: StationListViewModel

    @State private var isAlertPresented = true

    var body: some View {
        NavigationView {
            contentView
//            .unwrap(viewModel.viewState.error) { view, error in
//                view.alert(error, isPresented: $isAlertPresented)
//            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        isPresented = false
                    }
                }
            }
            .navigationTitle("Locations")
        }
        .task {
            guard !isPreview else { return }
            await viewModel.loadStations()
        }
    }

    @ViewBuilder var contentView: some View {
        switch viewModel.viewState {
        case .empty:
            Text("🌵")

        case let .failed(error):
            Color.clear
                .alert(error, isPresented: $isAlertPresented)

        case .loading:
            ProgressView { Text("Loading") }

        case let .ready(filteredStations):
            List(filteredStations) { station in
                StationListItemView(station: station)
                    .contentShape(Rectangle())
                    .listRowBackground(self.station == station ? Color.accentColor : .clear)
                    .onTapGesture {
                        self.station = station
                        isPresented = false
                    }
            }
            .listStyle(.plain)
            .searchable(text: $viewModel.searchText, prompt: "Search")
        }
    }
}

//extension StationListViewModel.ViewState {
//    var error: PresentableError? {
//        if case let .failed(error) = self {
//            return error
//        } else {
//            return nil
//        }
//    }
//}

// MARK: -

struct StationListView_Previews: PreviewProvider {
    static var previews: some View {
        Preview.viewFactory
            .makeStationListView(isPresented: .ignore, station: .stub(nil))
            .previewDisplayName("empty")

        Preview.viewFactory.makeStationListView(isPresented: .ignore, station: .stub(nil)) {
            $0.viewState = .loading
        }
        .previewDisplayName("loading")

        Preview.viewFactory.makeStationListView(isPresented: .ignore, station: .stub(nil)) {
            $0.viewState = .failed(Preview.presentableError)
        }
        .previewDisplayName("failed")


        Preview.viewFactory.makeStationListView(isPresented: .ignore, station: .stub(nil)) { viewModel in
            viewModel.searchText = "e"
            Task { await viewModel.loadStations() }
        }
        .previewDisplayName("ready")
    }
}
