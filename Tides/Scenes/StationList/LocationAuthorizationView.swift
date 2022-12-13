//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import SwiftUI

struct LocationAuthorizationView: View {
    let message: String
    let action: (() -> Void)?

    var body: some View {
        VStack(spacing: 10) {
            Text(message)
            Button(action: action ?? { }) {
                Label("Request Authorization", systemImage: "gearshape.fill")
            }
            .when(action == nil) { $0.hidden() }
        }
    }
}

struct LocationAuthorizationView_Previews: PreviewProvider {
    static var previews: some View {
        LocationAuthorizationView(
            message: "Location Services are unavailable, due to permission being denied, Location Services being disabled in Settings, or Airplane mode being active.",
            action: { }
        )
    }
}
