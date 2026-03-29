import SwiftUI

// MARK: - XP Progress Bar
struct XPProgressBar: View {
    let currentXP: Int
    let progress: Double
    let level: Int
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Level \(level)")
                    .font(.aiCaption())
                    .foregroundColor(.aiTextSecondary)
                Spacer()
                Text("\(currentXP) XP")
                    .font(.aiXP())
                    .foregroundColor(.aiPrimary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.aiPrimary.opacity(0.15))
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.aiPrimaryGradient)
                        .frame(width: geo.size.width * max(0, min(progress, 1)))
                        .animation(.spring(response: 0.5), value: progress)
                }
            }
            .frame(height: 10)
        }
    }
}

// MARK: - Hearts Display
struct HeartsDisplay: View {
    let hearts: Int
    var showTimer: Bool = false
    var heartsLastRefill: Date = Date()

    private var timeUntilRefill: String? {
        guard showTimer, hearts < 5 else { return nil }
        let tomorrow = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
        let remaining = tomorrow.timeIntervalSince(Date())
        guard remaining > 0 else { return nil }
        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }

    var body: some View {
        HStack(spacing: 4) {
            HStack(spacing: 2) {
                ForEach(0..<5) { i in
                    Image(systemName: i < hearts ? "heart.fill" : "heart")
                        .font(.system(size: 14))
                        .foregroundColor(i < hearts ? .aiRed : .aiTextSecondary.opacity(0.4))
                }
            }
            if let time = timeUntilRefill {
                Text(time)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.aiTextSecondary)
            }
        }
    }
}

// MARK: - Streak Badge
struct StreakBadge: View {
    let streak: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .foregroundColor(streak > 0 ? .aiOrange : .aiTextSecondary)
            Text("\(streak)")
                .font(.aiStreak())
                .foregroundColor(streak > 0 ? .aiOrange : .aiTextSecondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(streak > 0 ? Color.aiOrange.opacity(0.15) : Color.aiTextSecondary.opacity(0.1))
        )
    }
}

// MARK: - Level Badge
struct LevelBadge: View {
    let level: Int
    var size: CGFloat = 44
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.aiPrimaryGradient)
                .frame(width: size, height: size)
            Text("\(level)")
                .font(.aiRounded(.title3, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Category Card
struct CategoryCard: View {
    let category: CategoryData
    let progress: CategoryProgress?
    let isLocked: Bool
    var unlockHint: String?
    var categoryAccuracy: Double = 0
    let onTap: () -> Void

    private var completedLessons: Int { progress?.completedLessonIds.count ?? 0 }
    private var totalLessons: Int { category.lessons.count }
    private var progressFraction: Double {
        totalLessons > 0 ? Double(completedLessons) / Double(totalLessons) : 0
    }

    private var masteryTier: MasteryTier {
        guard completedLessons == totalLessons, totalLessons > 0 else { return .none }
        let stars = progress?.lessonStars ?? [:]
        let totalStars = stars.values.reduce(0, +)
        let maxStars = totalLessons * 3
        let starRatio = maxStars > 0 ? Double(totalStars) / Double(maxStars) : 0

        if starRatio >= 0.95 && categoryAccuracy >= 0.9 { return .gold }
        if starRatio >= 0.7 && categoryAccuracy >= 0.8 { return .silver }
        return .bronze
    }

    private var masteryBadge: some View {
        HStack(spacing: 3) {
            Image(systemName: masteryTier.icon)
                .font(.system(size: 14))
                .foregroundColor(masteryTier.color)
            Text(masteryTier.label)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(masteryTier.color)
        }
    }
    
    private var isNew: Bool {
        completedLessons == 0 && !isLocked
    }

    private var isComplete: Bool {
        completedLessons == totalLessons && totalLessons > 0
    }

    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(
                                isLocked ? Color.aiTextSecondary.opacity(0.1) :
                                LinearGradient(colors: [categoryColor, categoryColor.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .frame(width: 44, height: 44)
                        Image(systemName: category.icon)
                            .font(.system(size: 20))
                            .foregroundColor(isLocked ? .aiTextSecondary : .white)
                    }
                    Spacer()
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.aiTextSecondary)
                    } else if isComplete {
                        masteryBadge
                    } else if isNew {
                        Text("NEW")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(categoryColor))
                    } else {
                        // Progress ring
                        ZStack {
                            Circle()
                                .stroke(categoryColor.opacity(0.2), lineWidth: 3)
                                .frame(width: 28, height: 28)
                            Circle()
                                .trim(from: 0, to: progressFraction)
                                .stroke(categoryColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                .frame(width: 28, height: 28)
                                .rotationEffect(.degrees(-90))
                            Text("\(completedLessons)")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(categoryColor)
                        }
                    }
                }

                Text(category.name)
                    .font(.aiHeadline())
                    .foregroundColor(isLocked ? .aiTextSecondary : .aiTextPrimary)
                    .lineLimit(1)

                Text(category.description)
                    .font(.aiCaption())
                    .foregroundColor(.aiTextSecondary)
                    .lineLimit(2)

                if isLocked, let hint = unlockHint {
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 9))
                        Text(hint)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(.aiTextSecondary)
                    .lineLimit(1)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.aiCard)
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isComplete ? categoryColor.opacity(0.4) :
                        isLocked ? Color.aiTextSecondary.opacity(0.1) :
                        categoryColor.opacity(0.15),
                        lineWidth: isComplete ? 2 : 1
                    )
            )
            .opacity(isLocked ? 0.6 : 1)
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)
        }
        .disabled(isLocked)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in if !isLocked { isPressed = true } }
                .onEnded { _ in isPressed = false }
        )
    }

    private var categoryColor: Color {
        switch category.colorName {
        case "aiPrimary": return .aiPrimary
        case "aiSecondary": return .aiSecondary
        case "aiOrange": return .aiOrange
        case "aiRed": return .aiError
        case "aiGreen": return .aiSuccess
        case "aiTeal": return .aiSecondary
        case "aiIndigo": return .aiPrimary
        case "aiBrown": return .aiOrange
        case "aiCyan": return .aiSecondary
        default: return .aiPrimary
        }
    }
}

