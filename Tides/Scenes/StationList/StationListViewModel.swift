//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import Combine
import CoreLocation
import SwiftUI

@MainActor
class StationListViewModel: ObservableObject {

    enum ViewState {
        case empty
        case failed(PresentableError)
        case loading
        case ready(ReadyState)

        struct ReadyState {
            let message: String?
            let stations: [StationListing]

            init(message: String? = nil, stations: [StationListing] = []) {
                self.message = message
                self.stations = stations
            }
        }
    }

    @Published var searchText = ""

    @Published var viewState: ViewState = .empty

    @Binding private var selectedStation: StationListing?

    // TODO: Replace this with a CTA ViewState with a message and action (title, closure).
    private var statusMessage: some Publisher<String?, Never> {
        let locationProvider = self.locationProvider

        return locationProvider
            .authorizationStatus
            .map { (status: CLAuthorizationStatus) -> String? in
                switch status {
                case .notDetermined:
                    return "Use Location Services to find your nearest station"
                case .restricted:
                    return "Location Services are unavailable, possibly due to active restrictions such as parental controls being in place."
                case .denied:
                    return "Location Services are unavailable, due to permission being denied, Location Services being disabled in Settings, or Airplane mode being active."
                case .authorizedAlways, .authorizedWhenInUse:
                    locationProvider.requestLocation()
                    return nil
                @unknown default:
                    return nil
                }
            }
    }

    private var sortedStations: some Publisher<[StationListing], Error> {
        let location = locationProvider
            .location
            .removeDuplicates()

        let stations = Future<[StationListing], Error> { [stationLocator] in
            try await stationLocator.listStations()
        }

        return Publishers
            .CombineLatest(location, stations)
            .map { (location, stations) -> [StationListing] in
                location.map { location in
                    stations
                        .map {
                            StationListing(
                                id: $0.id,
                                name: $0.name,
                                location: $0.location,
                                distance:  $0.location.distance(from: location)
                            )
                        }
                        .sorted { ($0.distance ?? .infinity) < ($1.distance ?? .infinity) }
                }
                ?? stations.sorted { $0.name < $1.name }
            }
    }

    private var filteredStations: some Publisher<[StationListing], Error> {
        let searchText = $searchText
            .setFailureType(to: Error.self)

        return Publishers
            .CombineLatest(searchText, sortedStations)
            .map { (searchText, stations) in
                searchText.isEmpty
                    ? stations
                    : stations.filter {
                        $0.name.range(
                            of: searchText,
                            options: [String.CompareOptions.caseInsensitive, .diacriticInsensitive]
                        ) != nil
                    }
            }
    }

    private var internalViewState: some Publisher<ViewState, Never> {
        let statusMessage = statusMessage
            .setFailureType(to: Error.self)

        return Publishers
            .CombineLatest(statusMessage, filteredStations)
            .map { ViewState.ready(.init(message: $0.0, stations: $0.1)) }
            .catch {
                let presentableError: PresentableError
                if let error = $0 as? MareaTidesService.ListStationsError {
                    presentableError = PresentableError(error)
                } else {
                    presentableError = PresentableError(message: "An unknown failure occured.")
                }
                return Just(ViewState.failed(presentableError))
            }
    }

    private let locationProvider: LocationProviding

    private let stationLocator: StationLocating

    init(
        selectedStation: Binding<StationListing?>,
        locationProvider: LocationProviding,
        stationLocator: StationLocating
    ) {
        self._selectedStation = selectedStation
        self.locationProvider = locationProvider
        self.stationLocator = stationLocator
    }

    deinit {
        print(type(of: self), #function)
    }

    func resume() {
        internalViewState
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$viewState)

        locationProvider.requestAuthorizationIfNotDetermined()
    }

    func selectStation(_ station: StationListing?) {
        selectedStation = station
    }
}
