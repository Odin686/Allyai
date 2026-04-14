import SwiftUI

struct TrainView: View {
    @Bindable var user: UserProfile
    @State private var showDailyChallenge = false
    @State private var showPracticeMistakes = false
    @State private var showSmartReview = false
    @State private var showLesson: TrainLessonLaunch?

    private let provider = LessonContentProvider.shared

    struct TrainLessonLaunch: Identifiable {
        let id = UUID()
        let lesson: LessonData
        let category: CategoryData
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Daily Goal Widget
                    DailyGoalWidget(user: user)
                        .padding(.horizontal)

                    // Daily Challenge
                    dailyChallengeSection

                    // Practice Mistakes
                    if !user.missedQuestionIds.isEmpty {
                        practiceMistakesSection
                    }

                    // Smart Review (Spaced Repetition)
                    smartReviewSection

                    // Quick Review
                    quickReviewSection

                    // Category Accuracy
                    categoryAccuracySection
                }
                .padding(.bottom, 30)
            }
            .background(Color.aiBackground.ignoresSafeArea())
            .navigationTitle("Train")
            .fullScreenCover(isPresented: $showDailyChallenge) {
                DailyChallengeView(user: user)
            }
            .fullScreenCover(isPresented: $showPracticeMistakes) {
                PracticeMistakesView(user: user)
            }
            .fullScreenCover(item: $showLesson) { launch in
                LessonView(user: user, lesson: launch.lesson, category: launch.category)
            }
            .fullScreenCover(isPresented: $showSmartReview) {
                SmartReviewView(user: user)
            }
        }
    }

    // MARK: - Daily Challenge
    private var dailyChallengeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Daily", icon: "star.circle.fill", color: .aiWarning)

            if !user.hasCompletedDailyChallenge {
                Button { showDailyChallenge = true } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.aiWarning.opacity(0.15))
                                .frame(width: 52, height: 52)
                            Image(systemName: "star.circle.fill")
                                .font(.title2)
                                .foregroundColor(.aiWarning)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Daily Challenge")
                                    .font(.aiHeadline())
                                    .foregroundColor(.aiTextPrimary)
                                Text("NEW")
                                    .font(.system(size: 9, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Capsule().fill(Color.aiWarning))
                            }
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
            } else {
                // Completed state
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.aiSuccess.opacity(0.1))
                            .frame(width: 52, height: 52)
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.aiSuccess)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Daily Challenge Complete!")
                            .font(.aiHeadline())
                            .foregroundColor(.aiTextPrimary)
                        if user.dailyChallengeStreak > 1 {
                            Text("\(user.dailyChallengeStreak)-day streak 🔥")
                                .font(.aiCaption())
                                .foregroundColor(.aiOrange)
                        } else {
                            Text("Come back tomorrow for a new challenge")
                                .font(.aiCaption())
                                .foregroundColor(.aiTextSecondary)
                        }
                    }
                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.aiCard)
                        .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
                )
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Practice Mistakes
    private var practiceMistakesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Review", icon: "arrow.counterclockwise", color: .aiOrange)

            Button { showPracticeMistakes = true } label: {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.aiOrange.opacity(0.15))
                            .frame(width: 52, height: 52)
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title2)
                            .foregroundColor(.aiOrange)
                    }
                    VStack(alignment: .leading, spacing: 4) {
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
                        .stroke(Color.aiOrange.opacity(0.2), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Quick Review
    private var quickReviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Quick Review", icon: "bolt.fill", color: .aiPrimary)

            Button { startQuickReview() } label: {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.aiPrimary.opacity(0.12))
                            .frame(width: 52, height: 52)
                        Image(systemName: "shuffle")
                            .font(.title2)
                            .foregroundColor(.aiPrimary)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Random Lesson Review")
                            .font(.aiHeadline())
                            .foregroundColor(.aiTextPrimary)
                        Text("Jump into a random lesson to stay sharp")
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
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Category Accuracy
    private var categoryAccuracySection: some View {
        let categories = provider.allCategories.filter { cat in
            (user.categoryQuestionCounts[cat.id] ?? 0) > 0
        }

        return Group {
            if !categories.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    sectionHeader(title: "Your Strengths", icon: "chart.bar.fill", color: .aiSecondary)

                    ForEach(categories, id: \.id) { cat in
                        let accuracy = user.categoryAccuracy(for: cat.id)
                        let total = user.categoryQuestionCounts[cat.id] ?? 0

                        HStack(spacing: 12) {
                            Image(systemName: cat.icon)
                                .font(.system(size: 16))
                                .foregroundColor(.aiPrimary)
                                .frame(width: 30)

                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(cat.name)
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.aiTextPrimary)
                                    Spacer()
                                    Text("\(Int(accuracy * 100))%")
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundColor(accuracy >= 0.8 ? .aiSuccess : accuracy >= 0.5 ? .aiOrange : .aiError)
                                }
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(Color.aiPrimary.opacity(0.1))
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(accuracy >= 0.8 ? Color.aiSuccess : accuracy >= 0.5 ? Color.aiOrange : Color.aiError)
                                            .frame(width: geo.size.width * accuracy)
                                    }
                                }
                                .frame(height: 6)
                                Text("\(total) questions answered")
                                    .font(.system(size: 11, design: .rounded))
                                    .foregroundColor(.aiTextSecondary.opacity(0.7))
                            }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.aiCard)
                                .shadow(color: .black.opacity(0.02), radius: 2, y: 1)
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Smart Review (Spaced Repetition)
    private var smartReviewSection: some View {
        let dueCount = SpacedRepetitionService.shared.dueCount(for: user)
        let mastery = SpacedRepetitionService.shared.masteryPercentage(for: user)
        let totalCards = user.spacedRepetitionCards.count

        return VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Smart Review", icon: "brain.head.profile", color: .aiPrimary)

            Button { showSmartReview = true } label: {
                VStack(spacing: 12) {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.aiPrimary.opacity(0.12))
                                .frame(width: 52, height: 52)
                            Image(systemName: "brain.head.profile")
                                .font(.title2)
                                .foregroundColor(.aiPrimary)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Spaced Review")
                                    .font(.aiHeadline())
                                    .foregroundColor(.aiTextPrimary)
                                if dueCount > 0 {
                                    Text("\(dueCount) due")
                                        .font(.system(size: 10, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 7)
                                        .padding(.vertical, 2)
                                        .background(Capsule().fill(Color.aiPrimary))
                                }
                            }
                            Text("AI-powered review at optimal intervals")
                                .font(.aiCaption())
                                .foregroundColor(.aiTextSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.aiTextSecondary)
                            .font(.caption)
                    }

                    // Mastery bar (if there are cards)
                    if totalCards > 0 {
                        HStack(spacing: 8) {
                            Text("Mastery")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(.aiTextSecondary)
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color.aiPrimary.opacity(0.1))
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color.aiPrimary)
                                        .frame(width: geo.size.width * mastery)
                                }
                            }
                            .frame(height: 6)
                            Text("\(Int(mastery * 100))%")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.aiPrimary)
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.aiCard)
                        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(dueCount > 0 ? Color.aiPrimary.opacity(0.2) : Color.clear, lineWidth: 1)
                )
            }
        }
        .padding(.horizontal)
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

    private func startQuickReview() {
        let unlocked = provider.allCategories.filter { !isCategoryLocked($0) }
        guard let cat = unlocked.randomElement() else { return }
        let progress = user.categoryProgressList.first { $0.categoryId == cat.id }
        let incomplete = cat.lessons.first { lesson in
            !(progress?.completedLessonIds.contains(lesson.id) ?? false)
        }
        guard let selectedLesson = incomplete ?? cat.lessons.randomElement() else { return }
        showLesson = TrainLessonLaunch(lesson: selectedLesson, category: cat)
        HapticService.shared.mediumTap()
    }

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
