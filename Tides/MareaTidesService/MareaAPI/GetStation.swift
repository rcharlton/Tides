//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import Bricolage
import Foundation

extension Marea {
    struct GetStation: Endpoint {
        struct Success: Decodable {
            enum StationType: String, Decodable {
                case harmonic = "HARMONIC"
                case reference = "REFERENCE"
            }

            let status: UInt
            let id: String
            let name: String
            let latitude: Double
            let longitude: Double
            let provider: String
            let type: StationType
            let datums: Datums
            let timezone: String
        }

        typealias Failure = Error

        let successStatusCodes = [200]
        let id: String

        func urlRequest(relativeTo url: URL) -> URLRequest? {
            URL(string: "/v2/stations/\(id)", relativeTo: url)
                .map { URLRequest(url: $0) }
        }
    }
}

extension Marea {
    static var bundledStation: GetStation.Success? {
        get throws {
            try Bundle.main
                .url(forResource: "v2-stations-NOAA-9415112", withExtension: "json")
                .flatMap { try Data(contentsOf: $0) }
                .flatMap { try?JSONDecoder().decode(GetStation.Success.self, from: $0) }
        }
    }
}
