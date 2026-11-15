import SwiftUI
import Observation
import Foundation

@main
struct MyApp: App {
    @State private var appState = AppState()
    @State private var dataManager = DataManager()
    @State private var isShowingLaunchScreen = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                RootTabView()
                    .environment(appState)
                    .environment(dataManager)

                if isShowingLaunchScreen {
                    MindPalaceLaunchView {
                        isShowingLaunchScreen = false
                    }
                    .transition(.opacity.combined(with: .scale(scale: 1.04)))
                    .zIndex(1)
                }
            }
            .onAppear {
                dataManager.loadData()
            }
        }
    }
}
