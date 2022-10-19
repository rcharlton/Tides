//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import SwiftUI

struct PresentableError: Error {
    struct Action: Equatable {
        enum Role {
            case cancel, destructive, retry, task
        }

        let title: String
        let role: Role
        let action: () -> Void

        init(title: String, role: Role = .task, action: @escaping () -> Void = {}) {
            self.title = title
            self.role = role
            self.action = action
        }

        static func cancel(title: String = "Cancel", action: @escaping () -> Void = {}) -> Action {
            .init(title: title, role: .cancel, action: action)
        }

        static func destroy(title: String, action: @escaping () -> Void) -> Action {
            .init(title: title, role: .destructive, action: action)
        }

        static func retry(title: String = "Retry", action: @escaping () -> Void) -> Action {
            .init(title: title, role: .retry, action: action)
        }

        static func == (lhs: Action, rhs: Action) -> Bool {
            lhs.title == rhs.title
        }
    }

    init(title: String = "There was a problem", message: String, actions: [Action] = []) {
        self.title = title
        self.message = message
        self.actions = actions
    }

    let title: String
    let message: String
    let actions: [Action]
}

// MARK: -

extension View {
    func alert(_ error: PresentableError, isPresented: Binding<Bool>) -> some View {
        alert(error.title, isPresented: isPresented) {
            ForEach(error.actions, id: \.title) {
                Button($0.title, role: ButtonRole(role: $0.role), action: $0.action)
            }
        } message: { Text(error.message) }

    }
}

// MARK: -

private extension ButtonRole {
    init?(role: PresentableError.Action.Role) {
        switch role {
        case .cancel:
            self = .cancel
        case .destructive:
            self = .destructive
        case .retry, .task:
            return nil
        }
    }
}
