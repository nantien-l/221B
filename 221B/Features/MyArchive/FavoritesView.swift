import SwiftUI
import Observation
import Foundation

struct FavoritesView: View {
    @Environment(DataManager.self) var dataManager

    var body: some View {
        List {
            if !dataManager.characters.filter({ $0.isFavorite }).isEmpty {
                Section(header: Text("Favorite Characters")) {
                    ForEach(dataManager.characters.filter { $0.isFavorite }) { character in
                        NavigationLink(value: character) {
                            CharacterRowView(character: character)
                        }
                    }
                }
            }

            if !dataManager.locations.filter({ $0.isFavorite }).isEmpty {
                Section(header: Text("Favorite Locations")) {
                    ForEach(dataManager.locations.filter { $0.isFavorite }) { location in
                        NavigationLink(value: location) {
                            LocationRowView(location: location)
                        }
                    }
                }
            }

            if !dataManager.stories.filter({ $0.isFavorite }).isEmpty {
                Section(header: Text("Favorite Stories")) {
                    ForEach(dataManager.stories.filter { $0.isFavorite }) { story in
                        NavigationLink(value: story) {
                            StoryRowView(story: story)
                        }
                    }
                }
            }
        }
        .navigationTitle("Favorites")
    }
}
