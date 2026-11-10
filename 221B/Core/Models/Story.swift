import SwiftUI
import Observation
import Foundation

@Observable
class Story: Identifiable, Hashable {
    let id: String
    let title: String
    let collection: Collection?
    let publicationYear: Int
    let position: Int
    let bookOrder: Int?
    var isFavorite: Bool = false
    var isBookmarked: Bool = false
    var readingProgress: Double = 0.0
    var dateAdded: Date = Date()

    init(id: String, title: String, collection: Collection?, publicationYear: Int, position: Int = 0, bookOrder: Int? = nil) {
        self.id = id
        self.title = title
        self.collection = collection
        self.publicationYear = publicationYear
        self.position = position
        self.bookOrder = bookOrder
    }
    static func == (lhs: Story, rhs: Story) -> Bool { lhs.id == rhs.id }
    nonisolated func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
