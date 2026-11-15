import SwiftUI

struct CharactersView: View {
    @Environment(DataManager.self) private var dataManager
    @Environment(\.colorScheme) private var colorScheme
    @State private var searchText = ""
    @State private var category: CharacterCategory?
    @State private var groupByStory = false
    @State private var expandedStoryIDs: Set<String> = []

    private var ink: Color { colorScheme == .dark ? Color(red: 0.91, green: 0.89, blue: 0.83) : Color(red: 0.18, green: 0.20, blue: 0.17) }
    private var muted: Color { colorScheme == .dark ? Color(red: 0.69, green: 0.69, blue: 0.62) : Color(red: 0.40, green: 0.42, blue: 0.35) }
    private var accent: Color { colorScheme == .dark ? Color(red: 0.65, green: 0.73, blue: 0.57) : Color(red: 0.25, green: 0.37, blue: 0.28) }
    private var paper: Color { colorScheme == .dark ? Color(red: 0.17, green: 0.18, blue: 0.16) : Color(red: 0.99, green: 0.98, blue: 0.95) }

    private var filteredCharacters: [Character] {
        dataManager.characters.filter { character in
            (category == nil || character.category == category) &&
            (searchText.isEmpty || character.name.localizedCaseInsensitiveContains(searchText) ||
             character.aliases.contains { $0.localizedCaseInsensitiveContains(searchText) })
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    header
                    Picker("Browse characters", selection: $groupByStory) {
                        Text("People").tag(false)
                        Text("By Story").tag(true)
                    }
                    .pickerStyle(.segmented)
                    if let error = dataManager.loadError {
                        ContentUnavailableView("Unable to Load Characters", systemImage: "exclamationmark.triangle", description: Text(error))
                    } else if filteredCharacters.isEmpty {
                        ContentUnavailableView("No Characters Found", systemImage: "person.crop.circle.badge.questionmark", description: Text("Try a different search or category."))
                    } else if groupByStory {
                        storyDirectory
                    } else {
                        directory
                    }
                }
                .frame(maxWidth: 680, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 32)
                .padding(.bottom, 72)
                .frame(maxWidth: .infinity)
            }
            .background(BookColors.background(for: colorScheme).ignoresSafeArea())
            .searchable(text: $searchText, prompt: "Search names or aliases")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button { category = nil } label: {
                            if category == nil { Label("All", systemImage: "checkmark") } else { Text("All") }
                        }
                        ForEach(CharacterCategory.allCases, id: \.self) { item in
                            Button { category = item } label: {
                                if category == item { Label(item.rawValue.capitalized, systemImage: "checkmark") }
                                else { Text(item.rawValue.capitalized) }
                            }
                        }
                    } label: {
                        Label(category?.rawValue.capitalized ?? "Category", systemImage: "line.3.horizontal.decrease")
                    }
                }
            }
            .modifier(StoryDestinations())
            .navigationTitle("Characters")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("THE BAKER STREET ARCHIVE")
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .tracking(1.6)
                .foregroundStyle(accent)
            Text("People of the stories")
                .font(.system(.largeTitle, design: .serif, weight: .semibold))
                .foregroundStyle(ink)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            Text("Browse selected characters and their associated stories. The index is not exhaustive.")
                .font(.subheadline)
                .foregroundStyle(muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(paper, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(accent.opacity(0.2)))
    }

    private var directory: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(category?.rawValue.uppercased() ?? "CHARACTER DIRECTORY")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .tracking(1.4)
                    .foregroundStyle(accent)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Text("\(filteredCharacters.count) \(filteredCharacters.count == 1 ? "character" : "characters")")
                    .font(.footnote)
                    .foregroundStyle(muted)
            }
            Link("Source: The Sherlock Holmes Database", destination: URL(string: "https://shdb.guidesite.co.uk/characters/characters-list")!)
                .font(.footnote).foregroundStyle(accent)
            LazyVStack(spacing: 0) {
                ForEach(Array(filteredCharacters.enumerated()), id: \.element.id) { index, character in
                    NavigationLink(value: character) {
                        characterRow(character, showSeparator: index < filteredCharacters.count - 1)
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(paper, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(accent.opacity(0.16)))
        }
    }

    private var storyDirectory: some View {
        let matchingIDs = Set(filteredCharacters.map(\.id))
        let stories = dataManager.stories.filter { story in
            dataManager.appearances.contains { $0.story.id == story.id && matchingIDs.contains($0.character.id) }
        }
        return VStack(alignment: .leading, spacing: 20) {
            Link("Source: The Sherlock Holmes Database", destination: URL(string: "https://shdb.guidesite.co.uk/characters/characters-list")!)
                .font(.footnote).foregroundStyle(accent)
            Text("Only stories with available character records are shown.")
                .font(.footnote)
                .foregroundStyle(muted)
                .fixedSize(horizontal: false, vertical: true)
            ForEach(stories) { story in
                let people = dataManager.appearances.filter { $0.story.id == story.id && matchingIDs.contains($0.character.id) }
                let isExpanded = expandedStoryIDs.contains(story.id)
                VStack(alignment: .leading, spacing: 0) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.22)) {
                            if isExpanded { expandedStoryIDs.remove(story.id) }
                            else { expandedStoryIDs.insert(story.id) }
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(story.title)
                                    .font(.system(.headline, design: .serif))
                                    .foregroundStyle(ink)
                                Text(story.collection?.title ?? "Novel")
                                    .font(.footnote).foregroundStyle(muted)
                            }
                            Spacer()
                            Text("\(people.count)").font(.caption.monospacedDigit()).foregroundStyle(muted)
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down").font(.caption.weight(.semibold)).foregroundStyle(muted)
                        }
                        .padding(20)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    if isExpanded {
                        Rectangle().fill(accent.opacity(0.14)).frame(height: 1)
                        ForEach(Array(people.enumerated()), id: \.element.id) { index, appearance in
                            NavigationLink(value: appearance.character) {
                                characterRow(appearance.character, showSeparator: index < people.count - 1)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .background(paper, in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(accent.opacity(0.16)))
            }
        }
    }

    private func characterRow(_ character: Character, showSeparator: Bool) -> some View {
        HStack(spacing: 16) {
            Image(systemName: "person.crop.circle")
                .font(.system(size: 23, weight: .light))
                .foregroundStyle(accent)
                .frame(width: 46, height: 46)
                .background(accent.opacity(0.09), in: Circle())
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 5) {
                Text(character.name)
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(character.category.rawValue.capitalized)
                    .font(.footnote)
                    .foregroundStyle(muted)
            }
            Spacer(minLength: 4)
            if character.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundStyle(accent)
                    .accessibilityLabel("Favorite")
            }
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
                Rectangle().fill(accent.opacity(0.14)).frame(height: 1).padding(.leading, 82)
            }
        }
    }
}
