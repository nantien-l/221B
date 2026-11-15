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
            hasLoaded = true
            loadError = nil
        } catch {
            loadError = error.localizedDescription
        }
    }
}
