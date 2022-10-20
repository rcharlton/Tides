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

    let tides: [Tide]
    let disclaimer: String
    let copyright: String
}
