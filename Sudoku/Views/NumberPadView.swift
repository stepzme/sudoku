import SwiftUI

struct NumberPadView: View {
    let onTap: (Int) -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...9, id: \.self) { number in
                Button {
                    onTap(number)
                } label: {
                    Text("\(number)")
                        .font(.title3.bold().monospacedDigit())
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
                }
            }
        }
    }
}
