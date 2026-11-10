import SwiftUI
import Observation
import Foundation

struct LocationDetailView: View {
    let location: Location
    @Environment(DataManager.self) var dataManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Section {
                    Text(location.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }

                Section(header: Text("Description")) {
                    Text(location.description)
                }

                Section(header: Text("Related Stories")) {
                    if !location.storyLocations.isEmpty {
                        ForEach(location.storyLocations) { storyLocation in
                            NavigationLink(value: storyLocation.story) {
                                StoryLocationRowView(storyLocation: storyLocation)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(location.name)
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
