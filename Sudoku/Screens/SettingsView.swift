import SwiftUI

struct SettingsView: View {
    @AppStorage("highlightPeers") private var highlightPeers = true
    @AppStorage("autoRemoveNotes") private var autoRemoveNotes = true
    @AppStorage("haptics") private var haptics = true

    var body: some View {
        Form {
            Section("Игра") {
                Toggle("Подсвечивать связанные клетки", isOn: $highlightPeers)
                Toggle("Автоматически удалять заметки", isOn: $autoRemoveNotes)
                Toggle("Тактильный отклик", isOn: $haptics)
            }

            Section("О приложении") {
                LabeledContent("Уровней", value: "\(LevelCatalog.totalLevels)")
                LabeledContent("Сложности", value: "Легко, Средне, Сложно")
            }
        }
        .navigationTitle("Настройки")
    }
}
