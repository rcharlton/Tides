//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import Bricolage
import Foundation

extension Marea {
    struct GetTides: Endpoint {
        struct Success: Decodable {
            struct Origin: Decodable {
                struct Station: Decodable {
                    let id: String
                    let name: String
                    let provider: String
                }

                let latitude: Double
                let longitude: Double
                let distance: Double
                let unit: String
                let station: Station?
            }

            struct Datums: Decodable {
                let mhhw: Double
                let mhw: Double
                let mtl: Double
                let dtl: Double
                let mlw: Double
                let mllw: Double
//                let stnd: Double
                let gt: Double
                let mn: Double
                let dhq: Double
                let dlq: Double
//                let hwi: Double
//                let lwi: Double
                let lat: Double
                let hat: Double

                enum CodingKeys: String, CodingKey {
                    case mhhw = "MHHW"
                    case mhw = "MHW"
                    case mtl = "MTL"
                    case dtl = "DTL"
                    case mlw = "MLW"
                    case mllw = "MLLW"
//                    case stnd = "STND"
                    case gt = "GT"
                    case mn = "MN"
                    case dhq = "DHQ"
                    case dlq = "DLQ"
//                    case hwi = "HWI"
//                    case lwi = "LWI"
                    case lat = "LAT"
                    case hat = "HAT"
                }
            }

            struct Extreme: Decodable {
                enum State: String, Decodable {
                    case lowTide = "LOW TIDE"
                    case highTide = "HIGH TIDE"
                }
                let timestamp: UInt
                let datetime: String
                let height: Double
                let state: State
            }

            struct Height: Decodable {
                enum State: String, Decodable {
                    case falling = "FALLING"
                    case rising = "RISING"
                }

                let timestamp: UInt
                let datetime: String
                let height: Double
                let state: State
            }

            enum Source: String, Decodable {
                case station = "STATION"
                case fes2014 = "FES2014"
                case eot20 = "EOT20"
            }

            let disclaimer: String
            let latitude: Double
            let longitude: Double
            let origin: Origin
            let datums: Datums
            let timestamp: UInt
            let datetime: String // "2021-10-05T16:26:50+00:00"
            let unit: String
            let timezone: String
            let datum: String
            let extremes: [Extreme]
            let heights: [Height]
            let source: Source
            let copyright: String
        }

        typealias Failure = Error

        enum Datum: String {
            case lat = "LAT"
            case hat = "HAT"
            case mllw = "MLLW"
            case mhhw = "MHHW"
            case mhw = "MHW"
            case mlw = "MLW"
            case mtl = "MTL"
            case dtl = "DTL"
            case gt = "GL"
            case mn = "MN"
            case dhq = "DHQ"
            case dlq = "DLQ"
            case msl = "MSL"
        }

        let successStatusCodes = [200]

        let duration: UInt?
        let timestamp: UInt?
        let radius: UInt?
        let interval: UInt?
        let latitude: Double?
        let longitude: Double?
        let model: String?
        let stationRadius: UInt?
        let stationId: String?
        let datum: Datum?

        init(
            duration: UInt? = nil,
            timestamp: UInt? = nil,
            radius: UInt? = nil,
            interval: UInt? = nil,
            latitude: Double? = nil,
            longitude: Double? = nil,
            model: String? = nil,
            stationRadius: UInt? = nil,
            stationId: String? = nil,
            datum: Datum? = nil
        ) {
            self.duration = duration
            self.timestamp = timestamp
            self.radius = radius
            self.interval = interval
            self.latitude = latitude
            self.longitude = longitude
            self.model = model
            self.stationRadius = stationRadius
            self.stationId = stationId
            self.datum = datum
        }

        private var urlComponents: URLComponents {
            configure(URLComponents()) {
                $0.path = "/v2/tides"
                $0.queryItems = [
                    duration.map { URLQueryItem(name: "duration", value: String($0)) },
                    timestamp.map { URLQueryItem(name: "timestamp", value: String($0)) },
                    radius.map { URLQueryItem(name: "radius", value: String($0)) },
                    interval.map { URLQueryItem(name: "interval", value: String($0)) },
                    latitude.map { URLQueryItem(name: "latitude", value: String($0)) },
                    longitude.map { URLQueryItem(name: "longitude", value: String($0)) },
                    model.map { URLQueryItem(name: "model", value: $0) },
                    stationRadius.map { URLQueryItem(name: "station_radius", value: String($0)) },
                    stationId.map { URLQueryItem(name: "station_id", value: $0) },
                    datum.map { URLQueryItem(name: "datum", value: $0.rawValue) }
                ].compactMap { $0 }
            }
        }

        func urlRequest(relativeTo url: URL) -> URLRequest? {
            urlComponents
                .url(relativeTo: url)
                .flatMap { URLRequest(url: $0) }
        }
    }
}

extension Marea {
    static var bundledTidesForModel: GetTides.Success? {
        get throws {
            try Bundle.main
                .url(forResource: "v2-tides-model", withExtension: "json")
                .flatMap { try Data(contentsOf: $0) }
                .flatMap { try JSONDecoder().decode(GetTides.Success.self, from: $0) }
        }
    }

    static var bundledTidesForStation: GetTides.Success? {
        get throws {
            try Bundle.main
                .url(forResource: "v2-tides-station", withExtension: "json")
                .flatMap { try Data(contentsOf: $0) }
                .flatMap { try JSONDecoder().decode(GetTides.Success.self, from: $0) }
        }
    }
}
