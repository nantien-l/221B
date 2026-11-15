import SwiftUI
import Observation
import Foundation

struct CollectionRowView: View {
    let collection: Collection
    @Environment(\.colorScheme) private var colorScheme

    private var ink: Color { colorScheme == .dark ? Color(red: 0.92, green: 0.90, blue: 0.84) : Color(red: 0.18, green: 0.20, blue: 0.17) }
    private var muted: Color { colorScheme == .dark ? Color(red: 0.70, green: 0.70, blue: 0.63) : Color(red: 0.40, green: 0.42, blue: 0.35) }
    private var accent: Color { colorScheme == .dark ? Color(red: 0.58, green: 0.68, blue: 0.51) : Color(red: 0.25, green: 0.37, blue: 0.28) }
    private var paper: Color { colorScheme == .dark ? Color(red: 0.17, green: 0.18, blue: 0.16) : Color(red: 0.99, green: 0.98, blue: 0.95) }

    var body: some View {
        HStack(alignment: .top, spacing: 18) {
            VStack(spacing: 10) {
                Image(systemName: "books.vertical").font(.title2.weight(.light)).foregroundStyle(accent)
                Rectangle().fill(accent.opacity(0.45)).frame(width: 22, height: 1)
                Text(String(collection.year)).font(.caption.monospacedDigit()).foregroundStyle(accent)
            }.frame(width: 66).frame(maxHeight: .infinity).background(accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 8) {
                Text("STORY COLLECTION").font(.system(.caption2, design: .rounded, weight: .semibold)).tracking(1.2).foregroundStyle(accent)
                Text(collection.title)
                    .font(.system(.title3, design: .serif, weight: .semibold)).foregroundStyle(ink)
                    .lineLimit(3).multilineTextAlignment(.leading)
                Spacer(minLength: 0)
                HStack { Text("Published \(collection.year)"); Spacer(); Text("\(collection.stories.count) stories") }.font(.caption).foregroundStyle(muted)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 166, maxHeight: 166, alignment: .leading)
        .background(paper, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(accent.opacity(0.2)))
    }
}
