import SwiftUI
import Observation
import Foundation

@Observable
class Character: Identifiable, Hashable {
    let id: String
    let name: String
    let aliases: [String]
    let category: CharacterCategory
    let biography: String
    var isFavorite: Bool = false
    var appearances: [Appearance] = []

    init(id: String = UUID().uuidString, name: String, aliases: [String], category: CharacterCategory, biography: String) {
        self.id = id
        self.name = name
        self.aliases = aliases
        self.category = category
        self.biography = biography
    }
    static func == (lhs: Character, rhs: Character) -> Bool { lhs.id == rhs.id }
    nonisolated func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
