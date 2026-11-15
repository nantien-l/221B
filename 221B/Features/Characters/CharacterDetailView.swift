import SwiftUI

struct CharacterDetailView: View {
    let character: Character
    @Environment(DataManager.self) private var dataManager
    @Environment(\.colorScheme) private var colorScheme

    private var ink: Color { colorScheme == .dark ? Color(red: 0.91, green: 0.89, blue: 0.83) : Color(red: 0.18, green: 0.20, blue: 0.17) }
    private var muted: Color { colorScheme == .dark ? Color(red: 0.69, green: 0.69, blue: 0.62) : Color(red: 0.40, green: 0.42, blue: 0.35) }
    private var accent: Color { colorScheme == .dark ? Color(red: 0.65, green: 0.73, blue: 0.57) : Color(red: 0.25, green: 0.37, blue: 0.28) }
    private var paper: Color { colorScheme == .dark ? Color(red: 0.17, green: 0.18, blue: 0.16) : Color(red: 0.99, green: 0.98, blue: 0.95) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                profileHeader
                biography
                appearances
            }
            .frame(maxWidth: 680, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 38)
            .padding(.bottom, 72)
            .frame(maxWidth: .infinity)
        }
        .background(BookColors.background(for: colorScheme).ignoresSafeArea())
        .navigationTitle(character.name)
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private var profileHeader: some View {
        VStack(spacing: 16) {
            HStack(spacing: 10) {
                Rectangle().frame(width: 30, height: 1)
                Text("CHARACTER FILE")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .tracking(2)
                Rectangle().frame(width: 30, height: 1)
            }
            .foregroundStyle(accent)

            Image(systemName: "person.crop.circle")
                .font(.system(size: 38, weight: .ultraLight))
                .foregroundStyle(accent)
                .frame(width: 76, height: 76)
                .background(accent.opacity(0.09), in: Circle())
                .accessibilityHidden(true)
                .padding(.top, 4)

            Text(character.name)
                .font(.system(.largeTitle, design: .serif, weight: .semibold))
                .foregroundStyle(ink)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            Text(character.category.rawValue.uppercased())
                .font(.system(.caption2, design: .rounded, weight: .semibold))
                .tracking(1.4)
                .foregroundStyle(accent)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(accent.opacity(0.09), in: Capsule())

            Button { dataManager.toggleFavorite(for: character) } label: {
                Label(character.isFavorite ? "Saved to favourites" : "Add to favourites", systemImage: character.isFavorite ? "star.fill" : "star")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(character.isFavorite ? paper : accent)
                    .padding(.horizontal, 15).padding(.vertical, 9)
                    .background(character.isFavorite ? accent : accent.opacity(0.09), in: Capsule())
            }
            .buttonStyle(.plain)

            if !character.aliases.isEmpty {
                VStack(spacing: 5) {
                    Text("ALSO KNOWN AS")
                        .font(.system(.caption2, design: .rounded, weight: .medium))
                        .tracking(1.2)
                    Text(character.aliases.joined(separator: " · "))
                        .font(.system(.subheadline, design: .serif))
                        .multilineTextAlignment(.center)
                }
                .foregroundStyle(muted)
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 22)
        .padding(.vertical, 34)
        .background(paper, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(accent.opacity(0.2)))
    }

    private var biography: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading("BIOGRAPHY")
            Text(character.biography.isEmpty ? "No biography available yet." : character.biography)
                .font(.system(.body, design: .serif))
                .foregroundStyle(character.biography.isEmpty ? muted : ink)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var appearances: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                sectionHeading("APPEARANCES")
                Spacer()
                if !character.appearances.isEmpty {
                    Text("\(character.appearances.count) \(character.appearances.count == 1 ? "story" : "stories")")
                        .font(.footnote)
                        .foregroundStyle(muted)
                }
            }
            if character.appearances.isEmpty {
                Text("No related stories available yet.")
                    .font(.subheadline)
                    .foregroundStyle(muted)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(Array(character.appearances.enumerated()), id: \.element.id) { index, appearance in
                        NavigationLink(value: appearance.story) {
                            appearanceRow(appearance, showSeparator: index < character.appearances.count - 1)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .background(paper, in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(accent.opacity(0.16)))
            }
        }
    }

    private func sectionHeading(_ title: String) -> some View {
        Text(title)
            .font(.system(.caption, design: .rounded, weight: .semibold))
            .tracking(1.5)
            .foregroundStyle(accent)
            .accessibilityAddTraits(.isHeader)
    }

    private func appearanceLabel(_ appearance: Appearance) -> String {
        let kind = appearance.isMention.map { $0 ? "Mention" : "Full appearance" } ?? "Listed in story"
        return appearance.role.map { "\(kind) · \($0.rawValue.capitalized)" } ?? kind
    }

    private func appearanceRow(_ appearance: Appearance, showSeparator: Bool) -> some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 18, weight: .light))
                .foregroundStyle(accent)
                .frame(width: 42, height: 42)
                .background(accent.opacity(0.09), in: RoundedRectangle(cornerRadius: 9))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 5) {
                Text(appearance.story.title)
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(appearanceLabel(appearance))
                    .font(.footnote)
                    .foregroundStyle(muted)
            }
            Spacer(minLength: 4)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(muted)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
        .overlay(alignment: .bottom) {
            if showSeparator {
                Rectangle().fill(accent.opacity(0.14)).frame(height: 1).padding(.leading, 78)
            }
        }
    }
}
