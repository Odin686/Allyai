import SwiftUI

struct LessonCompleteView: View {
    @Bindable var user: UserProfile
    let lesson: LessonData
    let category: CategoryData
    let correctCount: Int
    let totalQuestions: Int
    let xpEarned: Int
    let firstTryCount: Int
    var onNextLesson: ((LessonData) -> Void)?

    @Environment(\.dismiss) private var dismiss
    @State private var animateXP = false
    @State private var animateStars = false
    @State private var showAchievement: AchievementData?
    @State private var showConfetti = false
    @State private var showLevelUp = false
    @State private var levelUpTitle = ""
    @State private var levelUpLevel = 0

    private var nextLesson: LessonData? {
        LessonContentProvider.shared.nextLesson(after: lesson.id)
    }

    private var isNextLessonUnlocked: Bool {
        // Next lesson is unlocked since the current one is now complete
        nextLesson != nil
    }
    
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
                                    .rotationEffect(.degrees(animateStars && i < stars ? 0 : -30))
                                    .animation(.spring(response: 0.5, dampingFraction: 0.5).delay(Double(i) * 0.2 + 0.3), value: animateStars)
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
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        if let next = nextLesson, onNextLesson != nil {
                            Button {
                                dismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onNextLesson?(next)
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Text("Next Lesson")
                                    Image(systemName: "arrow.right")
                                }
                                .font(.aiHeadline())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.aiPrimaryGradient)
                                )
                            }

                            Button {
                                dismiss()
                            } label: {
                                Text("Back to \(category.name)")
                                    .font(.aiBody())
                                    .foregroundColor(.aiTextSecondary)
                            }
                        } else {
                            Button {
                                dismiss()
                            } label: {
                                Text(category.lessons.allSatisfy({ user.categoryProgressList.first(where: { $0.categoryId == category.id })?.completedLessonIds.contains($0.id) ?? false }) ? "Category Complete!" : "Continue")
                                    .font(.aiHeadline())
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color.aiPrimaryGradient)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)

                    // What's Next suggestion
                    if let tip = whatsNextTip {
                        HStack(spacing: 10) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.aiWarning)
                            Text(tip)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.aiTextSecondary)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.aiWarning.opacity(0.06))
                        )
                        .padding(.horizontal)
                    }

                    Spacer(minLength: 30)
                }
            }
        }
        .onAppear {
            withAnimation {
                animateStars = true
                animateXP = true
            }
            if isPerfect {
                SoundService.shared.play(.perfectFanfare)
                HapticService.shared.perfectScore()
            } else {
                SoundService.shared.play(.lessonComplete)
                HapticService.shared.success()
            }
            checkNewAchievements()

            // Confetti for perfect score
            if isPerfect {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showConfetti = true
                }
            }

            // Check for level up
            let oldXP = user.totalXP - xpEarned
            if let newLevel = XPService.shared.didLevelUp(oldXP: oldXP, newXP: user.totalXP) {
                levelUpLevel = newLevel.level
                levelUpTitle = newLevel.title
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { showLevelUp = true }
                    showConfetti = true
                    HapticService.shared.levelUp()
                    SoundService.shared.play(.levelUp)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        withAnimation { showLevelUp = false }
                    }
                }
            }
        }
        .overlay {
            ConfettiView(isActive: showConfetti)
                .ignoresSafeArea()
        }
        .overlay {
            if showLevelUp {
                LevelUpBannerView(levelTitle: levelUpTitle, level: levelUpLevel)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .overlay(alignment: .top) {
            if let achievement = showAchievement {
                AchievementToast(achievement: achievement)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 50)
            }
        }
    }
    
    private var whatsNextTip: String? {
        if correctCount < totalQuestions / 2 {
            return "Try the Practice Mistakes mode on the home screen to review tricky questions!"
        } else if isPerfect && nextLesson == nil {
            return "Category complete! Try a mini-game to test your skills in a new way."
        } else if isPerfect {
            return "Perfect score! You're mastering \(category.name) — keep going!"
        } else if user.gamesPlayed < 3 {
            return "Have you tried the mini-games? They're a fun way to reinforce what you've learned."
        }
        return nil
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
