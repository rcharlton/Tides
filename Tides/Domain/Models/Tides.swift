//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import Foundation

struct Tides {
    struct Tide {
        enum Position {
            case low, high
        }
        let position: Position
        let date: Date
        let height: Double
    }

    /// Date of this record.
    let date: Date

    /// Height at date (interpolated).
    let height: Double

    let tides: [Tide]

    /// Lowest Astronomical Tide.
    let lat: Double

    /// Highest Astronomical Tide.
    let hat: Double

    /// Unit for the prediction heights.
    let unit: String

    /// Prediction source disclaimer.
    let disclaimer: String

    /// Prediction source copyright.
    let copyright: String
}
