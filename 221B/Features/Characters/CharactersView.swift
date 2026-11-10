import SwiftUI
import Observation
import Foundation

struct CharactersView: View {
    @Environment(DataManager.self) var dataManager

    @State private var searchText = ""
    @State private var category: CharacterCategory?

    private var filteredCharacters: [Character] {
        dataManager.characters.filter { character in
            (category == nil || character.category == category) &&
            (searchText.isEmpty || character.name.localizedCaseInsensitiveContains(searchText) ||
             character.aliases.contains { $0.localizedCaseInsensitiveContains(searchText) })
        }
    }

    var body: some View {
        NavigationStack {
            List(filteredCharacters) { character in
                NavigationLink(value: character) {
                    CharacterRowView(character: character)
                }
            }
            .searchable(text: $searchText)
            .toolbar {
                Menu("Category") {
                    Button("All") { category = nil }
                    ForEach(CharacterCategory.allCases, id: \.self) { item in
                        Button(item.rawValue.capitalized) { category = item }
                    }
                }
            }
            .modifier(StoryDestinations())
            .navigationTitle("Characters")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
    }
}
