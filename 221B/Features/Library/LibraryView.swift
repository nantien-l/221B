import SwiftUI
import Observation
import Foundation

struct LibraryView: View {
    @Environment(AppState.self) var appState
    @Environment(DataManager.self) var dataManager

    var body: some View {
        NavigationStack {
            Group {
                if appState.readingMode == .collections {
                    CollectionsView()
                } else {
                    ChronologyView()
                }
            }
            .modifier(StoryDestinations())
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Collections") {
                            appState.readingMode = .collections
                        }
                        Button("Chronology") {
                            appState.readingMode = .chronology
                        }
                    } label: {
                        Label("Reading Mode", systemImage: "arrow.left.and.right.horizontal")
                    }
                }
            }
        }
    }
}
