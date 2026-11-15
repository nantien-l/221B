import SwiftUI
import Observation
import Foundation

struct ChronologyView: View {
    @Environment(DataManager.self) var dataManager
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        List(dataManager.chronologyEntries) { entry in
            NavigationLink(value: entry.story) {
                ChronologyEntryRowView(entry: entry)
            }
            .listRowBackground(BookColors.background(for: colorScheme))
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(BookColors.background(for: colorScheme))
    }
}
