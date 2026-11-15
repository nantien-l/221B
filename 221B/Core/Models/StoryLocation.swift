import SwiftUI
import Observation
import Foundation

@Observable
class StoryLocation: Identifiable, Hashable {
    let id = UUID()
    let story: Story
    let location: Location
    let significance: Significance?

    init(story: Story, location: Location, significance: Significance?) {
        self.story = story
        self.location = location
        self.significance = significance
    }
    static func == (lhs: StoryLocation, rhs: StoryLocation) -> Bool { lhs.id == rhs.id }
    nonisolated func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
