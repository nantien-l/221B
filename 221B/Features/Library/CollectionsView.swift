import SwiftUI
import Observation
import Foundation

struct CollectionsView: View {
    @Environment(DataManager.self) var dataManager
    @Environment(AppState.self) var appState

    var body: some View {
        List(dataManager.collections) { collection in
            NavigationLink(value: collection) {
                CollectionRowView(collection: collection)
            }
        }
    }
}
