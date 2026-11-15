import SwiftUI
import Observation
import Foundation

struct StoryRowView: View {
    let story: Story
    @Environment(\.colorScheme) private var colorScheme

    private var ink: Color { colorScheme == .dark ? Color(red: 0.92, green: 0.90, blue: 0.84) : Color(red: 0.18, green: 0.20, blue: 0.17) }
    private var muted: Color { colorScheme == .dark ? Color(red: 0.70, green: 0.70, blue: 0.63) : Color(red: 0.40, green: 0.42, blue: 0.35) }
    private var accent: Color { colorScheme == .dark ? Color(red: 0.77, green: 0.62, blue: 0.42) : Color(red: 0.47, green: 0.31, blue: 0.18) }
    private var paper: Color { colorScheme == .dark ? Color(red: 0.19, green: 0.17, blue: 0.14) : Color(red: 0.98, green: 0.95, blue: 0.88) }

    var body: some View {
        HStack(alignment: .top, spacing: 18) {
            VStack(spacing: 10) {
                Image(systemName: "book.closed").font(.title2.weight(.light)).foregroundStyle(accent)
                Rectangle().fill(accent.opacity(0.45)).frame(width: 22, height: 1)
                Text(String(story.publicationYear)).font(.caption.monospacedDigit()).foregroundStyle(accent)
            }.frame(width: 66).frame(maxHeight: .infinity).background(accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 8) {
                Text("NOVEL").font(.system(.caption2, design: .rounded, weight: .semibold)).tracking(1.2).foregroundStyle(accent)
                Text(story.title)
                    .font(.system(.title3, design: .serif, weight: .semibold)).foregroundStyle(ink)
                    .lineLimit(3).multilineTextAlignment(.leading)
                Spacer(minLength: 0)
                HStack(spacing: 8) {
                    Text("Published \(story.publicationYear)").font(.caption).foregroundStyle(muted)
                    Spacer()
                    if story.isFavorite { Image(systemName: "star.fill").foregroundStyle(.orange) }
                    if story.isBookmarked { Image(systemName: "bookmark.fill").foregroundStyle(accent) }
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 166, maxHeight: 166, alignment: .leading)
        .background(paper, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(accent.opacity(0.22)))
    }
}
