//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import SwiftUI

struct TouchGestureModifier: ViewModifier {
    let beganAction: () -> Void
    
    let endedAction: () -> Void

    @GestureState private var isDown = false

    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($isDown) { _, state, _ in
                        if !state {
                            beganAction()
                            state = true
                        }
                    }
                    .onEnded { _ in
                        endedAction()
                    }
            )
    }
}

extension View {

    func onTouchGesture(
        began: @escaping () -> Void,
        ended: @escaping () -> Void
    ) -> some View {
        modifier(TouchGestureModifier(beganAction: began, endedAction: ended))
    }

}

