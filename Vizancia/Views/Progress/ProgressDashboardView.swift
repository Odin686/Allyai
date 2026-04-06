import SwiftUI

struct ProgressDashboardView: View {
    @Bindable var user: UserProfile
    @State private var showSettings = false
    @State private var showGlossary = false

    private let provider = LessonContentProvider.shared

    private var completedCategories: Int { user.categoryProgressList.filter(\.isComplete).count }
    private var totalLessonsAvail: Int { provider.allCategories.flatMap(\.lessons).count }
    private var overallAccuracy: Int {
        user.totalQuestionsAnswered > 0 ? (user.totalCorrectAnswers * 100) / user.totalQuestionsAnswered : 0
    }

    private var displayName: String {
        if !user.userName.isEmpty { return user.userName }
        if !user.name.isEmpty && user.name != "Learner" { return user.name }
        return "AI Learner"
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Profile Header
                    profileHeader

                    // Stats
                    statsGrid

                    // Achievements
                    achievementsSection

                    // Glossary
                    glossaryCard

                    // Activity
                    streakCalendar
                }
                .padding(.bottom, 30)
            }
            .background(Color.aiBackground.ignoresSafeArea())
            .navigationTitle("Progress")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.aiTextSecondary)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsSheet(user: user)
            }
            .sheet(isPresented: $showGlossary) {
                GlossaryView()
            }
        }
    }

    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 12) {
            LevelBadge(level: user.currentLevel, size: 64)
            Text(displayName)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.aiTextPrimary)
            let levelDef = LevelDefinition.all.first { $0.level == user.currentLevel }
            Text(levelDef?.title ?? "AI Novice")
                .font(.aiCaption())
                .foregroundColor(.aiTextSecondary)
            XPProgressBar(currentXP: user.totalXP, progress: user.levelProgress, level: user.currentLevel)
                .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Stats
    private var statsGrid: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                miniStat(value: formatNumber(user.totalXP), label: "Total XP", icon: "star.fill", color: .aiPrimary)
                miniStat(value: "\(user.currentStreak)", label: "Day Streak", icon: "flame.fill", color: .aiOrange)
            }
            HStack(spacing: 12) {
                miniStat(value: "\(user.totalLessonsCompleted)/\(totalLessonsAvail)", label: "Lessons", icon: "book.fill", color: .aiSuccess)
                miniStat(value: "\(overallAccuracy)%", label: "Accuracy", icon: "target", color: .aiSecondary)
            }
            HStack(spacing: 12) {
                miniStat(value: "\(completedCategories)/\(provider.allCategories.count)", label: "Categories", icon: "folder.fill", color: .aiWarning)
                miniStat(value: "\(user.gamesPlayed)", label: "Games Played", icon: "gamecontroller.fill", color: .aiError)
            }
        }
        .padding(.horizontal)
    }

    private func miniStat(value: String, label: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 32, height: 32)
                .background(Circle().fill(color.opacity(0.12)))
            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.aiTextPrimary)
                Text(label)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.aiTextSecondary)
            }
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.aiCard)
                .shadow(color: .black.opacity(0.03), radius: 3, y: 2)
        )
    }

    // MARK: - Achievements
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Achievements")
                    .font(.aiTitle())
                Text("\(user.unlockedAchievementIds.count)/\(AchievementData.all.count)")
                    .font(.aiCaption())
                    .foregroundColor(.aiTextSecondary)
                Spacer()
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(AchievementData.all) { achievement in
                        let unlocked = user.unlockedAchievementIds.contains(achievement.id)
                        let progress = achievement.progressInfo?(user)
                        VStack(spacing: 4) {
                            Text(achievement.icon)
                                .font(.system(size: 28))
                                .grayscale(unlocked ? 0 : 1)
                                .opacity(unlocked ? 1 : 0.4)
                            Text(achievement.name)
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundColor(unlocked ? .aiTextPrimary : .aiTextSecondary)
                                .lineLimit(1)
                            if !unlocked, let p = progress, p.target > 0 {
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color.aiPrimary.opacity(0.12))
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color.aiPrimary.opacity(0.5))
                                            .frame(width: geo.size.width * min(Double(p.current) / Double(p.target), 1.0))
                                    }
                                }
                                .frame(height: 4)
                                .padding(.horizontal, 6)
                                Text("\(p.current)/\(p.target)")
                                    .font(.system(size: 9, weight: .medium, design: .rounded))
                                    .foregroundColor(.aiTextSecondary)
                            } else if unlocked {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.aiSuccess)
                            }
                        }
                        .frame(width: 80, height: 100)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(unlocked ? Color.aiPrimary.opacity(0.08) : Color.aiCard)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(unlocked ? Color.aiPrimary.opacity(0.3) : Color.clear, lineWidth: 1)
                                )
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Glossary Card
    private var glossaryCard: some View {
        Button { showGlossary = true } label: {
            HStack(spacing: 14) {
                Image(systemName: "character.book.closed.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.aiPrimary)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.aiPrimary.opacity(0.12)))
                VStack(alignment: .leading, spacing: 2) {
                    Text("AI Glossary")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.aiTextPrimary)
                    Text("\(GlossaryData.entries.count) key AI terms and definitions")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.aiTextSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.aiTextSecondary.opacity(0.5))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.aiCard)
                    .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }

    // MARK: - Streak Calendar
    private var streakCalendar: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity")
                .font(.aiTitle())
                .padding(.horizontal)

            let days = Date().last90Days()
            let columns = Array(repeating: GridItem(.flexible(), spacing: 3), count: 7)

            LazyVGrid(columns: columns, spacing: 3) {
                ForEach(days, id: \.self) { day in
                    let active = user.activeDays.contains(day.formatted(.dateTime.year().month().day()))
                    RoundedRectangle(cornerRadius: 3)
                        .fill(active ? Color.aiSuccess : Color.aiSuccess.opacity(0.1))
                        .frame(height: 14)
                }
            }
            .padding(.horizontal)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.aiCard)
                .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
        )
        .padding(.horizontal)
    }

    private func formatNumber(_ n: Int) -> String {
        if n >= 1000 { return String(format: "%.1fk", Double(n) / 1000.0) }
        return "\(n)"
    }
}

