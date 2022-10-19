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

            struct Datums: Decodable {
                let mhhw: Double
                let mhw: Double
                let mtl: Double
                let dtl: Double
                let mlw: Double
                let mllw: Double
                let stnd: Double
                let gt: Double
                let mn: Double
                let dhq: Double
                let dlq: Double
                let hwi: Double
                let lwi: Double
                let lat: Double
                let hat: Double

                enum CodingKeys: String, CodingKey {
                    case mhhw = "MHHW"
                    case mhw = "MHW"
                    case mtl = "MTL"
                    case dtl = "DTL"
                    case mlw = "MLW"
                    case mllw = "MLLW"
                    case stnd = "STND"
                    case gt = "GT"
                    case mn = "MN"
                    case dhq = "DHQ"
                    case dlq = "DLQ"
                    case hwi = "HWI"
                    case lwi = "LWI"
                    case lat = "LAT"
                    case hat = "HAT"
                }
            }

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
