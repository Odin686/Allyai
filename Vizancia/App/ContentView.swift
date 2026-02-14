import SwiftUI

struct ContentView: View {
    @Bindable var user: UserProfile
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(user: user)
                .tabItem {
                    Label("Learn", systemImage: "house.fill")
                }
                .tag(0)
            
            GamesHubView(user: user)
                .tabItem {
                    Label("Games", systemImage: "gamecontroller.fill")
                }
                .tag(1)
            
            ProgressDashboardView(user: user)
                .tabItem {
                    Label("Progress", systemImage: "chart.bar.fill")
                }
                .tag(2)
            
            ProfileView(user: user)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .tint(Color.aiPrimary)
        .onAppear {
            user.checkHeartRefill()
            StreakService.shared.updateStreak(for: user)
        }
    }
}
