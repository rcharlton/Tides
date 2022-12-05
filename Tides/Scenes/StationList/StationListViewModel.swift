//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import Combine
import SwiftUI

@MainActor
class StationListViewModel: ObservableObject {
    enum ViewState {
        case empty
        case failed(PresentableError)
        case loading
        case ready([StationListing], StationListing?)
    }

    @Published var searchText = "" {
        didSet {
            if case .ready = viewState {
                viewState = .ready(filteredStations, selectedStation)
            }
        }
    }

    @Published var viewState: ViewState = .empty

    @Binding private var selectedStation: StationListing?

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

    init(
        selectedStation: Binding<StationListing?>,
        locationProvider: LocationProviding,
        stationLocator: StationLocating
    ) {
        self._selectedStation = selectedStation
        self.locationProvider = locationProvider
        self.stationLocator = stationLocator
    }

    func loadStations() async {
        do {
            viewState = .loading
            let currentLocation = try await locationProvider.currentLocation
            stations = try await stationLocator.listStations(around: currentLocation)
            viewState = .ready(filteredStations, selectedStation)
        } catch let error as MareaTidesService.LocateStationsError {
            viewState = .failed(PresentableError(error))
        } catch {
            viewState = .failed(PresentableError(message: "An unknown failure occured."))
        }
    }

    func selectStation(_ station: StationListing?) {
        selectedStation = station
    }
}
