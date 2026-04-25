import SwiftUI
import GameKit

struct CommunityView: View {
    @Bindable var user: UserProfile
    @State private var showLeaderboard = false
    @State private var showDuel = false
    @State private var showAllAchievements = false
    @State private var showShareSheet = false
    @StateObject private var gameKit = GameKitService.shared
    @StateObject private var duelService = DuelService.shared

    private var activeDuelCount: Int {
        duelService.activeMatches.filter { duelService.status(for: $0) == .yourTurn }.count
    }

    private var unlockedAchievements: [AchievementData] {
        AchievementData.all.filter { $0.condition(user) }
    }

    private var nextDuelAchievement: AchievementData? {
        AchievementData.all.first { ($0.id.hasPrefix("duel_streak") || $0.id == "first_blood") && !$0.condition(user) }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Achievement Showcase
                    achievementShowcase

                    // Learning Streaks Board
                    streaksBoard

                    // Duel Trophies Progress
                    duelTrophiesSection

                    // 1v1 Duels Section
                    duelsSection

                    // Leaderboard Section
                    leaderboardSection

                    // Invite Friends
                    inviteFriendsSection

                    // Game Center Status
                    gameCenterStatus

                    // Duel Stats
                    if user.totalDuelsPlayed > 0 {
                        duelStatsSection
                    }
                }
                .padding(.bottom, 30)
            }
            .background(Color.aiBackground.ignoresSafeArea())
            .navigationTitle("Community")
            .sheet(isPresented: $showLeaderboard) {
                LeaderboardView()
            }
            .fullScreenCover(isPresented: $showDuel) {
                DuelView(user: user)
            }
            .sheet(isPresented: $showAllAchievements) {
                allAchievementsSheet
            }
            .sheet(isPresented: $showShareSheet) {
                let text = "I'm learning AI with Vizancia! Challenge me to a duel 🧠⚔️"
                let url = URL(string: "https://vizancia.ca")!
                ActivityViewSheet(activityItems: [text, url])
                    .presentationDetents([.medium, .large])
            }
            .task {
                await duelService.loadActiveMatches()
            }
        }
    }

    // MARK: - Achievement Showcase
    private var achievementShowcase: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                sectionHeader(title: "Achievements", icon: "medal.fill", color: .aiWarning)
                Spacer()
                Button { showAllAchievements = true } label: {
                    Text("See All")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.aiPrimary)
                }
            }
            .padding(.horizontal)

            // Stats bar
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.aiWarning)
                    Text("\(unlockedAchievements.count)/\(AchievementData.all.count)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.aiTextPrimary)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.aiWarning.opacity(0.15))
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.aiWarning)
                            .frame(width: geo.size.width * (Double(unlockedAchievements.count) / Double(max(AchievementData.all.count, 1))))
                    }
                }
                .frame(height: 6)
            }
            .padding(.horizontal)

            // Recent achievements (horizontal scroll)
            if !unlockedAchievements.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(unlockedAchievements.suffix(6).reversed(), id: \.id) { achievement in
                            achievementBadge(achievement, unlocked: true)
                        }
                        // Show next locked ones as preview
                        ForEach(AchievementData.all.filter { !$0.condition(user) }.prefix(3), id: \.id) { achievement in
                            achievementBadge(achievement, unlocked: false)
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                // No achievements yet — show first 4 locked
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(AchievementData.all.prefix(4), id: \.id) { achievement in
                            achievementBadge(achievement, unlocked: false)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    private func achievementBadge(_ achievement: AchievementData, unlocked: Bool) -> some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(unlocked ? Color.aiWarning.opacity(0.12) : Color.aiTextSecondary.opacity(0.08))
                    .frame(width: 60, height: 60)
                Text(achievement.icon)
                    .font(.system(size: 26))
                    .opacity(unlocked ? 1 : 0.3)
            }
            Text(achievement.name)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundColor(unlocked ? .aiTextPrimary : .aiTextSecondary.opacity(0.5))
                .lineLimit(1)
                .frame(width: 70)

            if !unlocked, let progressInfo = achievement.progressInfo {
                let progress = progressInfo(user)
                Text("\(progress.current)/\(progress.target)")
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundColor(.aiTextSecondary.opacity(0.5))
            }
        }
    }

    // MARK: - Learning Streaks Board (GitHub-style)
    private var streaksBoard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionHeader(title: "Your Activity", icon: "calendar", color: .aiSuccess)
                Spacer()
                if user.currentStreak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.aiOrange)
                        Text("\(user.currentStreak) day streak")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.aiOrange)
                    }
                }
            }
            .padding(.horizontal)

            // Grid of last 84 days (12 weeks)
            let days = last84Days()
            let activeDaysSet = Set(user.activeDays)

            VStack(spacing: 3) {
                // Day labels
                HStack(spacing: 0) {
                    ForEach(["M", "T", "W", "T", "F", "S", "S"], id: \.self) { day in
                        Text(day)
                            .font(.system(size: 8, weight: .medium, design: .rounded))
                            .foregroundColor(.aiTextSecondary.opacity(0.5))
                            .frame(maxWidth: .infinity)
                    }
                }

                // Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: 7), spacing: 3) {
                    ForEach(days, id: \.self) { day in
                        let dateStr = Self.dayFormatter.string(from: day)
                        let isActive = activeDaysSet.contains(dateStr)
                        let isToday = Calendar.current.isDateInToday(day)
                        let xp = user.dailyXPLog[dateStr] ?? 0

                        RoundedRectangle(cornerRadius: 2.5)
                            .fill(cellColor(isActive: isActive, xp: xp, isToday: isToday))
                            .frame(height: 14)
                            .overlay(
                                isToday ?
                                RoundedRectangle(cornerRadius: 2.5)
                                    .stroke(Color.aiPrimary, lineWidth: 1)
                                : nil
                            )
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.aiCard)
                    .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
            )
            .padding(.horizontal)

            // Legend
            HStack(spacing: 12) {
                Spacer()
                Text("Less")
                    .font(.system(size: 9, design: .rounded))
                    .foregroundColor(.aiTextSecondary.opacity(0.5))
                ForEach([0, 20, 50, 100], id: \.self) { xp in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(cellColor(isActive: xp > 0, xp: xp, isToday: false))
                        .frame(width: 10, height: 10)
                }
                Text("More")
                    .font(.system(size: 9, design: .rounded))
                    .foregroundColor(.aiTextSecondary.opacity(0.5))
            }
            .padding(.horizontal, 20)

            // Stats row
            HStack(spacing: 14) {
                streakStat(value: "\(user.currentStreak)", label: "Current", icon: "flame.fill", color: .aiOrange)
                streakStat(value: "\(user.longestStreak)", label: "Best", icon: "crown.fill", color: .aiWarning)
                streakStat(value: "\(user.activeDays.count)", label: "Active Days", icon: "calendar.badge.checkmark", color: .aiSuccess)
                streakStat(value: "\(user.totalLessonsCompleted)", label: "Lessons", icon: "book.fill", color: .aiPrimary)
            }
            .padding(.horizontal)
        }
    }

    private func streakStat(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.aiTextPrimary)
            Text(label)
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundColor(.aiTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.aiCard)
                .shadow(color: .black.opacity(0.02), radius: 2, y: 1)
        )
    }

    private func cellColor(isActive: Bool, xp: Int, isToday: Bool) -> Color {
        if !isActive { return Color.aiSuccess.opacity(0.06) }
        if xp >= 100 { return Color.aiSuccess.opacity(0.9) }
        if xp >= 50 { return Color.aiSuccess.opacity(0.6) }
        if xp >= 20 { return Color.aiSuccess.opacity(0.35) }
        return Color.aiSuccess.opacity(0.2)
    }

    private func last84Days() -> [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        // Find the Monday of 12 weeks ago
        let weekday = calendar.component(.weekday, from: today)
        let daysToMonday = (weekday + 5) % 7
        guard let startOfWeek = calendar.date(byAdding: .day, value: -daysToMonday, to: today),
              let startDate = calendar.date(byAdding: .weekOfYear, value: -11, to: startOfWeek) else {
            return []
        }
        return (0..<84).compactMap { calendar.date(byAdding: .day, value: $0, to: startDate) }
    }

    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    // MARK: - Duel Trophies
    private var duelTrophiesSection: some View {
        let duelAchievements = AchievementData.all.filter {
            $0.id.hasPrefix("duel_streak") || $0.id == "first_blood"
        }

        return VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Duel Trophies", icon: "trophy.fill", color: .aiWarning)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(duelAchievements, id: \.id) { achievement in
                        let unlocked = achievement.condition(user)
                        let progress = achievement.progressInfo?(user)

                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(unlocked ? Color.aiWarning.opacity(0.15) : Color.aiTextSecondary.opacity(0.06))
                                    .frame(width: 56, height: 56)

                                if unlocked {
                                    Text(achievement.icon)
                                        .font(.system(size: 24))
                                } else {
                                    // Progress ring
                                    Circle()
                                        .stroke(Color.aiTextSecondary.opacity(0.1), lineWidth: 3)
                                        .frame(width: 44, height: 44)
                                    Circle()
                                        .trim(from: 0, to: CGFloat(progress?.current ?? 0) / CGFloat(max(progress?.target ?? 1, 1)))
                                        .stroke(Color.aiWarning.opacity(0.4), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                        .frame(width: 44, height: 44)
                                        .rotationEffect(.degrees(-90))
                                    Text(achievement.icon)
                                        .font(.system(size: 18))
                                        .opacity(0.3)
                                }
                            }
                            Text(achievement.name)
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundColor(unlocked ? .aiTextPrimary : .aiTextSecondary.opacity(0.5))
                                .lineLimit(1)

                            if let progress, !unlocked {
                                Text("\(progress.current)/\(progress.target)")
                                    .font(.system(size: 9, weight: .medium, design: .rounded))
                                    .foregroundColor(.aiTextSecondary.opacity(0.4))
                            } else if unlocked {
                                Text("Unlocked!")
                                    .font(.system(size: 9, weight: .bold, design: .rounded))
                                    .foregroundColor(.aiWarning)
                            }
                        }
                        .frame(width: 76)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Duels Section
    private var duelsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                sectionHeader(title: "1v1 Duels", icon: "person.2.fill", color: .aiPrimary)
                Spacer()
                if activeDuelCount > 0 {
                    Text("\(activeDuelCount) waiting")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.aiError))
                }
            }
            .padding(.horizontal)

            Button { showDuel = true } label: {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.aiPrimary, Color.aiGradientEnd],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ).opacity(0.2)
                            )
                            .frame(width: 56, height: 56)
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.aiPrimary)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Challenge a Player")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.aiTextPrimary)
                        Text("10 questions head-to-head — who knows AI better?")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.aiTextSecondary)
                            .lineLimit(2)
                    }
                    Spacer()
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.aiPrimary)
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.aiCard)
                        .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.aiPrimary.opacity(0.15), lineWidth: 1)
                )
            }
            .padding(.horizontal)

            ForEach(duelService.activeMatches.prefix(3), id: \.matchID) { match in
                activeDuelRow(match: match)
            }

            if duelService.activeMatches.count > 3 {
                Button { showDuel = true } label: {
                    Text("View all \(duelService.activeMatches.count) duels →")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.aiPrimary)
                }
                .padding(.horizontal)
            }
        }
    }

    private func activeDuelRow(match: GKTurnBasedMatch) -> some View {
        let status = duelService.status(for: match)
        let opponent = match.participants.first { $0.player != GKLocalPlayer.local }

        return HStack(spacing: 12) {
            Circle()
                .fill(statusColor(status).opacity(0.15))
                .frame(width: 8, height: 8)

            Text("vs \(opponent?.player?.displayName ?? "Opponent")")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.aiTextPrimary)

            Spacer()

            Text(statusLabel(status))
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(statusColor(status))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.aiCard)
        )
        .padding(.horizontal)
    }

    // MARK: - Leaderboard Section
    private var leaderboardSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Leaderboard", icon: "trophy.fill", color: .aiWarning)
                .padding(.horizontal)

            Button { showLeaderboard = true } label: {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.aiWarning.opacity(0.12))
                            .frame(width: 52, height: 52)
                        Image(systemName: "trophy.fill")
                            .font(.title2)
                            .foregroundColor(.aiWarning)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("View Leaderboard")
                            .font(.aiHeadline())
                            .foregroundColor(.aiTextPrimary)
                        Text("See how you rank against other learners")
                            .font(.aiCaption())
                            .foregroundColor(.aiTextSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.aiTextSecondary)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.aiCard)
                        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
                )
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Invite Friends
    private var inviteFriendsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Invite Friends", icon: "paperplane.fill", color: .aiSecondary)
                .padding(.horizontal)

            Button {
                showShareSheet = true
            } label: {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [Color.aiSecondary, Color.aiPrimary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ).opacity(0.15)
                            )
                            .frame(width: 52, height: 52)
                        Image(systemName: "person.badge.plus")
                            .font(.title2)
                            .foregroundColor(.aiSecondary)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Challenge Your Friends")
                            .font(.aiHeadline())
                            .foregroundColor(.aiTextPrimary)
                        Text("Share Vizancia and duel your friends!")
                            .font(.aiCaption())
                            .foregroundColor(.aiTextSecondary)
                    }
                    Spacer()
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16))
                        .foregroundColor(.aiSecondary)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.aiCard)
                        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.aiSecondary.opacity(0.12), lineWidth: 1)
                )
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Game Center Status
    private var gameCenterStatus: some View {
        Group {
            if gameKit.isAuthenticated {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.aiSuccess.opacity(0.12))
                            .frame(width: 36, height: 36)
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.aiSuccess)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Connected to Game Center")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.aiTextPrimary)
                        Text(gameKit.localPlayerName)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.aiTextSecondary)
                    }
                    Spacer()
                    Button {
                        gameKit.showGameCenterDashboard()
                    } label: {
                        Text("Dashboard")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.aiPrimary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Color.aiPrimary.opacity(0.1)))
                    }
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.aiCard)
                        .shadow(color: .black.opacity(0.03), radius: 3, y: 2)
                )
                .padding(.horizontal)
            } else {
                HStack(spacing: 10) {
                    Image(systemName: "gamecontroller")
                        .font(.system(size: 18))
                        .foregroundColor(.aiTextSecondary.opacity(0.5))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Game Center Not Connected")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.aiTextSecondary)
                        Text("Sign in via Settings to compete")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.aiTextSecondary.opacity(0.6))
                    }
                    Spacer()
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.aiCard)
                )
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Duel Stats
    private var duelStatsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Your Record", icon: "chart.bar.fill", color: .aiSecondary)
                .padding(.horizontal)

            HStack(spacing: 10) {
                statBox(value: "\(user.duelWins)", label: "Wins", icon: "trophy.fill", color: .aiWarning)
                statBox(value: "\(user.duelLosses)", label: "Losses", icon: "arrow.down.circle", color: .aiError)
                statBox(value: "\(user.duelTies)", label: "Ties", icon: "equal.circle.fill", color: .aiSecondary)
                statBox(
                    value: user.totalDuelsPlayed > 0 ? "\(Int(Double(user.duelWins) / Double(user.totalDuelsPlayed) * 100))%" : "—",
                    label: "Win Rate",
                    icon: "percent",
                    color: .aiPrimary
                )
            }
            .padding(.horizontal)
        }
    }

    private func statBox(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.aiTextPrimary)
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.aiTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.aiCard)
                .shadow(color: .black.opacity(0.03), radius: 3, y: 2)
        )
    }

    // MARK: - All Achievements Sheet
    private var allAchievementsSheet: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    // Summary
                    HStack(spacing: 16) {
                        VStack(spacing: 2) {
                            Text("\(unlockedAchievements.count)")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.aiWarning)
                            Text("Unlocked")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.aiTextSecondary)
                        }
                        VStack(spacing: 2) {
                            Text("\(AchievementData.all.count - unlockedAchievements.count)")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.aiTextSecondary)
                            Text("Locked")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.aiTextSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)

                    ForEach(AchievementData.all, id: \.id) { achievement in
                        let unlocked = achievement.condition(user)
                        let progress = achievement.progressInfo?(user)

                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(unlocked ? Color.aiWarning.opacity(0.12) : Color.aiTextSecondary.opacity(0.06))
                                    .frame(width: 48, height: 48)
                                Text(achievement.icon)
                                    .font(.system(size: 22))
                                    .opacity(unlocked ? 1 : 0.25)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(achievement.name)
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundColor(unlocked ? .aiTextPrimary : .aiTextSecondary)
                                    if unlocked {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(.aiSuccess)
                                    }
                                }
                                Text(achievement.description)
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundColor(.aiTextSecondary)

                                if let progress, !unlocked {
                                    GeometryReader { geo in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(Color.aiWarning.opacity(0.1))
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(Color.aiWarning.opacity(0.5))
                                                .frame(width: geo.size.width * (Double(progress.current) / Double(max(progress.target, 1))))
                                        }
                                    }
                                    .frame(height: 4)
                                }
                            }
                            Spacer()
                            if let progress {
                                Text("\(progress.current)/\(progress.target)")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(unlocked ? .aiWarning : .aiTextSecondary.opacity(0.5))
                            }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.aiCard)
                                .shadow(color: .black.opacity(0.02), radius: 2, y: 1)
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .background(Color.aiBackground.ignoresSafeArea())
            .navigationTitle("All Achievements")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Helpers

    private func sectionHeader(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.aiTextSecondary)
                .textCase(.uppercase)
        }
    }

    private func statusColor(_ status: DuelStatus) -> Color {
        switch status {
        case .yourTurn: return .aiPrimary
        case .waitingForOpponent, .waitingForResult: return .aiOrange
        case .completed: return .aiSuccess
        case .expired: return .aiTextSecondary
        }
    }

    private func statusLabel(_ status: DuelStatus) -> String {
        switch status {
        case .yourTurn: return "Your Turn"
        case .waitingForOpponent: return "Waiting..."
        case .waitingForResult: return "Waiting..."
        case .completed: return "Complete"
        case .expired: return "Expired"
        }
    }
}
