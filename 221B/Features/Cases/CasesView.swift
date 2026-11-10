import SwiftUI
import Observation
import Foundation

struct CasesView: View {
    @Environment(DataManager.self) var dataManager

    var body: some View {
        NavigationStack {
            List(dataManager.stories) { story in
                NavigationLink(value: story) {
                    StoryRowView(story: story)
                }
            }
            .modifier(StoryDestinations())
            .navigationTitle("Cases")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
    }
}
