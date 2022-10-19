//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import SwiftUI

extension View {
    @ViewBuilder func unwrap<Content: View, Wrapped>(
        _ optional: Optional<Wrapped>,
        transform: (Self, Wrapped) -> Content
    ) -> some View {
        if let wrapped = optional {
            transform(self, wrapped)
        } else {
            self
        }
    }
}
