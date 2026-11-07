import SwiftUI
import Observation
import Foundation

@Observable
class Story: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let collection: Collection
    let publicationYear: Int
    var isFavorite: Bool = false
    var isBookmarked: Bool = false
    var readingProgress: Double = 0.0
    var dateAdded: Date = Date()

    init(title: String, collection: Collection, publicationYear: Int) {
        self.title = title
        self.collection = collection
        self.publicationYear = publicationYear
    }
    static func == (lhs: Story, rhs: Story) -> Bool { lhs.id == rhs.id }
    nonisolated func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
