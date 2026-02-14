import SwiftUI

extension Color {
    // Brand Colors (same in light and dark)
    static let aiPrimary = Color(hex: "#6C5CE7")
    static let aiSecondary = Color(hex: "#00CEC9")
    static let aiSuccess = Color(hex: "#00B894")
    static let aiError = Color(hex: "#FF6B6B")
    static let aiWarning = Color(hex: "#FDCB6E")
    static let aiOrange = Color(hex: "#E17055")
    
    // Adaptive Colors (light/dark mode)
    static let aiBackground = Color("AIBackground")
    static let aiCard = Color("AICard")
    static let aiTextPrimary = Color("AITextPrimary")
    static let aiTextSecondary = Color("AITextSecondary")
    
    // Legacy aliases
    static let aiCardBg = aiCard
    static let aiDarkText = aiTextPrimary
    static let aiLightText = aiTextSecondary
    
    // Category Colors
    static let aiBlue = Color(hex: "#0984E3")
    static let aiPurple = Color(hex: "#6C5CE7")
    static let aiPink = Color(hex: "#E84393")
    static let aiRed = Color(hex: "#D63031")
    static let aiGreen = Color(hex: "#00B894")
    static let aiTeal = Color(hex: "#00CEC9")
    static let aiIndigo = Color(hex: "#5758BB")
    static let aiBrown = Color(hex: "#A0522D")
    static let aiCyan = Color(hex: "#00B4D8")
    
    // Gradient
    static let aiGradientStart = Color(hex: "#6C5CE7")
    static let aiGradientEnd = Color(hex: "#00CEC9")
    
    static var aiPrimaryGradient: LinearGradient {
        LinearGradient(
            colors: [.aiGradientStart, .aiGradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
