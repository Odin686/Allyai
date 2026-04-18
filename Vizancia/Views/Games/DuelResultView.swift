import SwiftUI

// MARK: - Duel Result View
struct DuelResultView: View {
    @Bindable var user: UserProfile
    let duelData: DuelMatchData
    let localPlayerId: String
    var opponentName: String? = nil
    @Environment(\.dismiss) private var dismiss
    @State private var animateResult = false
    @State private var showConfetti = false

    private var isPlayer1: Bool { localPlayerId == duelData.player1Id }
    private var myScore: Int { isPlayer1 ? (duelData.player1Score ?? 0) : (duelData.player2Score ?? 0) }
    private var opponentScore: Int { isPlayer1 ? (duelData.player2Score ?? 0) : (duelData.player1Score ?? 0) }
    private var totalQuestions: Int { duelData.questionIds.count }
    private var isWinner: Bool { duelData.winnerId == localPlayerId }
    private var isTie: Bool { duelData.isTie }
    private var isPerfect: Bool { myScore == totalQuestions }
    private var isBot: Bool { duelData.player2Id?.hasPrefix("bot_") == true }

    private var resultTitle: String {
        if isTie { return "It's a Tie!" }
        if isWinner { return "You Won! 🎉" }
        return "You Lost"
    }

    private var resultEmoji: String {
        if isTie { return "🤝" }
        if isWinner { return "👑" }
        return "💪"
    }

    private var resultColor: Color {
        if isTie { return .aiSecondary }
        if isWinner { return .aiWarning }
        return .aiTextSecondary
    }

    private var xpEarned: Int {
        DuelService.shared.xpReward(
            for: duelData,
            isWinner: isTie ? nil : isWinner,
            isPerfect: isPerfect
        )
    }

    var body: some View {
        ZStack {
            Color.aiBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    Spacer(minLength: 40)

                    // Result Header
                    VStack(spacing: 12) {
                        Text(resultEmoji)
                            .font(.system(size: 64))
                            .scaleEffect(animateResult ? 1 : 0.3)
                            .animation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.2), value: animateResult)

                        Text(resultTitle)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(resultColor)

                        Text("Duel Complete")
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(.aiTextSecondary)
                    }

                    // Head-to-Head Comparison
                    HStack(spacing: 0) {
                        // Your score
                        VStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color.aiPrimary.opacity(0.12))
                                    .frame(width: 56, height: 56)
                                Text("You")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.aiPrimary)
                            }
                            Text("\(myScore)")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundColor(.aiPrimary)
                            Text("out of \(totalQuestions)")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.aiTextSecondary)
                            if isWinner {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.aiWarning)
                            }
                        }
                        .frame(maxWidth: .infinity)

                        // VS
                        VStack {
                            Text("VS")
                                .font(.system(size: 16, weight: .black, design: .rounded))
                                .foregroundColor(.aiTextSecondary.opacity(0.4))
                        }
                        .frame(width: 50)

                        // Opponent score
                        VStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color.aiOrange.opacity(0.12))
                                    .frame(width: 56, height: 56)
                                if isBot {
                                    Image(systemName: "cpu")
                                        .font(.system(size: 20))
                                        .foregroundColor(.aiOrange)
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.aiOrange)
                                }
                            }
                            Text(opponentName ?? "Opponent")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(.aiOrange)
                            Text("\(opponentScore)")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundColor(.aiOrange)
                            Text("out of \(totalQuestions)")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.aiTextSecondary)
                            if !isWinner && !isTie {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.aiWarning)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.aiCard)
                            .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
                    )
                    .padding(.horizontal)

                    // XP Earned
                    VStack(spacing: 6) {
                        Text("+\(xpEarned)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.aiPrimary)
                        Text("XP Earned")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.aiTextSecondary)
                        if isPerfect {
                            Text("Perfect Score Bonus! +\(DuelRewards.perfectBonusXP) XP")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(.aiWarning)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.aiPrimary.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.aiPrimary.opacity(0.15), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal)

                    // Stats
                    HStack(spacing: 14) {
                        duelStat(title: "Wins", value: "\(user.duelWins)", icon: "trophy.fill", color: .aiWarning)
                        duelStat(title: "Losses", value: "\(user.duelLosses)", icon: "arrow.down.circle", color: .aiError)
                        duelStat(title: "Ties", value: "\(user.duelTies)", icon: "equal.circle.fill", color: .aiSecondary)
                    }
                    .padding(.horizontal)

                    // Share (only on wins)
                    if isWinner {
                        ShareButton(
                            cardType: .duelWin(
                                opponentName: opponentName ?? "Opponent",
                                myScore: myScore,
                                theirScore: opponentScore
                            ),
                            userName: user.userName,
                            totalXP: user.totalXP
                        )
                    }

                    // Buttons
                    VStack(spacing: 12) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Done")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.aiPrimaryGradient)
                                )
                        }
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 30)
                }
            }

            // Confetti overlay
            ConfettiView(isActive: showConfetti)
                .ignoresSafeArea()
        }
        .onAppear {
            withAnimation {
                animateResult = true
            }
            if isWinner || isPerfect {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showConfetti = true
                    HapticService.shared.perfectScore()
                    SoundService.shared.play(.perfectFanfare)
                }
            } else if isTie {
                HapticService.shared.success()
                SoundService.shared.play(.lessonComplete)
            } else {
                HapticService.shared.lightTap()
            }
        }
    }

    private func duelStat(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.aiTextPrimary)
            Text(title)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.aiTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.aiCard)
                .shadow(color: .black.opacity(0.03), radius: 3, y: 2)
        )
    }
}
