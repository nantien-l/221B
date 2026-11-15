import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            LibraryView().tabItem { Label("Library", systemImage: "book.fill") }
            CasesView().tabItem { Label("Cases", systemImage: "magnifyingglass.circle.fill") }
            CharactersView().tabItem { Label("Characters", systemImage: "person.2.fill") }
            PlacesView().tabItem { Label("Places", systemImage: "map.fill") }
            MuseumView().tabItem { Label("Museum", systemImage: "building.columns.fill") }
            My221BView().tabItem { Label("My 221B", systemImage: "star.fill") }
        }
    }
}
