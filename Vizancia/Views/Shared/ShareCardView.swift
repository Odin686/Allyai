import SwiftUI

// MARK: - Share Card Types
enum ShareCardType {
    case lessonComplete(lessonTitle: String, score: Int, total: Int, xp: Int)
    case duelWin(opponentName: String, myScore: Int, theirScore: Int)
    case streakMilestone(days: Int)
    case levelUp(level: Int, title: String)
    case achievement(name: String, description: String, icon: String)
}

// MARK: - Share Card View (rendered to image)
struct ShareCardView: View {
    let cardType: ShareCardType
    let userName: String
    let totalXP: Int

    var body: some View {
        VStack(spacing: 0) {
            cardContent
            brandFooter
        }
        .frame(width: 340)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.2), radius: 16, y: 8)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    // MARK: - Card Content
    @ViewBuilder
    private var cardContent: some View {
        switch cardType {
        case .lessonComplete(let title, let score, let total, let xp):
            lessonCompleteCard(title: title, score: score, total: total, xp: xp)
        case .duelWin(let opponent, let myScore, let theirScore):
            duelWinCard(opponent: opponent, myScore: myScore, theirScore: theirScore)
        case .streakMilestone(let days):
            streakCard(days: days)
        case .levelUp(let level, let title):
            levelUpCard(level: level, title: title)
        case .achievement(let name, let description, let icon):
            achievementCard(name: name, description: description, icon: icon)
        }
    }

    // MARK: - Lesson Complete

    private func lessonCompleteCard(title: String, score: Int, total: Int, xp: Int) -> some View {
        VStack(spacing: 16) {
            Spacer(minLength: 24)
            Image(systemName: score == total ? "star.fill" : "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.white)

            Text(score == total ? "Perfect Score!" : "Lesson Complete!")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(title)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            HStack(spacing: 24) {
                statPill(value: "\(score)/\(total)", label: "Score")
                statPill(value: "+\(xp)", label: "XP")
            }

            Spacer(minLength: 20)
        }
        .frame(minHeight: 260)
    }

    // MARK: - Duel Win

    private func duelWinCard(opponent: String, myScore: Int, theirScore: Int) -> some View {
        VStack(spacing: 16) {
            Spacer(minLength: 24)
            Image(systemName: "trophy.fill")
                .font(.system(size: 48))
                .foregroundColor(.yellow)

            Text("Duel Victory! ⚔️")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("\(myScore)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Me")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
                Text("vs")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
                VStack(spacing: 4) {
                    Text("\(theirScore)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                    Text(opponent)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 20)
        }
        .frame(minHeight: 260)
    }

    // MARK: - Streak

    private func streakCard(days: Int) -> some View {
        VStack(spacing: 16) {
            Spacer(minLength: 24)
            Image(systemName: "flame.fill")
                .font(.system(size: 54))
                .foregroundColor(.orange)

            Text("\(days)-Day Streak! 🔥")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("Learning AI every single day")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.8))

            Spacer(minLength: 20)
        }
        .frame(minHeight: 240)
    }

    // MARK: - Level Up

    private func levelUpCard(level: Int, title: String) -> some View {
        VStack(spacing: 16) {
            Spacer(minLength: 24)
            ZStack {
                Circle()
                    .fill(.white.opacity(0.15))
                    .frame(width: 80, height: 80)
                Text("\(level)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }

            Text("Level \(level)!")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.85))

            Text("\(totalXP) Total XP")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.6))

            Spacer(minLength: 20)
        }
        .frame(minHeight: 260)
    }

    // MARK: - Achievement

    private func achievementCard(name: String, description: String, icon: String) -> some View {
        VStack(spacing: 16) {
            Spacer(minLength: 24)
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.yellow)

            Text("Achievement Unlocked!")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
                .textCase(.uppercase)
                .tracking(1)

            Text(name)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text(description)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.75))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            Spacer(minLength: 20)
        }
        .frame(minHeight: 260)
    }

    // MARK: - Helpers

    private func statPill(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.white.opacity(0.15))
        )
    }

    private var brandFooter: some View {
        HStack {
            // Mascot image reference
            Image(systemName: "cpu")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
            Text("Vizancia")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
            Text("•")
                .foregroundColor(.white.opacity(0.3))
            Text(userName.isEmpty ? "AI Learner" : userName)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
            Spacer()
            Text("\(totalXP) XP")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(.black.opacity(0.15))
    }

    private var gradientColors: [Color] {
        switch cardType {
        case .lessonComplete(_, let score, let total, _):
            return score == total
                ? [Color(red: 0.6, green: 0.3, blue: 0.9), Color(red: 0.4, green: 0.1, blue: 0.7)]  // Purple
                : [Color(red: 0.2, green: 0.5, blue: 0.9), Color(red: 0.1, green: 0.3, blue: 0.7)]   // Blue
        case .duelWin:
            return [Color(red: 0.15, green: 0.15, blue: 0.2), Color(red: 0.1, green: 0.1, blue: 0.15)]  // Dark
        case .streakMilestone:
            return [Color(red: 0.9, green: 0.4, blue: 0.1), Color(red: 0.8, green: 0.2, blue: 0.1)]     // Orange
        case .levelUp:
            return [Color(red: 0.2, green: 0.7, blue: 0.5), Color(red: 0.1, green: 0.5, blue: 0.4)]     // Teal
        case .achievement:
            return [Color(red: 0.7, green: 0.5, blue: 0.1), Color(red: 0.5, green: 0.3, blue: 0.1)]     // Gold
        }
    }
}

