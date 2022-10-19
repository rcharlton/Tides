//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import SwiftUI

#if DEBUG
public extension EnvironmentValues {
    /// Useage: @Environment(\.isPreview) var isPreview
    var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
#endif
