//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import Bricolage
import SwiftUI

struct StationListView: View {

    @Environment(\.isPreview) var isPreview

    @Binding var isPresented: Bool

    @State private var isAlertPresented = true

    @State private var selectedStation: StationListing?

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
        .onAppear {
            guard !isPreview else { return }
            viewModel.resume()
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

        case let .ready(state):
            VStack {
//                unwrap(state.message) { Text($0) }

                Text(state.message ?? "Nearest stations")
                
                List(state.stations) { station in
                    StationListItemView(station: station)
                        .contentShape(Rectangle())
                        .listRowBackground(selectedStation == station ? Color.accentColor : .clear)
                        .onTapGesture {
                            selectedStation = station
                            viewModel.selectStation(station)
                            isPresented = false
                        }
                }
                .listStyle(.plain)
                .searchable(text: $viewModel.searchText, prompt: "Search")
            }
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
        ) {
            $0.searchText = "e"
            $0.resume()
        }
        .previewDisplayName("ready")
    }
}

protocol ViewModel: ObservableObject {
    associatedtype ViewState
}
