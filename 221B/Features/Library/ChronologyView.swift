import SwiftUI
import Observation
import Foundation

struct ChronologyView: View {
    @Environment(DataManager.self) var dataManager

    var body: some View {
        List(dataManager.chronologyEntries) { entry in
            NavigationLink(value: entry.story) {
                ChronologyEntryRowView(entry: entry)
            }
        }
    }
}
