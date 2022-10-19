//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import SwiftUI

struct TidesPredictionView: View {
    let station: Station

    var body: some View {
        VStack {
            Text("TidesPredictionView")
                .padding(10)
            Text("Station: " + station.name)
        }
    }
}

struct TidesPredictionView_Previews: PreviewProvider {
    static var previews: some View {
        TidesPredictionView(station: Preview.stations[0])
    }
}
