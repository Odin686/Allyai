import SwiftUI

struct HomeView: View {
    @Bindable var user: UserProfile
    @State private var showDailyChallenge = false
    @State private var showPracticeMistakes = false
    @State private var showLesson: LessonLaunch?

    private let provider = LessonContentProvider.shared

    struct LessonLaunch: Identifiable {
        let id = UUID()
        let lesson: LessonData
        let category: CategoryData
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Greeting + inline stats
                    greetingSection
                        .padding(.horizontal)

                    // Continue Learning (hero)
                    if let continueInfo = continueWhere {
                        continueCard(category: continueInfo.0, lesson: continueInfo.1)
                    }

                    // Daily Goal
                    DailyGoalWidget(user: user)
                        .padding(.horizontal)

                    // Quick Play or Daily Challenge
                    if !user.hasCompletedDailyChallenge {
                        dailyChallengeCard
                    } else {
                        quickPlayButton
                    }

                    // Practice Mistakes (only if needed)
                    if !user.missedQuestionIds.isEmpty {
                        practiceMistakesCard
                    }
                }
                .padding(.bottom, 30)
            }
            .background(Color.aiBackground.ignoresSafeArea())
            .navigationTitle("Vizancia")
            .navigationBarTitleDisplayMode(.large)
            .fullScreenCover(isPresented: $showDailyChallenge) {
                DailyChallengeView(user: user)
            }
            .fullScreenCover(isPresented: $showPracticeMistakes) {
                PracticeMistakesView(user: user)
            }
            .fullScreenCover(item: $showLesson) { launch in
                LessonView(user: user, lesson: launch.lesson, category: launch.category)
            }
        }
    }

    // MARK: - Greeting + Stats
    private var greetingSection: some View {
        let name = user.userName.isEmpty ? user.name : user.userName
        let displayName = (name == "Learner" || name.isEmpty) ? "there" : name
        let greeting: String = {
            let hour = Calendar.current.component(.hour, from: Date())
            if hour < 12 { return "Good morning, \(displayName)" }
            if hour < 17 { return "Good afternoon, \(displayName)" }
            return "Good evening, \(displayName)"
        }()

        return VStack(spacing: 10) {
            HStack {
                Text(greeting)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.aiTextPrimary)
                Spacer()
                if user.currentStreak > 0 {
                    StreakBadge(streak: user.currentStreak)
                }
            }

            HStack(spacing: 0) {
                Label("\(user.totalXP) XP", systemImage: "star.fill")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.aiPrimary)
                Spacer()
                Label("Lvl \(user.currentLevel)", systemImage: "trophy.fill")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.aiWarning)
                Spacer()
                HeartsDisplay(hearts: user.hearts, showTimer: true, heartsLastRefill: user.heartsLastRefill)
            }
        }
    }

    // MARK: - Continue Learning
    private var continueWhere: (CategoryData, LessonData)? {
        guard user.totalLessonsCompleted > 0 else { return nil }
        for cat in provider.allCategories {
            if isCategoryLocked(cat) { continue }
            let prog = user.categoryProgressList.first { $0.categoryId == cat.id }
            if prog?.isComplete ?? false { continue }
            if let nextLesson = cat.lessons.first(where: { lesson in
                !(prog?.completedLessonIds.contains(lesson.id) ?? false)
            }) {
                return (cat, nextLesson)
            }
        }
        return nil
    }

    private func continueCard(category: CategoryData, lesson: LessonData) -> some View {
        Button {
            showLesson = LessonLaunch(lesson: lesson, category: category)
            HapticService.shared.mediumTap()
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 52, height: 52)
                    Image(systemName: "play.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("CONTINUE")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .tracking(1)
                    Text(lesson.title)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Text(category.name)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [Color.aiPrimary, Color.aiPrimary.opacity(0.8), Color.aiGradientEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .aiPrimary.opacity(0.3), radius: 10, y: 5)
            )
        }
        .padding(.horizontal)
    }

    // MARK: - Daily Challenge
    private var dailyChallengeCard: some View {
        Button { showDailyChallenge = true } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.aiWarning.opacity(0.15))
                        .frame(width: 50, height: 50)
                    Image(systemName: "star.circle.fill")
                        .font(.title2)
                        .foregroundColor(.aiWarning)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("Daily Challenge")
                        .font(.aiHeadline())
                        .foregroundColor(.aiTextPrimary)
                    Text("Answer today's question for bonus XP!")
                        .font(.aiCaption())
                        .foregroundColor(.aiTextSecondary)
                }
                Spacer()
                Text("+25 XP")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.aiWarning)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.aiCard)
                    .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.aiWarning.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal)
    }

    // MARK: - Quick Play
    private var quickPlayButton: some View {
        Button { startQuickPlay() } label: {
            HStack(spacing: 12) {
                Image(systemName: "shuffle")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.aiPrimary)
                Text("Quick Play — Random Lesson")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.aiPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.aiTextSecondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.aiPrimary.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.aiPrimary.opacity(0.15), lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal)
    }

    private func startQuickPlay() {
        let unlocked = provider.allCategories.filter { !isCategoryLocked($0) }
        guard let cat = unlocked.randomElement() else { return }
        let progress = user.categoryProgressList.first { $0.categoryId == cat.id }
        let incomplete = cat.lessons.first { lesson in
            !(progress?.completedLessonIds.contains(lesson.id) ?? false)
        }
        guard let selectedLesson = incomplete ?? cat.lessons.randomElement() else { return }
        showLesson = LessonLaunch(lesson: selectedLesson, category: cat)
        HapticService.shared.mediumTap()
    }

    // MARK: - Practice Mistakes
    private var practiceMistakesCard: some View {
        Button { showPracticeMistakes = true } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.aiOrange.opacity(0.15))
                        .frame(width: 50, height: 50)
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title2)
                        .foregroundColor(.aiOrange)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("Practice Mistakes")
                        .font(.aiHeadline())
                        .foregroundColor(.aiTextPrimary)
                    Text("\(user.missedQuestionIds.count) questions to review")
                        .font(.aiCaption())
                        .foregroundColor(.aiTextSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.aiTextSecondary)
                    .font(.caption)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.aiCard)
                    .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.aiOrange.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal)
    }

    // MARK: - Helpers
    private func isCategoryLocked(_ category: CategoryData) -> Bool {
        switch category.unlockRequirement {
        case .none:
            return false
        case .completeCategory(let id):
            return !(user.categoryProgressList.first { $0.categoryId == id }?.isComplete ?? false)
        case .completeCategoryMinimum(let id):
            let progress = user.categoryProgressList.first { $0.categoryId == id }
            return (progress?.completedLessonIds.count ?? 0) < 2
        }
    }
}
