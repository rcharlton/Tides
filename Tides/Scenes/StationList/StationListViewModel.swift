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

        struct AuthorizationPrompt {
            let message: String
            let action: (() -> Void)?
        }

        struct ReadyState {
            let authorizationPrompt: AuthorizationPrompt?
            let stations: [StationListing]

            init(
                authorizationPrompt: AuthorizationPrompt? = nil,
                stations: [StationListing] = []
            ) {
                self.authorizationPrompt = authorizationPrompt
                self.stations = stations
            }
        }
    }

    @Published var searchText = ""

    @Published var viewState: ViewState = .empty

    @Binding private var selectedStation: StationListing?

    private var authorizationPrompt: some Publisher<ViewState.AuthorizationPrompt?, Never> {
        let locationProvider = self.locationProvider

        let requestAuthorization = { [locationProvider] in
            locationProvider.requestAuthorization()
        }

        let actionMessage = "Turn on Location Services to see your nearest tide stations."

        return locationProvider
            .availability
            .map { (availability) -> ViewState.AuthorizationPrompt? in
                switch availability {
                case .disabled:
                    return .init("Location Services are disabled in Settings.\n\(actionMessage)")
                case .undetermined:
                    return .init(
                        message: "Authorise Location Services to see your nearest tide stations.",
                        action: requestAuthorization
                    )
                case .restricted:
                    return .init(
                        "Location Services are restricted, possibly due to parental controls being in place."
                    )
                case .denied:
                    return .init(
                        "Location Services are unavailable due to permission being denied or Airplane mode being active.\n\(actionMessage)"
                    )
                case .authorized:
                    // Nasty side-effect!
                    locationProvider.requestLocation()
                    return .init("Your nearest tide stations:")
                case .unknown:
                    return .init("Unable to determine the status of Location Services.")
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
        let authorizationPrompt = authorizationPrompt
            .setFailureType(to: Error.self)

        let loading = Just(ViewState.loading)

        let readyOrFailed = Publishers
            .CombineLatest(authorizationPrompt, filteredStations)
            .map { ViewState.ready(.init(authorizationPrompt: $0.0, stations: $0.1)) }
            .catch {
                let presentableError: PresentableError
                if let error = $0 as? MareaTidesService.ListStationsError {
                    presentableError = PresentableError(error)
                } else {
                    presentableError = PresentableError(message: "An unknown failure occured.")
                }
                return Just(ViewState.failed(presentableError))
            }

        return Publishers.Merge(loading, readyOrFailed)
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
            .print()
            .assign(to: &self.$viewState)
    }

    func selectStation(_ station: StationListing?) {
        selectedStation = station
    }
}

// MARK: -

extension StationListViewModel.ViewState.AuthorizationPrompt {
    init(_ message: String) {
        self.init(message: message, action: nil)
    }
}
