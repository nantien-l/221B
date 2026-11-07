import SwiftUI
import Observation
import Foundation

struct My221BView: View {
    @Environment(DataManager.self) var dataManager
    @Environment(AppState.self) var appState

    var body: some View {
        NavigationStack {
            Group {
                if appState.showFavoritesOnly {
                    FavoritesView()
                } else if appState.showBookmarksOnly {
                    BookmarksView()
                } else if appState.showReadOnly {
                    ReadingProgressView()
                } else {
                    My221BMainView()
                }
            }
            .modifier(StoryDestinations())
            .navigationTitle("My 221B")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("All") {
                            appState.showFavoritesOnly = false
                            appState.showBookmarksOnly = false
                            appState.showReadOnly = false
                        }
                        Button("Favorites") {
                            appState.showFavoritesOnly = true
                            appState.showBookmarksOnly = false
                            appState.showReadOnly = false
                        }
                        Button("Bookmarks") {
                            appState.showFavoritesOnly = false
                            appState.showBookmarksOnly = true
                            appState.showReadOnly = false
                        }
                        Button("Reading Progress") {
                            appState.showFavoritesOnly = false
                            appState.showBookmarksOnly = false
                            appState.showReadOnly = true
                        }
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
        }
    }
}
