import SwiftUI

// MARK: - Card Modifier
struct CardModifier: ViewModifier {
    var cornerRadius: CGFloat = 16
    var shadowRadius: CGFloat = 8
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.08), radius: shadowRadius, x: 0, y: 4)
            )
    }
}

// MARK: - Shake Modifier
struct ShakeModifier: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit: CGFloat = 3
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * shakesPerUnit), y: 0))
    }
}

// MARK: - Floating Text Modifier
struct FloatingTextModifier: ViewModifier {
    let text: String
    @Binding var isShowing: Bool
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1
    
    func body(content: Content) -> some View {
        content.overlay(
            Group {
                if isShowing {
                    Text(text)
                        .font(.aiXP())
                        .foregroundStyle(Color.aiPrimary)
                        .offset(y: offset)
                        .opacity(opacity)
                        .onAppear {
                            withAnimation(.easeOut(duration: 1.2)) {
                                offset = -60
                                opacity = 0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                isShowing = false
                                offset = 0
                                opacity = 1
                            }
                        }
                }
            }
        )
    }
}

// MARK: - Glow Modifier
struct GlowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.6), radius: radius)
            .shadow(color: color.opacity(0.3), radius: radius * 2)
    }
}

// MARK: - Pulse Modifier
struct PulseModifier: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isPulsing)
            .onAppear { isPulsing = true }
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle(cornerRadius: CGFloat = 16, shadowRadius: CGFloat = 8) -> some View {
        modifier(CardModifier(cornerRadius: cornerRadius, shadowRadius: shadowRadius))
    }
    
    func shake(attempts: CGFloat) -> some View {
        modifier(ShakeModifier(animatableData: attempts))
    }
    
    func floatingText(_ text: String, isShowing: Binding<Bool>) -> some View {
        modifier(FloatingTextModifier(text: text, isShowing: isShowing))
    }
    
    func glow(color: Color = .aiPrimary, radius: CGFloat = 10) -> some View {
        modifier(GlowModifier(color: color, radius: radius))
    }
    
    func pulse() -> some View {
        modifier(PulseModifier())
    }
    
    func glassMorphism(cornerRadius: CGFloat = 20) -> some View {
        self.background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}
