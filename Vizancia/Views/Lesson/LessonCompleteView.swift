import SwiftUI

struct LessonCompleteView: View {
    @Bindable var user: UserProfile
    let lesson: LessonData
    let category: CategoryData
    let correctCount: Int
    let totalQuestions: Int
    let xpEarned: Int
    let firstTryCount: Int
    
    @Environment(\.dismiss) private var dismiss
    @State private var animateXP = false
    @State private var animateStars = false
    @State private var showAchievement: AchievementData?
    
    private var stars: Int {
        if correctCount == totalQuestions { return 3 }
        if correctCount >= totalQuestions - 1 { return 2 }
        return 1
    }
    
    private var accuracy: Int {
        totalQuestions > 0 ? (correctCount * 100) / totalQuestions : 0
    }
    
    private var isPerfect: Bool { correctCount == totalQuestions }
    
    var body: some View {
        ZStack {
            Color.aiBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    Spacer(minLength: 30)
                    
                    // Trophy/Stars
                    VStack(spacing: 16) {
                        if isPerfect {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.aiWarning)
                                .scaleEffect(animateStars ? 1 : 0.3)
                                .animation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.2), value: animateStars)
                        }
                        
                        HStack(spacing: 8) {
                            ForEach(0..<3) { i in
                                Image(systemName: i < stars ? "star.fill" : "star")
                                    .font(.system(size: 36))
                                    .foregroundColor(i < stars ? .aiWarning : .aiTextSecondary.opacity(0.3))
                                    .scaleEffect(animateStars && i < stars ? 1 : 0.3)
                                    .animation(.spring(response: 0.5, dampingFraction: 0.5).delay(Double(i) * 0.15 + 0.3), value: animateStars)
                            }
                        }
                        
                        Text(isPerfect ? "Perfect Score!" : stars >= 2 ? "Great Job!" : "Lesson Complete!")
                            .font(.aiLargeTitle)
                            .foregroundColor(.aiTextPrimary)
                        
                        Text(lesson.title)
                            .font(.aiBody())
                            .foregroundColor(.aiTextSecondary)
                    }
                    
                    // XP Earned
                    VStack(spacing: 6) {
                        Text("+\(xpEarned)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.aiPrimary)
                            .scaleEffect(animateXP ? 1 : 0.5)
                            .animation(.spring(response: 0.5, dampingFraction: 0.4).delay(0.6), value: animateXP)
                        Text("XP Earned")
                            .font(.aiCaption())
                            .foregroundColor(.aiTextSecondary)
                    }
                    
                    // Stats
                    HStack(spacing: 14) {
                        StatCard(
                            title: "Accuracy",
                            value: "\(accuracy)%",
                            icon: "target",
                            color: accuracy >= 80 ? .aiSuccess : .aiWarning
                        )
                        StatCard(
                            title: "Correct",
                            value: "\(correctCount)/\(totalQuestions)",
                            icon: "checkmark.circle",
                            color: .aiSuccess
                        )
                        StatCard(
                            title: "First Try",
                            value: "\(firstTryCount)",
                            icon: "bolt.fill",
                            color: .aiPrimary
                        )
                    }
                    .padding(.horizontal)
                    
                    // Level Progress
                    XPProgressBar(
                        currentXP: user.totalXP,
                        progress: user.levelProgress,
                        level: user.currentLevel
                    )
                    .padding(.horizontal)
                    
                    // Continue Button
                    Button {
                        dismiss()
                    } label: {
                        Text("Continue")
                            .font(.aiHeadline())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.aiPrimaryGradient)
                            )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            withAnimation {
                animateStars = true
                animateXP = true
            }
            SoundService.shared.play(.lessonComplete)
            HapticService.shared.success()
            checkNewAchievements()
        }
        .overlay(alignment: .top) {
            if let achievement = showAchievement {
                AchievementToast(achievement: achievement)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 50)
            }
        }
    }
    
    private func checkNewAchievements() {
        for achievement in AchievementData.all {
            if !user.unlockedAchievementIds.contains(achievement.id) && achievement.condition(user) {
                user.unlockedAchievementIds.append(achievement.id)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.spring()) {
                        showAchievement = achievement
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation { showAchievement = nil }
                    }
                }
                break
            }
        }
    }
}
