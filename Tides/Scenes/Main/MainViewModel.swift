//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import Combine
import SwiftUI

@MainActor
class MainViewModel: ObservableObject {
    enum ViewState {
        case failed(PresentableError)
        case loading(StationSummary)
        case ready(Station, TidesPrediction)
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
                    async let tidesPrediction = tidesPredictionProvider.tidesPrediction()
                    viewState = .ready(try await station, try await tidesPrediction)
                } catch let error as MareaTidesService.LocateStationsError {
                    viewState = .failed(PresentableError(error, cancel: cancelAction))
                } catch let error as MareaTidesService.TidesPredictionError {
                    viewState = .failed(
                        PresentableError(error, cancel: cancelAction, retry: retryAction)
                    )
                } catch {
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
