//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import Combine
import SwiftUI

@MainActor
class TidesViewModel: ObservableObject {
    enum ViewState {
        case failed(PresentableError)
        case loading(StationSummary)
        case ready(Station, Tides)
        case welcome
    }

    @Published var viewState: ViewState = .welcome

    @Published var stationSummary: StationSummary? {
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

        if let stationSummary = self.stationSummary {
            pendingTask = Task {
                let cancelAction = { self.viewState = .welcome }
                let retryAction = { self.update() }

                do {
                    viewState = .loading(stationSummary)
                    async let station = stationProvider.station(for: stationSummary.id)
                    async let tides = tidesPredictionProvider.tides(for: stationSummary.id)
                    viewState = .ready(try await station, try await tides)
                } catch let error as MareaTidesService.LocateStationsError {
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
