//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import Bricolage
import SwiftUI

struct TidesPredictionView: View {
    let station: Station

    let tides: Tides

    private let dateFormatter = configure(DateFormatter()) {
        $0.dateFormat = "E d MMM, HH:mm"
    }

    private let numberFormatter = configure(NumberFormatter()) {
        $0.numberStyle = .decimal
        $0.maximumFractionDigits = 2
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(station.name, systemImage: "mappin.and.ellipse")
                .font(.largeTitle)

            Text(station.provider)
                .font(.subheadline)


            ForEach(tides.tides, id: \.date) { tide in
                HStack {
                    Text(dateFormatter.string(from: tide.date))
                    Text(tide.position.description)

                    let height = numberFormatter.string(from: NSNumber(value: tide.height)) ?? "unknown"
                    Text("\(height) units?")
                }
                .font(.body)
            }
        }
        .foregroundColor(.black)
    }
}

struct TidesPredictionView_Previews: PreviewProvider {
    static var previews: some View {
        TidesPredictionView(station: Preview.stations[0], tides: Preview.tides)
    }
}

extension Tides.Tide.Position: CustomStringConvertible {
    var description: String {
        switch self {
        case .low:
            return "Low"
        case .high:
            return "High"
        }
    }
}
