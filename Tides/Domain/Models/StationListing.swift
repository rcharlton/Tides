//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

struct StationListing: Identifiable, Equatable {
    let id: String
    let name: String
    let location: Coordinate
    let distance: Double?
}
