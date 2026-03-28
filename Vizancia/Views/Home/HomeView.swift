import SwiftUI

struct HomeView: View {
    @Bindable var user: UserProfile
    @State private var showCategoryDetail: CategoryData?
    @State private var xpFloatText = ""
    @State private var showXPFloat = false
    @State private var showPracticeMistakes = false
    @State private var showDailyChallenge = false

    private let provider = LessonContentProvider.shared
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Viz Mascot
                    vizSection
                        .padding(.horizontal)

                    // Header Stats
                    headerSection

                    // Daily Goal
                    DailyGoalWidget(user: user)
                        .padding(.horizontal)

                    // Daily Challenge
                    if !user.hasCompletedDailyChallenge {
                        dailyChallengeCard
                    }

                    // Recommended Next
                    if let recommended = recommendedCategory {
                        recommendedCard(recommended)
                    }

                    // Practice Mistakes
                    if !user.missedQuestionIds.isEmpty {
                        practiceMistakesCard
                    }

                    // Categories Grid
                    categoriesSection
                }
                .padding(.bottom, 30)
            }
            .background(Color.aiBackground.ignoresSafeArea())
            .navigationTitle("Vizancia")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { headerToolbar }
            .sheet(item: $showCategoryDetail) { cat in
                CategoryDetailView(user: user, category: cat)
            }
            .fullScreenCover(isPresented: $showPracticeMistakes) {
                PracticeMistakesView(user: user)
            }
            .fullScreenCover(isPresented: $showDailyChallenge) {
                DailyChallengeView(user: user)
            }
        }
    }
    
    // MARK: - Viz Mascot
    private var vizSection: some View {
        HStack(spacing: 12) {
            VizMascotView(size: 60, showMessage: false, enableEyePop: true)
            VStack(alignment: .leading, spacing: 3) {
                Text(vizGreeting)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.aiTextPrimary)
                Text(vizSubtext)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.aiTextSecondary)
            }
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.aiPrimary.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.aiPrimary.opacity(0.12), lineWidth: 1)
                )
        )
    }

    private var vizGreeting: String {
        let name = user.userName.isEmpty ? user.name : user.userName
        let displayName = (name == "Learner" || name.isEmpty) ? "there" : name
        if user.totalLessonsCompleted == 0 {
            return "Hey \(displayName)! Ready to start?"
        } else if user.currentStreak >= 7 {
            return "\(user.currentStreak)-day streak! Amazing, \(displayName)!"
        } else if user.dailyGoalMet {
            return "Daily goal crushed, \(displayName)!"
        } else {
            return "Welcome back, \(displayName)!"
        }
    }

    private var vizSubtext: String {
        if user.totalLessonsCompleted == 0 {
            return "Tap a category below to begin your AI journey."
        } else if user.currentStreak >= 7 {
            return "You're on fire! Keep that momentum going."
        } else if user.dailyGoalMet {
            return "Try a game or explore a new topic?"
        } else if !user.missedQuestionIds.isEmpty && user.missedQuestionIds.count >= 3 {
            return "\(user.missedQuestionIds.count) questions to review — practice makes perfect!"
        } else {
            return "Let's learn something new about AI today."
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 12) {
            XPProgressBar(
                currentXP: user.totalXP,
                progress: user.levelProgress,
                level: user.currentLevel
            )
            .padding(.horizontal)
            
            HStack(spacing: 16) {
                HeartsDisplay(hearts: user.hearts, showTimer: true, heartsLastRefill: user.heartsLastRefill)
                Spacer()
                StreakBadge(streak: user.currentStreak)
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var headerToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            LevelBadge(level: user.currentLevel, size: 34)
        }
    }
    
    // MARK: - Categories
    private let tracks: [(name: String, icon: String, ids: [String])] = [
        ("Foundations", "book.fill", ["ai_basics", "how_ai_learns", "ai_history"]),
        ("Skills", "hammer.fill", ["generative_ai", "prompt_engineering", "ai_at_work"]),
        ("Deep Dive", "magnifyingglass", ["ai_vocabulary", "ai_under_hood", "ai_tools"]),
        ("Big Picture", "globe.americas.fill", ["ai_ethics", "ai_healthcare", "ai_creative_arts", "future_of_ai"]),
    ]

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            ForEach(tracks, id: \.name) { track in
                trackSection(track)
            }
        }
    }

    private func trackSection(_ track: (name: String, icon: String, ids: [String])) -> some View {
        let categories = track.ids.compactMap { id in provider.category(byId: id) }
        let completedCount = categories.filter { cat in
            user.categoryProgressList.first { $0.categoryId == cat.id }?.isComplete ?? false
        }.count

        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: track.icon)
                    .font(.system(size: 14))
                    .foregroundColor(.aiPrimary)
                Text(track.name)
                    .font(.aiTitle())
                Text("\(completedCount)/\(categories.count)")
                    .font(.aiCaption())
                    .foregroundColor(.aiTextSecondary)
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(categories) { category in
                        let locked = isCategoryLocked(category)
                        let progress = user.categoryProgressList.first { $0.categoryId == category.id }
                        CategoryCard(
                            category: category,
                            progress: progress,
                            isLocked: locked,
                            unlockHint: unlockHint(for: category),
                            categoryAccuracy: user.categoryAccuracy(for: category.id)
                        ) {
                            showCategoryDetail = category
                        }
                        .frame(width: 170)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Recommended
    private var recommendedCategory: CategoryData? {
        // Experience-based starting suggestion
        if user.totalLessonsCompleted == 0 {
            switch user.experienceLevel {
            case .beginner: return provider.category(byId: "ai_basics")
            case .familiar: return provider.category(byId: "generative_ai")
            case .regular: return provider.category(byId: "prompt_engineering")
            case .builder: return provider.category(byId: "ai_ethics")
            }
        }
        // Find first unlocked, incomplete category
        for cat in provider.allCategories {
            if !isCategoryLocked(cat) {
                let progress = user.categoryProgressList.first { $0.categoryId == cat.id }
                if !(progress?.isComplete ?? false) {
                    return cat
                }
            }
        }
        return nil
    }

    private func recommendedCard(_ category: CategoryData) -> some View {
        Button { showCategoryDetail = category } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.aiPrimary.opacity(0.15))
                        .frame(width: 50, height: 50)
                    Image(systemName: category.icon)
                        .font(.title2)
                        .foregroundColor(.aiPrimary)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("Recommended for You")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.aiPrimary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    Text(category.name)
                        .font(.aiHeadline())
                        .foregroundColor(.aiTextPrimary)
                }
                Spacer()
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title3)
                    .foregroundColor(.aiPrimary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.aiPrimary.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.aiPrimary.opacity(0.2), lineWidth: 1)
                    )
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
                VStack(spacing: 2) {
                    Text("+25")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.aiWarning)
                    Text("XP")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.aiWarning)
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
                    .stroke(Color.aiWarning.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal)
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

    private func unlockHint(for category: CategoryData) -> String? {
        guard let requiredId = category.unlockRequirement.requiredCategoryId,
              let requiredCategory = provider.category(byId: requiredId) else { return nil }
        switch category.unlockRequirement {
        case .none:
            return nil
        case .completeCategory:
            return "Complete \(requiredCategory.name)"
        case .completeCategoryMinimum:
            return "Complete 2 lessons in \(requiredCategory.name)"
        }
    }
}
