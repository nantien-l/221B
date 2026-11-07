import SwiftUI
import Observation
import Foundation

@main
struct MyApp: App {
    @State private var appState = AppState()
    @State private var dataManager = DataManager()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(appState)
                .environment(dataManager)
                .onAppear {
                    if dataManager.collections.isEmpty { dataManager.loadSampleData() }
                }
        }
    }
}
