//
// Copyright © 2022 Robin Charlton. All rights reserved.
//

import SwiftUI

extension Binding {
    static func stub(_ value: Value) -> Self {
        Binding(get: { value }, set: { _ in })
    }
}

extension Binding where Value: ExpressibleByBooleanLiteral {
    static var ignore: Self {
        Binding(get: { false }, set: { _ in })
    }
}

extension Binding where Value: ExpressibleByIntegerLiteral {
    static var ignore: Self {
        Binding(get: { 0 }, set: { _ in })
    }
}

extension Binding where Value: ExpressibleByStringLiteral {
    static var ignore: Self {
        Binding(get: { "" }, set: { _ in })
    }
}
