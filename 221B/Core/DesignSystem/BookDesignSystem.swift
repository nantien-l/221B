import SwiftUI

extension Font {
    static let bookSection = Font.system(.title3, design: .serif, weight: .semibold)
    static let bookItem = Font.system(.headline, design: .serif)
    static let bookMeta = Font.system(.subheadline, design: .serif)
    static let bookCaption = Font.system(.caption, design: .serif)
}

enum BookColors {
    static func background(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.11, green: 0.12, blue: 0.11)
            : Color(red: 0.97, green: 0.96, blue: 0.93)
    }
}
