import Foundation

struct CaseTimelineEntry: Identifiable {
    let story: Story
    let year: Int
    let order: Int
    var id: String { story.id }
}
