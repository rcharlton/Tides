//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import Combine
import SwiftUI

@MainActor
class TidesViewModel: ObservableObject {
    enum ViewState {
        case failed(PresentableError)
        case loading(StationListing)
        case ready(Station, Tides)
        case welcome
    }

    @Published var viewState: ViewState = .welcome

    @Published var selectedStation: StationListing? {
        didSet {
            update()
        }
    }

    private var pendingTask: Cancellable?

    private let stationProvider: StationProviding

    private let tidesPredictionProvider: TidesPredictionProviding

    init(stationProvider: StationProviding, tidesPredictionProvider: TidesPredictionProviding) {
        self.stationProvider = stationProvider
        self.tidesPredictionProvider = tidesPredictionProvider
    }

    private func update() {
        pendingTask?.cancel()
        pendingTask = nil

        if let selectedStation = self.selectedStation {
            pendingTask = Task {
                let cancelAction = { self.viewState = .welcome }
                let retryAction = { self.update() }

                do {
                    viewState = .loading(selectedStation)
                    async let station = stationProvider.station(for: selectedStation.id)
                    async let tides = tidesPredictionProvider.tides(for: selectedStation.id)
                    viewState = .ready(try await station, try await tides)
                } catch let error as MareaTidesService.ListStationsError {
                    print(error)
                    viewState = .failed(PresentableError(error, cancel: cancelAction, retry: retryAction))
                } catch let error as MareaTidesService.TidesError {
                    print(error)
                    viewState = .failed(PresentableError(error, cancel: cancelAction, retry: retryAction))
                } catch {
                    print(error)
                    viewState = .failed(
                        PresentableError(
                            title: "Unknown Failure",
                            message: "\(error.localizedDescription). \(error)",
                            actions: [.cancel(action: cancelAction)]
                        )
                    )
                }

                pendingTask = nil
            }
        } else {
            viewState = .welcome
        }
    }
}

extension Task: Cancellable {
}