// MARK: - Share Card Service
@MainActor
class ShareService {
    static let shared = ShareService()

    /// Render a share card view to a UIImage
    func renderShareCard(_ cardType: ShareCardType, userName: String, totalXP: Int) -> UIImage? {
        let view = ShareCardView(cardType: cardType, userName: userName, totalXP: totalXP)
        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }

    /// Present share sheet with rendered card — returns activity items for SwiftUI sheet
    func shareItems(_ cardType: ShareCardType, userName: String, totalXP: Int) -> [Any] {
        let text = shareText(for: cardType)
        if let image = renderShareCard(cardType, userName: userName, totalXP: totalXP) {
            return [image, text]
        }
        return [text]
    }

    private func shareText(for cardType: ShareCardType) -> String {
        switch cardType {
        case .lessonComplete(let title, let score, let total, _):
            return score == total
                ? "Just got a perfect score on \"\(title)\" in Vizancia! 🌟 #AILearning #Vizancia"
                : "Completed \"\(title)\" in Vizancia! 🎓 #AILearning #Vizancia"
        case .duelWin(let opponent, _, _):
            return "Just won an AI knowledge duel against \(opponent) in Vizancia! ⚔️🏆 #Vizancia"
        case .streakMilestone(let days):
            return "I've been learning AI for \(days) days straight on Vizancia! 🔥 #LearningStreak #Vizancia"
        case .levelUp(let level, let title):
            return "Just reached Level \(level) — \(title) — in Vizancia! 🚀 #AILearning #Vizancia"
        case .achievement(let name, _, _):
            return "Just unlocked \"\(name)\" in Vizancia! 🏅 #Achievement #Vizancia"
        }
    }
}

// MARK: - Share Button Component
struct ShareButton: View {
    let cardType: ShareCardType
    let userName: String
    let totalXP: Int
    @State private var showShareSheet = false

    var body: some View {
        Button {
            showShareSheet = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 14))
                Text("Share")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.aiPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.aiPrimary.opacity(0.1))
            )
        }
        .sheet(isPresented: $showShareSheet) {
            ActivityViewSheet(
                activityItems: ShareService.shared.shareItems(
                    cardType, userName: userName, totalXP: totalXP
                )
            )
            .presentationDetents([.medium, .large])
        }
    }
}

// MARK: - Activity View Sheet (UIKit wrapper for SwiftUI)
struct ActivityViewSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
