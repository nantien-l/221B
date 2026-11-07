import SwiftUI
import Observation
import Foundation

struct My221BMainView: View {
    @Environment(DataManager.self) var dataManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Section(header: Text("Reading Progress")) {
                    if !dataManager.stories.isEmpty {
                        ForEach(dataManager.stories) { story in
                            ReadingProgressRowView(story: story)
                        }
                    }
                }

                Section(header: Text("Favorites")) {
                    if dataManager.characters.contains(where: { $0.isFavorite }) {
                        Text("Characters: \(dataManager.characters.filter { $0.isFavorite }.count)")
                    }
                    if dataManager.locations.contains(where: { $0.isFavorite }) {
                        Text("Locations: \(dataManager.locations.filter { $0.isFavorite }.count)")
                    }
                }

                Section(header: Text("Bookmarks")) {
                    if dataManager.stories.contains(where: { $0.isBookmarked }) {
                        Text("Stories: \(dataManager.stories.filter { $0.isBookmarked }.count)")
                    }
                }
            }
            .padding()
        }
    }
}
