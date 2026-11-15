import SwiftUI

struct CollectionDetailView: View {
    let collection: Collection
    @Environment(\.colorScheme) private var colorScheme

    private var ink: Color { colorScheme == .dark ? Color(red: 0.91, green: 0.89, blue: 0.83) : Color(red: 0.18, green: 0.20, blue: 0.17) }
    private var muted: Color { colorScheme == .dark ? Color(red: 0.69, green: 0.69, blue: 0.62) : Color(red: 0.40, green: 0.42, blue: 0.35) }
    private var accent: Color { colorScheme == .dark ? Color(red: 0.65, green: 0.73, blue: 0.57) : Color(red: 0.25, green: 0.37, blue: 0.28) }
    private var paper: Color { colorScheme == .dark ? Color(red: 0.17, green: 0.18, blue: 0.16) : Color(red: 0.99, green: 0.98, blue: 0.95) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                collectionHeader
                contents
            }
            .frame(maxWidth: 680, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 38)
            .padding(.bottom, 72)
            .frame(maxWidth: .infinity)
        }
        .background(BookColors.background(for: colorScheme).ignoresSafeArea())
        .navigationTitle(collection.title)
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private var collectionHeader: some View {
        VStack(spacing: 18) {
            HStack(spacing: 10) {
                Rectangle().frame(width: 30, height: 1)
                Text("THE SHERLOCK HOLMES COLLECTION")
                    .font(.system(.caption2, design: .rounded, weight: .semibold))
                    .tracking(1.6)
                    .multilineTextAlignment(.center)
                Rectangle().frame(width: 30, height: 1)
            }
            .foregroundStyle(accent)

            Text(collection.title)
                .font(.system(.largeTitle, design: .serif, weight: .semibold))
                .foregroundStyle(ink)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            Text("ARTHUR CONAN DOYLE")
                .font(.system(.caption2, design: .rounded, weight: .medium))
                .tracking(1.4)
                .foregroundStyle(muted)

            Rectangle().fill(accent.opacity(0.4)).frame(width: 42, height: 1)
                .padding(.vertical, 2)

            HStack(spacing: 10) {
                Text("Published \(String(collection.year))")
                Text("·").accessibilityHidden(true)
                Text("\(collection.stories.count) stories")
            }
            .font(.subheadline)
            .foregroundStyle(muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 22)
        .padding(.vertical, 36)
        .background(paper, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(accent.opacity(0.2)))
    }

    private var contents: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("INSIDE THIS VOLUME")
                        .font(.system(.caption2, design: .rounded, weight: .semibold))
                        .tracking(1.5)
                        .foregroundStyle(accent)
                    Text("Contents")
                        .font(.system(.title2, design: .serif, weight: .semibold))
                        .foregroundStyle(ink)
                        .accessibilityAddTraits(.isHeader)
                }
                Spacer()
                Text("\(collection.stories.count) stories")
                    .font(.footnote)
                    .foregroundStyle(muted)
            }
            .padding(.bottom, 18)

            LazyVStack(spacing: 0) {
                ForEach(Array(collection.stories.enumerated()), id: \.element.id) { index, story in
                    NavigationLink(value: story) {
                        storyRow(story, number: index + 1)
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(paper, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(accent.opacity(0.16)))
        }
    }

    private func storyRow(_ story: Story, number: Int) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Text(String(format: "%02d", number))
                .font(.system(.subheadline, design: .serif))
                .foregroundStyle(accent)
                .monospacedDigit()
                .frame(width: 28, alignment: .leading)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 5) {
                Text(story.title)
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text("First published \(String(story.publicationYear))")
                    .font(.footnote)
                    .foregroundStyle(muted)
            }
            Spacer(minLength: 4)
            if story.isFavorite {
                Image(systemName: "star.fill").foregroundStyle(accent).accessibilityLabel("Favorite")
            }
            if story.isBookmarked {
                Image(systemName: "bookmark.fill").foregroundStyle(accent).accessibilityLabel("Bookmarked")
            }
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(muted)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .contentShape(Rectangle())
        .overlay(alignment: .bottom) {
            if number < collection.stories.count {
                Rectangle().fill(accent.opacity(0.14)).frame(height: 1).padding(.leading, 64)
            }
        }
    }
}
