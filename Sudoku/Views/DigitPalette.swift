import SwiftUI

enum DigitPalette {
    static func color(for number: Int) -> Color {
        switch number {
        case 1: return Color(red: 91 / 255, green: 188 / 255, blue: 216 / 255)
        case 2: return Color(red: 199 / 255, green: 82 / 255, blue: 119 / 255)
        case 3: return Color(red: 246 / 255, green: 199 / 255, blue: 208 / 255)
        case 4: return Color(red: 233 / 255, green: 193 / 255, blue: 217 / 255)
        case 5: return Color(red: 0 / 255, green: 101 / 255, blue: 171 / 255)
        case 6: return Color(red: 126 / 255, green: 86 / 255, blue: 149 / 255)
        case 7: return Color(red: 226 / 255, green: 105 / 255, blue: 19 / 255)
        case 8: return Color(red: 241 / 255, green: 163 / 255, blue: 0 / 255)
        case 9: return Color(red: 20 / 255, green: 18 / 255, blue: 19 / 255)
        default: return .blue
        }
    }
}
