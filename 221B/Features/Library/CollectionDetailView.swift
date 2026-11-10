import SwiftUI
import Observation
import Foundation

struct CollectionDetailView: View {
    let collection: Collection
    @Environment(DataManager.self) var dataManager
    @Environment(AppState.self) var appState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Section {
                    Text(collection.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Published: \(collection.year)")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }

                Section(header: Text("Stories")) {
                    ForEach(collection.stories) { story in
                        NavigationLink(value: story) {
                            StoryRowView(story: story)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(collection.title)
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
