import SwiftUI

struct NumberPadView: View {
    private let spacing: CGFloat = 10
    let isNotesMode: Bool
    let remainingCount: (Int) -> Int
    let isDisabled: (Int) -> Bool
    let onTap: (Int) -> Void

    var body: some View {
        GeometryReader { geometry in
            let buttonWidth = max(0, (geometry.size.width - (spacing * 2)) / 3)
            let buttonHeight = max(0, (geometry.size.height - (spacing * 2)) / 3)

            VStack(spacing: spacing) {
                ForEach(0..<3, id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(0..<3, id: \.self) { column in
                            let number = (row * 3) + column + 1
                            let disabled = isDisabled(number)
                            Button {
                                onTap(number)
                            } label: {
                                ZStack(alignment: .topTrailing) {
                                    Image("Digit\(number)")
                                        .resizable()
                                        .interpolation(.high)
                                        .scaledToFit()
                                        .frame(width: buttonWidth * 0.56, height: buttonHeight * 0.56)
                                        .frame(width: buttonWidth, height: buttonHeight)
                                        .background(backgroundFill(for: number), in: RoundedRectangle(cornerRadius: 18))
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 18)
                                                .stroke(borderColor(for: number), lineWidth: isNotesMode ? 2 : 0)
                                        }
                                        .saturation(disabled ? 0 : 1)
                                        .opacity(disabled ? 0.4 : 1)

                                    Text("\(remainingCount(number))")
                                        .font(.caption2.bold().monospacedDigit())
                                        .foregroundStyle(disabled ? .secondary : .primary)
                                        .padding(.top, 8)
                                        .padding(.trailing, 8)
                                }
                            }
                            .buttonStyle(.plain)
                            .disabled(disabled)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func backgroundFill(for number: Int) -> Color {
        isNotesMode ? .clear : DigitPalette.color(for: number).opacity(0.5)
    }

    private func borderColor(for number: Int) -> Color {
        isNotesMode ? DigitPalette.color(for: number) : .clear
    }
}
