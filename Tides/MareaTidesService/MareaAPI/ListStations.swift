//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import Bricolage
import Foundation

extension Marea {
    struct ListStations: Endpoint {
        struct Element: Decodable {
            let id: String
            let name: String
            let latitude: Double
            let longitude: Double
        }

        typealias Success = [Element]
        typealias Failure = Error

        let successStatusCodes = [200]

        func urlRequest(relativeTo url: URL) -> URLRequest? {
            URL(string: "/v2/stations", relativeTo: url)
                .map { URLRequest(url: $0) }
        }
    }
}

extension Marea {
    static var bundledStationsList: ListStations.Success? {
        get throws {
            try Bundle.main
                .url(forResource: "v2-stations", withExtension: "json")
                .flatMap { try Data(contentsOf: $0) }
                .flatMap { try JSONDecoder().decode(ListStations.Success.self, from: $0) }
        }
    }
}
