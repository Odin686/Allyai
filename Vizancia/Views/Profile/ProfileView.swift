import SwiftUI

struct ProfileView: View {
    @Bindable var user: UserProfile
    @State private var showResetAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                // User Info
                Section {
                    HStack(spacing: 16) {
                        LevelBadge(level: user.currentLevel, size: 56)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.name.isEmpty ? "AI Learner" : user.name)
                                .font(.aiTitle())
                            let levelDef = LevelDefinition.all.first { $0.level == user.currentLevel }
                            Text(levelDef?.title ?? "AI Novice")
                                .font(.aiCaption())
                                .foregroundColor(.aiTextSecondary)
                        }
                    }
                    .listRowBackground(Color.aiCard)
                    .padding(.vertical, 4)
                }
                
                // Daily Goal
                Section("Daily Goal") {
                    Picker("XP Goal", selection: $user.dailyGoalTier) {
                        ForEach(DailyGoalTier.allCases, id: \.self) { tier in
                            Text("\(tier.rawValue.capitalized) (\(tier.xpTarget) XP)")
                                .tag(tier)
                        }
                    }
                    .onChange(of: user.dailyGoalTier) { _, new in
                        user.dailyXPGoal = new.xpTarget
                    }
                }
                .listRowBackground(Color.aiCard)
                
                // Settings
                Section("Settings") {
                    Toggle(isOn: $user.soundEnabled) {
                        Label("Sound Effects", systemImage: "speaker.wave.2.fill")
                    }
                    .onChange(of: user.soundEnabled) { _, new in
                        SoundService.shared.isEnabled = new
                    }
                    
                    Toggle(isOn: $user.hapticsEnabled) {
                        Label("Haptic Feedback", systemImage: "iphone.radiowaves.left.and.right")
                    }
                    .onChange(of: user.hapticsEnabled) { _, new in
                        HapticService.shared.isEnabled = new
                    }
                    
                    Toggle(isOn: $user.notificationsEnabled) {
                        Label("Notifications", systemImage: "bell.fill")
                    }
                    .onChange(of: user.notificationsEnabled) { _, new in
                        if new {
                            NotificationService.shared.requestPermission { _ in }
                        }
                    }
                }
                .listRowBackground(Color.aiCard)
                
                // Name
                Section("Profile") {
                    HStack {
                        Label("Name", systemImage: "person")
                        Spacer()
                        TextField("Your name", text: $user.name)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.aiTextSecondary)
                    }
                }
                .listRowBackground(Color.aiCard)
                
                // Hearts
                Section("Hearts") {
                    HStack {
                        Label("Current Hearts", systemImage: "heart.fill")
                            .foregroundColor(.aiError)
                        Spacer()
                        HeartsDisplay(hearts: user.hearts)
                    }
                    HStack {
                        Label("Streak Freezes", systemImage: "snowflake")
                        Spacer()
                        Text("\(user.streakFreezes)")
                            .foregroundColor(.aiTextSecondary)
                    }
                }
                .listRowBackground(Color.aiCard)
                
                // About
                Section("About") {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0").foregroundColor(.aiTextSecondary)
                    }
                    Link(destination: URL(string: "https://apple.com")!) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }
                }
                .listRowBackground(Color.aiCard)
                
                // Reset
                Section {
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        Label("Reset All Progress", systemImage: "arrow.counterclockwise")
                            .foregroundColor(.aiError)
                    }
                }
                .listRowBackground(Color.aiCard)
            }
            .scrollContentBackground(.hidden)
            .background(Color.aiBackground)
            .navigationTitle("Profile")
            .alert("Reset Progress?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    user.totalXP = 0
                    user.currentLevel = 1
                    user.currentStreak = 0
                    user.longestStreak = 0
                    user.hearts = 5
                    user.totalLessonsCompleted = 0
                    user.totalCorrectAnswers = 0
                    user.totalQuestionsAnswered = 0
                    user.gamesPlayed = 0
                    user.categoryProgressList = []
                    user.unlockedAchievementIds = []
                    user.gameHighScores = [:]
                    user.todayXP = 0
                    user.activeDays = []
                }
            } message: {
                Text("This will erase all your progress, XP, achievements, and stats. This cannot be undone.")
            }
        }
    }
}
