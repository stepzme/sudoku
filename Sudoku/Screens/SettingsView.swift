import SwiftUI

struct SettingsView: View {
    @AppStorage("highlightPeers") private var highlightPeers = true
    @AppStorage("autoRemoveNotes") private var autoRemoveNotes = true
    @AppStorage("haptics") private var haptics = true

    var body: some View {
        Form {
            Section("Gameplay") {
                Toggle("Highlight related cells", isOn: $highlightPeers)
                Toggle("Auto-remove notes", isOn: $autoRemoveNotes)
                Toggle("Haptics", isOn: $haptics)
            }

            Section("About") {
                LabeledContent("Levels", value: "300")
                LabeledContent("Difficulties", value: "Easy, Medium, Hard")
            }
        }
        .navigationTitle("Settings")
    }
}
