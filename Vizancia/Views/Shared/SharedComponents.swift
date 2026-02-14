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
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5) { i in
                Image(systemName: i < hearts ? "heart.fill" : "heart")
                    .font(.system(size: 14))
                    .foregroundColor(i < hearts ? .aiRed : .aiTextSecondary.opacity(0.4))
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
    let onTap: () -> Void
    
    private var completedLessons: Int { progress?.completedLessonIds.count ?? 0 }
    private var totalLessons: Int { category.lessons.count }
    private var progressFraction: Double {
        totalLessons > 0 ? Double(completedLessons) / Double(totalLessons) : 0
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(categoryColor.opacity(0.15))
                            .frame(width: 48, height: 48)
                        Image(systemName: category.icon)
                            .font(.system(size: 22))
                            .foregroundColor(isLocked ? .aiTextSecondary : categoryColor)
                    }
                    Spacer()
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.aiTextSecondary)
                    } else if completedLessons == totalLessons && totalLessons > 0 {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.aiSuccess)
                            .font(.title3)
                    } else {
                        Text("\(completedLessons)/\(totalLessons)")
                            .font(.aiCaption())
                            .foregroundColor(.aiTextSecondary)
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
                
                if !isLocked {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(categoryColor.opacity(0.15))
                            RoundedRectangle(cornerRadius: 4)
                                .fill(categoryColor)
                                .frame(width: geo.size.width * progressFraction)
                        }
                    }
                    .frame(height: 6)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.aiCard)
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isLocked ? Color.aiTextSecondary.opacity(0.1) : categoryColor.opacity(0.2), lineWidth: 1)
            )
            .opacity(isLocked ? 0.6 : 1)
        }
        .disabled(isLocked)
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
                    Text(lesson.description)
                        .font(.aiCaption())
                        .foregroundColor(.aiTextSecondary)
                        .lineLimit(1)
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
