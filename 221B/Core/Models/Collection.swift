import SwiftUI
import Observation
import Foundation

@Observable
class Collection: Identifiable, Hashable {
    let id: String
    let title: String
    let year: Int
    let bookOrder: Int
    var stories: [Story]

    init(id: String, title: String, year: Int, bookOrder: Int, stories: [Story]) {
        self.id = id
        self.bookOrder = bookOrder
        self.title = title
        self.year = year
        self.stories = stories
    }
    static func == (lhs: Collection, rhs: Collection) -> Bool { lhs.id == rhs.id }
    nonisolated func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
