import SwiftUI
import Observation
import Foundation

struct StoryDetailView: View {
    let story: Story
    @Environment(DataManager.self) var dataManager
    @Environment(AppState.self) var appState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Section {
                    Text(story.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    HStack {
                        Text(story.collection.map { "From: \($0.title)" } ?? "Novel")
                        Spacer()
                        Text("\(story.publicationYear)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Button(action: {
                            story.isFavorite.toggle()
                        }) {
                            Label(story.isFavorite ? "Favorited" : "Favorite", systemImage: "star")
                                .foregroundColor(story.isFavorite ? .yellow : .primary)
                        }

                        Button(action: {
                            story.isBookmarked.toggle()
                        }) {
                            Label(story.isBookmarked ? "Bookmarked" : "Bookmark", systemImage: "bookmark")
                                .foregroundColor(story.isBookmarked ? .blue : .primary)
                        }
                    }
                    .padding()
                }

                NavigationLink {
                    StoryReaderView(story: story)
                } label: {
                    Label("Read Original Text", systemImage: "book")
                }
                .buttonStyle(.borderedProminent)

                Section(header: Text("Characters")) {
                    if let charactersInStory = charactersInStory(story: story) {
                        ForEach(charactersInStory) { character in
                            NavigationLink(value: character) {
                                CharacterRowView(character: character)
                            }
                        }
                    }
                }

                Section(header: Text("Locations")) {
                    if let locationsInStory = locationsInStory(story: story) {
                        ForEach(locationsInStory) { location in
                            NavigationLink(value: location) {
                                LocationRowView(location: location)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(story.title)
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private func charactersInStory(story: Story) -> [Character]? {
        var result: [Character] = []
        for appearance in dataManager.appearances {
            if appearance.story.id == story.id {
                result.append(appearance.character)
            }
        }
        return result.isEmpty ? nil : result
    }

    private func locationsInStory(story: Story) -> [Location]? {
        var result: [Location] = []
        for storyLocation in dataManager.storyLocations {
            if storyLocation.story.id == story.id {
                result.append(storyLocation.location)
            }
        }
        return result.isEmpty ? nil : result
    }
}
