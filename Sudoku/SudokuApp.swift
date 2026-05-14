import SwiftUI

@main
struct SudokuApp: App {
    @StateObject private var progressStore = ProgressStore.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(progressStore)
        }
    }
}
