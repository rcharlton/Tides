//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import SwiftUI

extension View {
    @ViewBuilder func when<Content: View>(
        _ condition: () -> Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
}
