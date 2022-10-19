//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import Bricolage

extension PresentableError {
    private static var retryableStatusCodes = [500, 503]

    init<E: Endpoint>(
        _ error: EndpointError<E>,
        cancel: @escaping () -> Void = {},
        retry: @escaping () -> Void = {}
    ) {
        switch error {
        case let .dataTaskFailedWithError(error):
            self.init(
                message: "Data task failed with error \(error.localizedDescription)",
                actions: [.cancel(action: cancel), .retry(action: retry)]
            )

        case let .endpointIsMisconfigured(endpoint):
            self.init(
                message: "Endpoint \(endpoint) is misconfigured",
                actions: [.cancel(action: cancel) ]
            )

        case let .failedToDecodeType(typename, error):
            self.init(
                message: "Failed to decode \(typename) due to \(error.localizedDescription)",
                actions: [.cancel(action: cancel) ]
            )

        case let .statusCodeIsFailure(statusCode, error):
            let errorMessage = (error as? CustomStringConvertible)?.description ?? ""
            let retryAction = Self.retryableStatusCodes.contains(statusCode) ? Action.retry(action: retry) : nil
            let actions = [Action.cancel(action: cancel), retryAction].compactMap { $0 }

            self.init(
                message: "Status code \(statusCode) indicates failure. \(errorMessage)",
                actions: actions
            )

        case .urlResponseIsUnexpected:
            self.init(
                message: "URL response is unexpected",
                actions: [.cancel(action: cancel) ]
            )
        }
    }
}

extension Marea.Error: CustomStringConvertible {
    public var description: String { error }
}
