import SwiftUI
import Observation
import Foundation

struct PlacesView: View {
    @Environment(DataManager.self) var dataManager

    var body: some View {
        NavigationStack {
            List(dataManager.locations) { location in
                NavigationLink(value: location) {
                    LocationRowView(location: location)
                }
            }
            .modifier(StoryDestinations())
            .navigationTitle("Places")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