// MARK: - Lesson Row
struct LessonRow: View {
    let lesson: LessonData
    let isCompleted: Bool
    let isLocked: Bool
    let stars: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(isCompleted ? Color.aiSuccess.opacity(0.15) : isLocked ? Color.aiTextSecondary.opacity(0.1) : Color.aiPrimary.opacity(0.15))
                        .frame(width: 44, height: 44)
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .foregroundColor(.aiSuccess)
                            .fontWeight(.bold)
                    } else if isLocked {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.aiTextSecondary)
                            .font(.footnote)
                    } else {
                        Text("\(lesson.order + 1)")
                            .font(.aiRounded(.body, weight: .semibold))
                            .foregroundColor(.aiPrimary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(lesson.title)
                        .font(.aiBody())
                        .foregroundColor(isLocked ? .aiTextSecondary : .aiTextPrimary)
                    HStack(spacing: 6) {
                        Text(lesson.description)
                            .font(.aiCaption())
                            .foregroundColor(.aiTextSecondary)
                            .lineLimit(1)
                        Text("~\(max(lesson.questionCount / 2, 2)) min")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(.aiTextSecondary.opacity(0.6))
                    }
                }

                Spacer()

                if isCompleted {
                    HStack(spacing: 2) {
                        ForEach(0..<3) { i in
                            Image(systemName: i < stars ? "star.fill" : "star")
                                .font(.system(size: 12))
                                .foregroundColor(i < stars ? .aiWarning : .aiTextSecondary.opacity(0.3))
                        }
                    }
                }
                
                if !isLocked {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.aiTextSecondary)
                        .font(.caption)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.aiCard)
                    .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
            )
            .opacity(isLocked ? 0.6 : 1)
        }
        .disabled(isLocked)
    }
}

// MARK: - Daily Goal Widget
struct DailyGoalWidget: View {
    let user: UserProfile
    
    private var goalProgress: Double {
        guard user.dailyXPGoal > 0 else { return 0 }
        return min(Double(user.todayXP) / Double(user.dailyXPGoal), 1.0)
    }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily Goal")
                        .font(.aiCaption())
                        .foregroundColor(.aiTextSecondary)
                    Text("\(user.todayXP) / \(user.dailyXPGoal) XP")
                        .font(.aiHeadline())
                        .foregroundColor(.aiTextPrimary)
                }
                Spacer()
                ZStack {
                    Circle()
                        .stroke(Color.aiSuccess.opacity(0.2), lineWidth: 5)
                        .frame(width: 50, height: 50)
                    Circle()
                        .trim(from: 0, to: goalProgress)
                        .stroke(Color.aiSuccess, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(), value: goalProgress)
                    if goalProgress >= 1 {
                        Image(systemName: "checkmark")
                            .foregroundColor(.aiSuccess)
                            .fontWeight(.bold)
                    } else {
                        Text("\(Int(goalProgress * 100))%")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.aiSuccess)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.aiCard)
                .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
        )
    }
}

// MARK: - Achievement Toast
struct AchievementToast: View {
    let achievement: AchievementData
    
    var body: some View {
        HStack(spacing: 12) {
            Text(achievement.icon)
                .font(.system(size: 36))
            VStack(alignment: .leading, spacing: 2) {
                Text("Achievement Unlocked!")
                    .font(.aiCaption())
                    .foregroundColor(.aiWarning)
                Text(achievement.name)
                    .font(.aiHeadline())
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(colors: [.aiPrimary, .aiGradientEnd], startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .padding(.horizontal)
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(value)
                .font(.aiRounded(.title2, weight: .bold))
                .foregroundColor(.aiTextPrimary)
            Text(title)
                .font(.aiCaption())
                .foregroundColor(.aiTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.aiCard)
                .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        )
    }
}

// MARK: - Mastery Tier
enum MasteryTier {
    case none, bronze, silver, gold

    var label: String {
        switch self {
        case .none: return ""
        case .bronze: return "Bronze"
        case .silver: return "Silver"
        case .gold: return "Gold"
        }
    }

    var icon: String {
        switch self {
        case .none: return "checkmark.circle.fill"
        case .bronze: return "medal.fill"
        case .silver: return "medal.fill"
        case .gold: return "trophy.fill"
        }
    }

    var color: Color {
        switch self {
        case .none: return .aiSuccess
        case .bronze: return Color(red: 0.8, green: 0.5, blue: 0.2)
        case .silver: return Color(red: 0.6, green: 0.65, blue: 0.7)
        case .gold: return Color(red: 1.0, green: 0.84, blue: 0.0)
        }
    }
}
