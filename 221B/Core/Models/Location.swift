import SwiftUI
import Observation
import Foundation

@Observable
class Location: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    var isFavorite: Bool = false
    var storyLocations: [StoryLocation] = []

    init(id: String = UUID().uuidString, name: String, description: String) {
        self.id = id
        self.name = name
        self.description = description
    }
    static func == (lhs: Location, rhs: Location) -> Bool { lhs.id == rhs.id }
    nonisolated func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
