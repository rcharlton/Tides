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

    deinit {
        print(type(of: self), #function)
    }

    func resume() {
        typealias StationsError = MareaTidesService.ListStationsError

        let locationProvider = self.locationProvider

        // TODO: Can we move this inside LocationProvider?
        let location = locationProvider
            .requestAuthorization()
            .flatMap { status in
                switch status {
                case .authorizedAlways, .authorizedWhenInUse:
                    locationProvider.requestLocation2()
                    return locationProvider.location
                default:
                    return Just(Optional<Coordinate>(nil)).eraseToAnyPublisher()
                }
            }
            .removeDuplicates()
            .setFailureType(to: Error.self)

        let stations = Future<[StationListing], Error> { [stationLocator] in
            try await stationLocator.listStations()
        }

        // TODO: How to represent location state in the ViewState so UI is meaningful?

        let sortedStations = Publishers
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

        let searchText = $searchText.setFailureType(to: Error.self)

        let filteredStations = Publishers
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

        let viewState = filteredStations
            .map { [weak self] in
                ViewState.ready($0, self?.selectedStation)
            }
            .catch {
                let presentableError: PresentableError
                if let error = $0 as? MareaTidesService.ListStationsError {
                    presentableError = PresentableError(error)
                } else {
                    presentableError = PresentableError(message: "An unknown failure occured.")
                }
                return Just(ViewState.failed(presentableError))
            }
            .receive(on: DispatchQueue.main)

        viewState.assign(to: &self.$viewState)
    }

    func selectStation(_ station: StationListing?) {
        selectedStation = station

        if case let .ready(stations, _) = viewState {
            viewState = .ready(stations, selectedStation)
        }
    }
}
