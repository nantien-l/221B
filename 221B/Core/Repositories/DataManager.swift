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

    func loadSampleData() {
        let data = JSONDataRepository.shared.loadSampleData()
        collections = data.collections
        stories = data.stories
        characters = data.characters
        locations = data.locations
        appearances = data.appearances
        storyLocations = data.storyLocations
        chronologyEntries = data.chronologyEntries

        // Update relationships
        for character in characters {
            character.appearances = appearances.filter { $0.character.id == character.id }
        }

        for location in locations {
            location.storyLocations = storyLocations.filter { $0.location.id == location.id }
        }
    }
}

