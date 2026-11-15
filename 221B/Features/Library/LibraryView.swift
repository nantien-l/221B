import SwiftUI

struct LibraryView: View {
    var body: some View {
        NavigationStack {
            CollectionsView()
                .modifier(StoryDestinations())
                .navigationTitle("Library")
                #if !os(macOS)
                .navigationBarTitleDisplayMode(.large)
                #endif
        }
    }
}
