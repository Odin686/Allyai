import SwiftUI
import SwiftData

@main
struct VizanciaApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: UserProfile.self)
    }
}

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [UserProfile]
    @State private var showLaunchScreen = true
    
    var body: some View {
        ZStack {
            Group {
                if let user = users.first {
                    if user.onboardingCompleted {
                        ContentView(user: user)
                    } else {
                        OnboardingView(user: user)
                    }
                } else {
                    Color.clear.onAppear { createUser() }
                }
            }
            
            if showLaunchScreen {
                LaunchScreenView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showLaunchScreen = false
                }
            }
        }
    }
    
    private func createUser() {
        let user = UserProfile()
        modelContext.insert(user)
        try? modelContext.save()
    }
}
