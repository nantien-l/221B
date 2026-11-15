import SwiftUI
import Observation
import Foundation

struct My221BMainView: View {
    @Environment(DataManager.self) var dataManager
    @Environment(\.colorScheme) private var colorScheme

    private var ink: Color { colorScheme == .dark ? Color(red: 0.92, green: 0.90, blue: 0.84) : Color(red: 0.18, green: 0.20, blue: 0.17) }
    private var muted: Color { colorScheme == .dark ? Color(red: 0.69, green: 0.69, blue: 0.62) : Color(red: 0.40, green: 0.42, blue: 0.35) }
    private var accent: Color { colorScheme == .dark ? Color(red: 0.65, green: 0.73, blue: 0.57) : Color(red: 0.25, green: 0.37, blue: 0.28) }
    private var paper: Color { colorScheme == .dark ? Color(red: 0.17, green: 0.18, blue: 0.16) : Color(red: 0.99, green: 0.98, blue: 0.95) }

    private var favoriteCount: Int { dataManager.characters.filter(\.isFavorite).count + dataManager.locations.filter(\.isFavorite).count + dataManager.stories.filter(\.isFavorite).count }
    private var bookmarkCount: Int { dataManager.stories.filter(\.isBookmarked).count }
    private var inProgress: [Story] { dataManager.stories.filter { $0.readingProgress > 0 && $0.readingProgress < 1 }.sorted { $0.readingProgress > $1.readingProgress } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                header
                stats
                progressSection
                librarySection
            }
            .frame(maxWidth: 680, alignment: .leading)
            .padding(.horizontal, 24).padding(.top, 28).padding(.bottom, 72)
            .frame(maxWidth: .infinity)
        }
        .background(BookColors.background(for: colorScheme).ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("YOUR SHERLOCK HOLMES DESK").font(.system(.caption, design: .rounded, weight: .semibold)).tracking(1.6).foregroundStyle(accent)
            Text("My 221B").font(.system(.largeTitle, design: .serif, weight: .semibold)).foregroundStyle(ink)
            Text("Keep your reading, favourites, and bookmarks close at hand.").font(.subheadline).foregroundStyle(muted)
        }
    }

    private var stats: some View {
        HStack(spacing: 12) {
            stat("Reading", value: inProgress.count, icon: "book.closed")
            stat("Favorites", value: favoriteCount, icon: "star")
            stat("Bookmarks", value: bookmarkCount, icon: "bookmark")
        }
    }

    private func stat(_ title: String, value: Int, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon).foregroundStyle(accent)
            Text("\(value)").font(.system(.title2, design: .serif, weight: .semibold)).foregroundStyle(ink)
            Text(title.uppercased()).font(.system(.caption2, design: .rounded, weight: .semibold)).tracking(0.8).foregroundStyle(muted)
        }.frame(maxWidth: .infinity, alignment: .leading).padding(16).background(paper, in: RoundedRectangle(cornerRadius: 14)).overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(accent.opacity(0.16)))
    }

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Continue reading", subtitle: inProgress.isEmpty ? "Your next chapter will appear here." : "Pick up where you left off.")
            if inProgress.isEmpty {
                emptyCard("book.pages", title: "No stories in progress", text: "Open a story from the Library to begin reading.")
            } else {
                VStack(spacing: 0) { ForEach(inProgress.prefix(4)) { ReadingProgressRowView(story: $0).padding(.horizontal, 18).padding(.vertical, 12) } }.background(paper, in: RoundedRectangle(cornerRadius: 14)).overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(accent.opacity(0.16)))
            }
        }
    }

    private var librarySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Your library", subtitle: "A quiet corner for the things you want to remember.")
            HStack(spacing: 12) { emptyCard("star", title: "Favorites", text: "\(favoriteCount) saved") ; emptyCard("bookmark", title: "Bookmarks", text: "\(bookmarkCount) saved") }
        }
    }

    private func sectionTitle(_ title: String, subtitle: String) -> some View { VStack(alignment: .leading, spacing: 4) { Text(title).font(.system(.title3, design: .serif, weight: .semibold)).foregroundStyle(ink); Text(subtitle).font(.footnote).foregroundStyle(muted) } }
    private func emptyCard(_ icon: String, title: String, text: String) -> some View { VStack(alignment: .leading, spacing: 8) { Image(systemName: icon).font(.title3).foregroundStyle(accent); Text(title).font(.system(.headline, design: .serif)).foregroundStyle(ink); Text(text).font(.footnote).foregroundStyle(muted) }.frame(maxWidth: .infinity, minHeight: 104, alignment: .topLeading).padding(16).background(paper, in: RoundedRectangle(cornerRadius: 14)).overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(accent.opacity(0.16))) }
}
