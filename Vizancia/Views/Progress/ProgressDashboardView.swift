import SwiftUI

struct ProgressDashboardView: View {
    @Bindable var user: UserProfile
    
    private let provider = LessonContentProvider.shared
    
    private var totalCategories: Int { provider.allCategories.count }
    private var completedCategories: Int { user.categoryProgressList.filter(\.isComplete).count }
    private var totalLessonsAvail: Int { provider.allCategories.flatMap(\.lessons).count }
    private var overallAccuracy: Int {
        user.totalQuestionsAnswered > 0 ? (user.totalCorrectAnswers * 100) / user.totalQuestionsAnswered : 0
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Level Card
                    levelCard
                    
                    // Stats Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatCard(title: "Total XP", value: formatNumber(user.totalXP), icon: "star.fill", color: .aiPrimary)
                        StatCard(title: "Streak", value: "\(user.currentStreak) days", icon: "flame.fill", color: .aiOrange)
                        StatCard(title: "Lessons", value: "\(user.totalLessonsCompleted)/\(totalLessonsAvail)", icon: "book.fill", color: .aiSuccess)
                        StatCard(title: "Accuracy", value: "\(overallAccuracy)%", icon: "target", color: .aiSecondary)
                        StatCard(title: "Categories", value: "\(completedCategories)/\(totalCategories)", icon: "folder.fill", color: .aiWarning)
                        StatCard(title: "Games Played", value: "\(user.gamesPlayed)", icon: "gamecontroller.fill", color: .aiError)
                    }
                    .padding(.horizontal)
                    
                    // Achievements
                    achievementsSection
                    
                    // Streak Calendar
                    streakCalendar
                }
                .padding(.bottom, 30)
            }
            .background(Color.aiBackground.ignoresSafeArea())
            .navigationTitle("Progress")
        }
    }
    
    // MARK: - Level
    private var levelCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                LevelBadge(level: user.currentLevel, size: 60)
                VStack(alignment: .leading, spacing: 4) {
                    let levelDef = LevelDefinition.all.first { $0.level == user.currentLevel }
                    Text(levelDef?.title ?? "AI Novice")
                        .font(.aiTitle())
                        .foregroundColor(.aiTextPrimary)
                    Text("\(user.totalXP) XP Total")
                        .font(.aiCaption())
                        .foregroundColor(.aiTextSecondary)
                }
                Spacer()
            }
            XPProgressBar(currentXP: user.totalXP, progress: user.levelProgress, level: user.currentLevel)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.aiCard)
                .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
        )
        .padding(.horizontal)
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
                        VStack(spacing: 6) {
                            Text(achievement.icon)
                                .font(.system(size: 30))
                                .grayscale(unlocked ? 0 : 1)
                                .opacity(unlocked ? 1 : 0.4)
                            Text(achievement.name)
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundColor(unlocked ? .aiTextPrimary : .aiTextSecondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 80, height: 90)
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
