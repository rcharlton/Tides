//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import Combine

@MainActor
class StationListViewModel: ObservableObject {
    enum ViewState {
        case empty
        case failed(PresentableError)
        case loading
        case ready([StationListing])
    }

    @Published var searchText = "" {
        didSet {
            if case .ready = viewState {
                viewState = .ready(filteredStations)
            }
        }
    }

    @Published var viewState: ViewState = .empty

    private var filteredStations: [StationListing] {
        searchText.isEmpty
            ? stations
            : stations.filter {
                $0.name.range(
                    of: searchText,
                    options: [String.CompareOptions.caseInsensitive, .diacriticInsensitive]
                ) != nil
            }
    }

    private let locationProvider: LocationProviding

    private let stationLocator: StationLocating

    private var stations: [StationListing] = []

    init(locationProvider: LocationProviding, stationLocator: StationLocating) {
        self.locationProvider = locationProvider
        self.stationLocator = stationLocator
    }

    func loadStations() async {
        do {
            viewState = .loading
            let currentLocation = try await locationProvider.currentLocation
            stations = try await stationLocator.listStations(around: currentLocation)
            viewState = .ready(filteredStations)
        } catch let error as MareaTidesService.LocateStationsError {
            viewState = .failed(PresentableError(error))
        } catch {
            viewState = .failed(PresentableError(message: "An unknown failure occured."))
        }
    }
}
