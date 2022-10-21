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

                /// Origin distance from requested coordinates.
                let distance: Double
                let unit: String
                let station: Station?
            }

            struct Extreme: Decodable {
                enum State: String, Decodable {
                    case lowTide = "LOW TIDE"
                    case highTide = "HIGH TIDE"
                }
                let timestamp: UInt
                let datetime: Date
                let height: Double
                let state: State
            }

            struct Height: Decodable {
                enum State: String, Decodable {
                    case falling = "FALLING"
                    case rising = "RISING"
                }
                let timestamp: UInt
                let datetime: Date
                let height: Double
                let state: State
            }

            enum Source: String, Decodable {
                case station = "STATION"
                case fes2014 = "FES2014"
                case eot20 = "EOT20"
            }

            let disclaimer: String

            /// Response status.
            let status: UInt

            /// Requested coordinate.
            let latitude: Double
            let longitude: Double

            /// Nearest location for requested coordinates with tide predictions available.
            let origin: Origin

            /// Tidal datums.
            let datums: Datums

            /// Requested timestamp.
            let timestamp: UInt

            /// Timestamp as in timezone specified in timezone field.
            let datetime: Date

            /// Unit for the prediction heights.
            let unit: String

            /// Datetime timezone.
            let timezone: String

            /// Reference Tidal datum.
            let datum: String

            /// List of low and high tides.
            let extremes: [Extreme]

            /// List of water levels with requested interval.
            let heights: [Height]

            /// Prediction source: either model (FES2014, EOT20) OR "STATION".
            let source: Source

            /// Prediction source copyright.
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

        var decoder: Decoding { makeJSONDecoder() }

        // Query parameters:
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

        /// Initializer
        /// - Parameters:
        ///   - duration:  Duration is the number of minutes for which the forecast should be calculated.
        ///                Default is 1440 (one day). Please note that one response can contain max
        ///                10080 predicted heights, so duration can't be bigger than 10080.
        ///   - timestamp: Timestamp (number of seconds since the unix epoch) of the prediction beginning.
        //                 Defaults to current timestamp.
        ///   - radius:    When no prediction is found in requested coordinates, API tries to return
        ///                the nearest prediction. You can limit the radius by setting radius parameter
        ///                to any positive integer.
        ///   - interval:  Interval means number of minutes between the returned measurements.
        ///                Please note that one response can contain max 10080 predicted heights,
        ///                so interval can't be bigger than 10080.
        ///   - latitude:  Latitude in range from -90 to 90.
        ///   - longitude: Longitude in range from -180 to 180.
        ///   - model:     Preferred model for Tide prediction: FES2014 (default) or EOT20
        ///   - datum:     Reference vertical datum (https://en.wikipedia.org/wiki/Vertical_datum).
        ///                When specified all returned heights will be referred to selected datum
        ///                (list of low and high tides, list of water levels, list of datums).
        ///                Allowed: LAT, HAT, MLLW, MHHW, MHW, MLW, MTL, DTL, GT, MN, DHQ, DLQ, MSL
        ///                Default: MSL
        init(
            duration: UInt? = nil,
            timestamp: UInt? = nil,
            radius: UInt? = nil,
            interval: UInt? = nil,
            latitude: Double? = nil,
            longitude: Double? = nil,
            model: String? = nil,
            datum: Datum? = nil
        ) {
            self.duration = duration
            self.timestamp = timestamp
            self.radius = radius
            self.interval = interval
            self.latitude = latitude
            self.longitude = longitude
            self.model = model
            self.stationRadius = nil
            self.stationId = nil
            self.datum = datum
        }

        /// Initializer
        /// - Parameters:
        ///   - duration:  Duration is the number of minutes for which the forecast should be calculated.
        ///                Default is 1440 (one day). Please note that one response can contain max
        ///                10080 predicted heights, so duration can't be bigger than 10080.
        ///   - timestamp: Timestamp (number of seconds since the unix epoch) of the prediction beginning.
        //                 Defaults to current timestamp.
        ///   - interval:  Interval means number of minutes between the returned measurements.
        ///                Please note that one response can contain max 10080 predicted heights,
        ///                so interval can't be bigger than 10080.
        ///   - model:     Preferred model for Tide prediction: FES2014 (default) or EOT20
        ///   - stationRadius: When station is found in specified station_radius, return the prediction
        ///                    from the station (if not found, nearest model prediction is used).
        ///   - stationId: Prediction for particular Station by ID (can't be used together with
        ///                latitude and longitude parameters)
        ///   - datum:     Reference vertical datum (https://en.wikipedia.org/wiki/Vertical_datum).
        ///                When specified all returned heights will be referred to selected datum
        ///                (list of low and high tides, list of water levels, list of datums).
        ///                Allowed: LAT, HAT, MLLW, MHHW, MHW, MLW, MTL, DTL, GT, MN, DHQ, DLQ, MSL
        ///                Default: MSL
        init(
            duration: UInt? = nil,
            timestamp: UInt? = nil,
            interval: UInt? = nil,
            model: String? = nil,
            stationRadius: UInt? = nil,
            stationId: String? = nil,
            datum: Datum? = nil
        ) {
            self.duration = duration
            self.timestamp = timestamp
            self.radius = nil
            self.interval = interval
            self.latitude = nil
            self.longitude = nil
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
                .flatMap { try makeJSONDecoder().decode(GetTides.Success.self, from: $0) }
        }
    }

    static var bundledTidesForStation: GetTides.Success? {
        get throws {
            try Bundle.main
                .url(forResource: "v2-tides-station", withExtension: "json")
                .flatMap { try Data(contentsOf: $0) }
                .flatMap { try makeJSONDecoder().decode(GetTides.Success.self, from: $0) }
        }
    }
}
