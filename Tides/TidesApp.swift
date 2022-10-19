//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import SwiftUI

@main
struct TidesApp: App {
    var body: some Scene {
        WindowGroup {
            ViewFactory().makeTidesView()
        }
    }
}
