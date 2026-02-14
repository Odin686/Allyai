import SwiftUI

struct LaunchScreenView: View {
    @State private var isAnimating = false
    @State private var showTitle = false
    @State private var showSubtitle = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "#1a1a2e"), Color(hex: "#16213e")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Brain icon
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.aiPrimary.opacity(0.3), Color.clear],
                                center: .center,
                                startRadius: 30,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 80, weight: .thin))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.aiPrimary, .aiSecondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(isAnimating ? 1.0 : 0.5)
                        .opacity(isAnimating ? 1 : 0)
                }
                
                VStack(spacing: 8) {
                    Text("Vizancia")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(showTitle ? 1 : 0)
                        .offset(y: showTitle ? 0 : 20)
                    
                    Text("Learn AI the fun way")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .opacity(showSubtitle ? 1 : 0)
                        .offset(y: showSubtitle ? 0 : 10)
                }
            }
            
            // Neural network dots
            ForEach(0..<12) { i in
                Circle()
                    .fill(Color.aiSecondary.opacity(0.3))
                    .frame(width: CGFloat.random(in: 3...6))
                    .offset(
                        x: CGFloat.random(in: -160...160),
                        y: CGFloat.random(in: -300...300)
                    )
                    .scaleEffect(isAnimating ? 1 : 0)
                    .animation(.easeOut(duration: 0.8).delay(Double(i) * 0.08), value: isAnimating)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                isAnimating = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                showTitle = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.6)) {
                showSubtitle = true
            }
        }
    }
}
