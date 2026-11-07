import SwiftUI
import Observation
import Foundation

@Observable
class Appearance: Identifiable, Hashable {
    let id = UUID()
    let character: Character
    let story: Story
    let role: Role
    let isMention: Bool

    init(character: Character, story: Story, role: Role, isMention: Bool) {
        self.character = character
        self.story = story
        self.role = role
        self.isMention = isMention
    }
    static func == (lhs: Appearance, rhs: Appearance) -> Bool { lhs.id == rhs.id }
    nonisolated func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
