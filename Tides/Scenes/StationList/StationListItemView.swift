//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import Bricolage
import SwiftUI

struct StationListItemView: View {
    private static let numberFormatter = configure(NumberFormatter()) {
        $0.maximumFractionDigits = 1
    }

    let station: StationListing

    var body: some View {
        HStack {
            Text(station.name)
            Spacer()
            Text(Self.distanceString(station.distance))
        }
        .frame(height: 50)
    }

    private static func distanceString(_ distance: Double) -> String {
        let kilometers = distance / 1000
        let string = Self.numberFormatter.string(from: kilometers as NSNumber).map { $0 + " km away" }
        return string ?? "Unknown distance"
    }
}

struct StationListItemView_Previews: PreviewProvider {
    static var previews: some View {
        List(Preview.stationList) {
            StationListItemView(station: $0)
        }
        .listStyle(.plain)
    }
}
