import SwiftUI

struct StoryDetailView: View {
    let story: Story
    @Environment(DataManager.self) private var dataManager
    @Environment(\.colorScheme) private var colorScheme

    private var timelineEntry: CaseTimelineEntry? {
        dataManager.caseTimeline?.entries.first { $0.id == story.id }
    }
    private var characters: [Character] {
        dataManager.appearances.filter { $0.story.id == story.id }.map(\.character)
    }
    private var locations: [Location] {
        dataManager.storyLocations.filter { $0.story.id == story.id }.map(\.location)
    }
    private var ink: Color { colorScheme == .dark ? Color(red: 0.91, green: 0.89, blue: 0.83) : Color(red: 0.18, green: 0.20, blue: 0.17) }
    private var muted: Color { colorScheme == .dark ? Color(red: 0.69, green: 0.69, blue: 0.62) : Color(red: 0.40, green: 0.42, blue: 0.35) }
    private var accent: Color { colorScheme == .dark ? Color(red: 0.65, green: 0.73, blue: 0.57) : Color(red: 0.25, green: 0.37, blue: 0.28) }
    private var paper: Color { colorScheme == .dark ? Color(red: 0.17, green: 0.18, blue: 0.16) : Color(red: 0.99, green: 0.98, blue: 0.95) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                details
                relatedSections
            }
            .frame(maxWidth: 680)
            .padding(.horizontal, 24)
            .padding(.top, 38)
            .padding(.bottom, 72)
            .frame(maxWidth: .infinity)
        }
        .background(BookColors.background(for: colorScheme).ignoresSafeArea())
        .navigationTitle(story.title)
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private var header: some View {
        VStack(spacing: 18) {
            HStack(spacing: 10) {
                Rectangle().frame(width: 30, height: 1)
                Text(timelineEntry.map { "CASE FILE  ·  \(String(format: "%02d", $0.order))" } ?? "CASE FILE")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .tracking(2)
                Rectangle().frame(width: 30, height: 1)
            }
            .foregroundStyle(accent)

            Text(story.title)
                .font(.system(.largeTitle, design: .serif, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(ink)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: 6) {
                Text(story.collection?.title ?? "A Sherlock Holmes novel")
                    .font(.system(.subheadline, design: .serif))
                    .multilineTextAlignment(.center)
                Text("ARTHUR CONAN DOYLE")
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .tracking(1.4)
            }
            .foregroundStyle(muted)

            NavigationLink {
                StoryReaderView(story: story)
            } label: {
                Label("Read Original Text", systemImage: "book")
                    .font(.headline)
                    .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 15)
                    .background(accent, in: RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .padding(.top, 12)

            HStack(spacing: 12) {
                Button { dataManager.toggleFavorite(for: story) } label: {
                    Label(story.isFavorite ? "Favorited" : "Favorite", systemImage: story.isFavorite ? "star.fill" : "star")
                }
                Button { dataManager.toggleBookmark(for: story) } label: {
                    Label(story.isBookmarked ? "Bookmarked" : "Bookmark", systemImage: story.isBookmarked ? "bookmark.fill" : "bookmark")
                }
            }
            .font(.subheadline.weight(.medium))
            .buttonStyle(.bordered)
            .tint(accent)
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 22)
        .background(paper, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(accent.opacity(0.2)))
        .padding(.bottom, 36)
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeading("CASE DETAILS")
            detailRow("Estimated case year", value: timelineEntry.map { String($0.year) } ?? "Unknown")
            detailRow(story.collection == nil ? "Book publication" : "First UK publication", value: String(story.publicationYear))
            detailRow("Collection", value: story.collection?.title ?? "Standalone novel")
            if timelineEntry != nil {
                Text("Case year follows Baring-Gould's chronology and is an interpretation.")
                    .font(.footnote)
                    .foregroundStyle(muted)
                    .padding(.top, 14)
            }
        }
        .padding(.bottom, 36)
    }

    private func sectionHeading(_ title: String) -> some View {
        Text(title)
            .font(.system(.caption, design: .rounded, weight: .semibold))
            .tracking(1.5)
            .foregroundStyle(accent)
            .padding(.bottom, 12)
            .accessibilityAddTraits(.isHeader)
    }

    private func detailRow(_ label: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 16) {
            Text(label).foregroundStyle(muted)
            Spacer(minLength: 12)
            Text(value).foregroundStyle(ink).multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) { Rectangle().fill(accent.opacity(0.18)).frame(height: 1) }
    }

    private var relatedSections: some View {
        VStack(alignment: .leading, spacing: 24) {
            charactersGallery
            locationsSection
        }
    }

    // MARK: - Characters gallery

    /// Lightweight value type that wraps a Character for the page-swipe gallery.
    /// Satisfies assignment: struct + Identifiable + stored in an [array].
    private struct CaseCharacter: Identifiable {
        let id: String
        let name: String
        let category: String
        let biography: String
        let isFavorite: Bool
        let character: Character
    }

    private var caseCharacters: [CaseCharacter] {
        characters.map {
            CaseCharacter(
                id: $0.id,
                name: $0.name,
                category: $0.category.rawValue,
                biography: $0.biography,
                isFavorite: $0.isFavorite,
                character: $0
            )
        }
    }

    @ViewBuilder
    private var charactersGallery: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeading("CHARACTERS")
            if caseCharacters.isEmpty {
                Text("No related characters available yet.")
                    .font(.subheadline).foregroundStyle(muted)
            } else {
                TabView {
                    ForEach(caseCharacters) { caseChar in
                        NavigationLink(value: caseChar.character) {
                            characterCard(caseChar)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 4)
                        .padding(.bottom, 32)   // room for page indicator dots
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(height: 200)
            }
        }
    }

    private func characterCard(_ caseChar: CaseCharacter) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(caseChar.name)
                        .font(.system(.title3, design: .serif, weight: .semibold))
                        .foregroundStyle(ink)
                        .lineLimit(1)
                    Text(caseChar.category.capitalized)
                        .font(.caption.weight(.medium))
                        .tracking(0.8)
                        .foregroundStyle(accent)
                }
                Spacer()
                if caseChar.isFavorite {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(accent)
                }
            }
            Text(caseChar.biography)
                .font(.system(.footnote, design: .serif))
                .foregroundStyle(muted)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            Label("View character", systemImage: "arrow.right")
                .font(.caption.weight(.medium))
                .foregroundStyle(accent)
        }
        .padding(18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(paper, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(accent.opacity(0.2)))
    }

    // MARK: - Locations section

    private var locationsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeading("LOCATIONS")
            if locations.isEmpty {
                Text("No related locations available yet.").font(.subheadline).foregroundStyle(muted)
            } else {
                ForEach(locations) { location in
                    NavigationLink(value: location) {
                        LocationRowView(location: location).foregroundStyle(ink)
                    }
                }
            }
        }
    }
}
