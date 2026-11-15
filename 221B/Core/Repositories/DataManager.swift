import SwiftUI
import Observation
import Foundation

@Observable
class DataManager {
    var collections: [Collection] = []
    var stories: [Story] = []
    var characters: [Character] = []
    var locations: [Location] = []
    var appearances: [Appearance] = []
    var storyLocations: [StoryLocation] = []
    var chronologyEntries: [ChronologyEntry] = []

    var caseTimeline: CaseTimeline?
    var caseTimelineError: String?
    var novels: [Story] = []
    var loadError: String?
    private var hasLoaded = false
    private let userLibraryStore = UserLibraryStore()

    func loadData() {
        guard !hasLoaded else { return }
        do {
            let bibliography = try JSONDataRepository.shared.loadBibliography()
            collections = bibliography.collections
            novels = bibliography.novels
            stories = bibliography.stories
            let characterData = try CharacterRepository().load(stories: stories)
            characters = characterData.characters
            let locationData = try LocationRepository().load(stories: stories)
            locations = locationData.locations
            appearances = characterData.appearances
            storyLocations = locationData.storyLocations
            do {
                caseTimeline = try CaseTimelineRepository().load(stories: stories)
                caseTimelineError = nil
            } catch {
                caseTimeline = nil
                caseTimelineError = error.localizedDescription
            }
            chronologyEntries = stories.map { ChronologyEntry(story: $0, proposedDate: nil, source: "", notes: "") }
            for character in characters {
                character.appearances = appearances.filter { $0.character.id == character.id }
            }
            for location in locations {
                location.storyLocations = storyLocations.filter { $0.location.id == location.id }
            }
            restoreUserLibrary()
            hasLoaded = true
            loadError = nil
        } catch {
            loadError = error.localizedDescription
        }
    }

    func toggleFavorite(for story: Story) {
        story.isFavorite.toggle()
        saveUserLibrary()
    }

    func toggleBookmark(for story: Story) {
        story.isBookmarked.toggle()
        saveUserLibrary()
    }

    func toggleFavorite(for character: Character) {
        character.isFavorite.toggle()
        saveUserLibrary()
    }

    func toggleFavorite(for location: Location) {
        location.isFavorite.toggle()
        saveUserLibrary()
    }

    func updateReadingProgress(for story: Story, to progress: Double) {
        let clamped = min(max(progress, 0), 1)
        guard abs(story.readingProgress - clamped) > 0.001 else { return }
        story.readingProgress = clamped
        saveUserLibrary()
    }

    private func restoreUserLibrary() {
        let snapshot = userLibraryStore.load()
        for story in stories {
            story.isFavorite = snapshot.favoriteStoryIDs.contains(story.id)
            story.isBookmarked = snapshot.bookmarkedStoryIDs.contains(story.id)
            story.readingProgress = snapshot.storyProgress[story.id] ?? 0
        }
        for character in characters {
            character.isFavorite = snapshot.favoriteCharacterIDs.contains(character.id)
        }
        for location in locations {
            location.isFavorite = snapshot.favoriteLocationIDs.contains(location.id)
        }
    }

    private func saveUserLibrary() {
        let snapshot = UserLibraryStore.Snapshot(
            favoriteStoryIDs: Set(stories.filter(\.isFavorite).map(\.id)),
            favoriteCharacterIDs: Set(characters.filter(\.isFavorite).map(\.id)),
            favoriteLocationIDs: Set(locations.filter(\.isFavorite).map(\.id)),
            bookmarkedStoryIDs: Set(stories.filter(\.isBookmarked).map(\.id)),
            storyProgress: Dictionary(uniqueKeysWithValues: stories.filter { $0.readingProgress > 0 }.map { ($0.id, $0.readingProgress) })
        )
        userLibraryStore.save(snapshot)
    }
}
