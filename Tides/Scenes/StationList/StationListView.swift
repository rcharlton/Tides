//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import Bricolage
import SwiftUI

struct StationListView: View {

    @Environment(\.isPreview) var isPreview

    @Binding var isPresented: Bool

    @State private var isAlertPresented = true

    @ObservedObject var viewModel: StationListViewModel

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
            ProgressView { Text("Requesting Locations") }

        case let .ready(filteredStations, selectedStation):
            List(filteredStations) { station in
                StationListItemView(station: station)
                    .contentShape(Rectangle())
                    .listRowBackground(selectedStation == station ? Color.accentColor : .clear)
                    .onTapGesture {
                        viewModel.selectStation(station)
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
            .makeStationListView(isPresented: .ignore, selectedStation: .stub(nil))
            .previewDisplayName("empty")

        Preview.viewFactory.makeStationListView(isPresented: .ignore, selectedStation: .stub(nil)) {
            $0.viewState = .loading
        }
        .previewDisplayName("loading")

        Preview.viewFactory.makeStationListView(isPresented: .ignore, selectedStation: .stub(nil)) {
            $0.viewState = .failed(Preview.presentableError)
        }
        .previewDisplayName("failed")

        Preview.viewFactory.makeStationListView(
            isPresented: .ignore,
            selectedStation: .stub(nil)
        ) { viewModel in
            viewModel.searchText = "e"
            Task { await viewModel.loadStations() }
        }
        .previewDisplayName("ready")
    }
}
