import SwiftUI
import Observation
import Foundation

struct BookmarksView: View {
    @Environment(DataManager.self) var dataManager

    var body: some View {
        List {
            if !dataManager.stories.filter({ $0.isBookmarked }).isEmpty {
                Section(header: Text("Bookmarked Stories")) {
                    ForEach(dataManager.stories.filter { $0.isBookmarked }) { story in
                        NavigationLink(value: story) {
                            StoryRowView(story: story)
                        }
                    }
                }
            }
        }
        .navigationTitle("Bookmarks")
    }
}
