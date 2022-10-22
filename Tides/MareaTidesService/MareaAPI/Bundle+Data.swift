//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import Foundation
import Marea

extension Bundle {
    var station: Marea.Station? {
        get throws {
            try url(forResource: "v2-stations-NOAA-9415112", withExtension: "json")
                .flatMap { try Data(contentsOf: $0) }
                .flatMap { try JSONDecoder().decode(Marea.Station.self, from: $0) }
        }
    }

    var tidesForModel: Marea.Tides? {
        get throws {
            try url(forResource: "v2-tides-model", withExtension: "json")
                .flatMap { try Data(contentsOf: $0) }
                .flatMap { try makeJSONDecoder().decode(Marea.Tides.self, from: $0) }
        }
    }

    var tidesForStation: Marea.Tides? {
        get throws {
            try url(forResource: "v2-tides-station", withExtension: "json")
                .flatMap { try Data(contentsOf: $0) }
                .flatMap { try makeJSONDecoder().decode(Marea.Tides.self, from: $0) }
        }
    }

    var stationsList: [Marea.StationListing]? {
        get throws {
            try url(forResource: "v2-stations", withExtension: "json")
                .flatMap { try Data(contentsOf: $0) }
                .flatMap { try JSONDecoder().decode([Marea.StationListing].self, from: $0) }
        }
    }
}
