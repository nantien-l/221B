import SwiftUI
import Observation
import Foundation

struct ReadingProgressView: View {
    @Environment(DataManager.self) var dataManager

    var body: some View {
        List {
            if !dataManager.stories.isEmpty {
                Section(header: Text("Reading Progress")) {
                    ForEach(dataManager.stories) { story in
                        ReadingProgressRowView(story: story)
                    }
                }
            }
        }
        .navigationTitle("Reading Progress")
    }
}
