import SwiftUI
import Observation
import Foundation

@Observable
class AppState {
    var selectedStory: Story? = nil
    var selectedCharacter: Character? = nil
    var selectedLocation: Location? = nil
    var selectedCollection: Collection? = nil
    var readingMode: ReadingMode = .collections
    var searchText: String = ""
    var showFavoritesOnly: Bool = false
    var showBookmarksOnly: Bool = false
    var showReadOnly: Bool = false
}
