import SwiftUI

struct StoryDestinations: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: Collection.self) { CollectionDetailView(collection: $0) }
            .navigationDestination(for: Story.self) { StoryDetailView(story: $0) }
            .navigationDestination(for: Character.self) { CharacterDetailView(character: $0) }
            .navigationDestination(for: Location.self) { LocationDetailView(location: $0) }
    }
}
