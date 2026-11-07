import SwiftUI
import Observation
import Foundation

@Observable
class Collection: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let year: Int
    var stories: [Story]

    init(title: String, year: Int, stories: [Story]) {
        self.title = title
        self.year = year
        self.stories = stories
    }
    static func == (lhs: Collection, rhs: Collection) -> Bool { lhs.id == rhs.id }
    nonisolated func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