// MARK: - Settings Sheet
struct SettingsSheet: View {
    @Bindable var user: UserProfile
    @Environment(\.dismiss) private var dismiss
    @State private var showResetAlert = false

    var body: some View {
        NavigationStack {
            List {
                Section("Profile") {
                    HStack {
                        Label("Name", systemImage: "person")
                        Spacer()
                        TextField("Your name", text: $user.userName)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.aiTextSecondary)
                            .onChange(of: user.userName) { _, newValue in
                                user.name = newValue
                            }
                    }
                }
                .listRowBackground(Color.aiCard)

                Section("Daily Goal") {
                    Picker("XP Goal", selection: $user.dailyGoalTier) {
                        ForEach(DailyGoalTier.allCases, id: \.self) { tier in
                            Text("\(tier.rawValue.capitalized) (\(tier.xpTarget) XP)").tag(tier)
                        }
                    }
                    .onChange(of: user.dailyGoalTier) { _, new in
                        user.dailyXPGoal = new.xpTarget
                    }
                }
                .listRowBackground(Color.aiCard)

                Section("Preferences") {
                    Toggle(isOn: $user.soundEnabled) {
                        Label("Sounds", systemImage: "speaker.wave.2.fill")
                    }
                    .onChange(of: user.soundEnabled) { _, new in
                        SoundService.shared.isEnabled = new
                    }
                    Toggle(isOn: $user.hapticsEnabled) {
                        Label("Haptics", systemImage: "iphone.radiowaves.left.and.right")
                    }
                    .onChange(of: user.hapticsEnabled) { _, new in
                        HapticService.shared.isEnabled = new
                    }
                    Toggle(isOn: $user.notificationsEnabled) {
                        Label("Notifications", systemImage: "bell.fill")
                    }
                    .onChange(of: user.notificationsEnabled) { _, new in
                        if new { NotificationService.shared.requestPermission { _ in } }
                    }
                }
                .listRowBackground(Color.aiCard)

                Section("About") {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "2.0")
                            .foregroundColor(.aiTextSecondary)
                    }
                    if let url = URL(string: "https://odin686.github.io/Vizancia/privacy-policy.html") {
                        Link(destination: url) {
                            Label("Privacy Policy", systemImage: "hand.raised.fill")
                        }
                    }
                    if let url = URL(string: "https://odin686.github.io/Vizancia/terms-of-service.html") {
                        Link(destination: url) {
                            Label("Terms of Service", systemImage: "doc.text.fill")
                        }
                    }
                    Button {
                        if let url = URL(string: "mailto:info@vizancia.ca") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label("Contact Support", systemImage: "envelope.fill")
                    }
                }
                .listRowBackground(Color.aiCard)

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
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
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
                    user.missedQuestionIds = []
                }
            } message: {
                Text("This will erase all your progress, XP, achievements, and stats. This cannot be undone.")
            }
        }
    }
}
