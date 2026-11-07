import SwiftUI
import Observation
import Foundation

@Observable
class ChronologyEntry: Identifiable, Hashable {
    let id = UUID()
    let story: Story
    let proposedDate: Date?
    let source: String
    let notes: String

    init(story: Story, proposedDate: Date?, source: String, notes: String) {
        self.story = story
        self.proposedDate = proposedDate
        self.source = source
        self.notes = notes
    }
    static func == (lhs: ChronologyEntry, rhs: ChronologyEntry) -> Bool { lhs.id == rhs.id }
    nonisolated func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

