import SwiftUI

enum CloudTheme {
    // MARK: - Colors

    static let primaryBlue = Color(red: 0.31, green: 0.76, blue: 0.97)       // #4FC3F7
    static let accentBlue = Color(red: 0.01, green: 0.53, blue: 0.82)        // #0288D1
    static let deepBlue = Color(red: 0.10, green: 0.14, blue: 0.49)          // #1A237E
    static let inkDark = Color(red: 0.07, green: 0.09, blue: 0.15)           // #121826 near-black
    static let skyBackground = Color(red: 0.88, green: 0.94, blue: 1.0)      // #E0F0FF
    static let cloudWhite = Color(red: 0.97, green: 0.98, blue: 1.0)         // #F8FAFF
    static let surfaceBlue = Color(red: 0.93, green: 0.96, blue: 1.0)        // #EDF5FF
    static let borderBlue = Color(red: 0.78, green: 0.88, blue: 0.97)        // #C7E1F7
    static let mutedText = Color(red: 0.30, green: 0.36, blue: 0.46)         // #4D5C75
    static let checkGreen = Color(red: 0.30, green: 0.78, blue: 0.55)        // #4DC78C
    static let dangerRed = Color(red: 0.93, green: 0.36, blue: 0.36)         // #ED5C5C

    // MARK: - Text Colors

    static let textPrimary = inkDark
    static let textSecondary = mutedText
    static let textOnAccent = Color.white

    // MARK: - Gradient

    static let gradient = LinearGradient(
        colors: [primaryBlue, accentBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let subtleGradient = LinearGradient(
        colors: [skyBackground, cloudWhite],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Dimensions

    static let panelWidth: CGFloat = 700
    static let panelHeight: CGFloat = 400
    static let cornerRadius: CGFloat = 16
    static let smallCorner: CGFloat = 10
    static let spacing: CGFloat = 12
    static let padding: CGFloat = 16

    // MARK: - Shadows

    static let panelShadow = Color.black.opacity(0.15)
    static let cardShadow = Color(red: 0.31, green: 0.76, blue: 0.97).opacity(0.15)

    // MARK: - Animation

    static let springAnimation = Animation.spring(response: 0.35, dampingFraction: 0.82)
    static let quickAnimation = Animation.easeOut(duration: 0.2)
}

// MARK: - View Modifiers

struct CloudCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(CloudTheme.cloudWhite)
            .clipShape(RoundedRectangle(cornerRadius: CloudTheme.smallCorner))
            .shadow(color: CloudTheme.cardShadow, radius: 4, x: 0, y: 2)
    }
}

extension View {
    func cloudCard() -> some View {
        modifier(CloudCardModifier())
    }
}
