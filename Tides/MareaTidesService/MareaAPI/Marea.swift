//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import Bricolage
import Foundation

/// https://api.marea.ooo/doc/
enum Marea {
    private static let serviceURL = URL(string: "https://api.marea.ooo")!
    private static let apiTokenHeader = ["x-marea-api-token": "a29026b6-f2ce-4143-b2de-ee566fbfd3cb"]

    static func makeClient() -> EndpointInvoking {
        configure(WebClient(serviceURL: Marea.serviceURL)) {
            $0.additionalHeaders = Marea.apiTokenHeader
        }
    }

    struct Error: Decodable {
        let error: String
        let status: Int
    }

}
