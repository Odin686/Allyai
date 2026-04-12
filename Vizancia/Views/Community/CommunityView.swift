import SwiftUI
import GameKit

struct CommunityView: View {
    @Bindable var user: UserProfile
    @State private var showLeaderboard = false
    @State private var showDuel = false
    @StateObject private var gameKit = GameKitService.shared
    @StateObject private var duelService = DuelService.shared

    private var activeDuelCount: Int {
        duelService.activeMatches.filter { duelService.status(for: $0) == .yourTurn }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Game Center Status
                    gameCenterStatus

                    // 1v1 Duels Section
                    duelsSection

                    // Leaderboard Section
                    leaderboardSection

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
            .task {
                await duelService.loadActiveMatches()
            }
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
                            .background(
                                Capsule()
                                    .fill(Color.aiPrimary.opacity(0.1))
                            )
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

            // Start Duel Hero Card
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

            // Active duels preview
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
