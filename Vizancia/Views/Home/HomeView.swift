import SwiftUI

struct HomeView: View {
    @Bindable var user: UserProfile
    @State private var showCategoryDetail: CategoryData?
    @State private var xpFloatText = ""
    @State private var showXPFloat = false
    @State private var showPracticeMistakes = false
    @State private var showDailyChallenge = false
    @State private var showQuickPlay: LessonData?
    @State private var quickPlayCategory: CategoryData?
    @State private var showContinueLesson: LessonData?
    @State private var continueCategory: CategoryData?

    private let provider = LessonContentProvider.shared
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Greeting
                    greetingBanner
                        .padding(.horizontal)

                    // Continue Learning
                    if let continueInfo = continueWhere {
                        continueCard(category: continueInfo.0, lesson: continueInfo.1)
                    }

                    // Header Stats
                    headerSection

                    // Daily Goal + Daily Challenge
                    HStack(spacing: 12) {
                        DailyGoalWidget(user: user)
                        if !user.hasCompletedDailyChallenge {
                            dailyChallengeCompact
                        }
                    }
                    .padding(.horizontal)

                    // Quick Play
                    quickPlayButton

                    // Recommended Next
                    if let recommended = recommendedCategory {
                        recommendedCard(recommended)
                    }

                    // Practice Mistakes
                    if !user.missedQuestionIds.isEmpty {
                        practiceMistakesCard
                    }

                    // Divider
                    Rectangle()
                        .fill(Color.aiTextSecondary.opacity(0.08))
                        .frame(height: 1)
                        .padding(.horizontal)

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
            .fullScreenCover(item: $showQuickPlay) { lesson in
                if let cat = quickPlayCategory {
                    LessonView(user: user, lesson: lesson, category: cat)
                }
            }
            .fullScreenCover(item: $showContinueLesson) { lesson in
                if let cat = continueCategory {
                    LessonView(user: user, lesson: lesson, category: cat)
                }
            }
        }
    }
    
    // MARK: - Greeting
    private var greetingBanner: some View {
        let name = user.userName.isEmpty ? user.name : user.userName
        let displayName = (name == "Learner" || name.isEmpty) ? "" : ", \(name)"
        let greeting: String = {
            let hour = Calendar.current.component(.hour, from: Date())
            if hour < 12 { return "Good morning\(displayName)!" }
            if hour < 17 { return "Good afternoon\(displayName)!" }
            return "Good evening\(displayName)!"
        }()

        return HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.aiTextPrimary)
                Text("What shall we learn today?")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.aiTextSecondary)
            }
            Spacer()
            if user.currentStreak > 0 {
                StreakBadge(streak: user.currentStreak)
            }
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
                LevelBadge(level: user.currentLevel, size: 28)
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
        ("Start Here", "star.fill", ["ai_basics", "how_ai_learns", "ai_history"]),
        ("Level Up", "arrow.up.circle.fill", ["generative_ai", "prompt_engineering", "ai_at_work"]),
        ("Go Deeper", "magnifyingglass", ["ai_vocabulary", "ai_under_hood", "ai_tools"]),
        ("Explore", "globe.americas.fill", ["ai_ethics", "ai_healthcare", "ai_creative_arts", "future_of_ai"]),
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
        let allComplete = completedCount == categories.count && categories.count > 0

        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: allComplete ? "checkmark.circle.fill" : track.icon)
                    .font(.system(size: 14))
                    .foregroundColor(allComplete ? .aiSuccess : .aiPrimary)
                Text(track.name)
                    .font(.aiTitle())
                Text("\(completedCount)/\(categories.count)")
                    .font(.aiCaption())
                    .foregroundColor(allComplete ? .aiSuccess : .aiTextSecondary)
                if allComplete {
                    Text("Complete!")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.aiSuccess)
                }
                Spacer()
            }
            .padding(.horizontal)

            if !allComplete {
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
            continueCategory = category
            showContinueLesson = lesson
            HapticService.shared.mediumTap()
            SoundService.shared.play(.whoosh)
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

    // MARK: - Daily Challenge Compact
    private var dailyChallengeCompact: some View {
        Button { showDailyChallenge = true } label: {
            VStack(spacing: 8) {
                Image(systemName: "star.circle.fill")
                    .font(.title2)
                    .foregroundColor(.aiWarning)
                Text("Daily")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.aiTextPrimary)
                Text("+25 XP")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.aiWarning)
            }
            .frame(width: 80)
            .padding(.vertical, 12)
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
    }

    // MARK: - Quick Play
    private var quickPlayButton: some View {
        Button {
            startQuickPlay()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Quick Play")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Jump into a random lesson")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
                Image(systemName: "shuffle")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.aiPrimaryGradient)
                    .shadow(color: .aiPrimary.opacity(0.3), radius: 8, y: 4)
            )
        }
        .padding(.horizontal)
    }

    private func startQuickPlay() {
        let unlocked = provider.allCategories.filter { !isCategoryLocked($0) }
        guard let cat = unlocked.randomElement() else { return }
        let progress = user.categoryProgressList.first { $0.categoryId == cat.id }
        // Pick first incomplete lesson, or random if all done
        let incomplete = cat.lessons.first { lesson in
            !(progress?.completedLessonIds.contains(lesson.id) ?? false)
        }
        let lesson = incomplete ?? cat.lessons.randomElement()
        guard let selectedLesson = lesson else { return }
        quickPlayCategory = cat
        showQuickPlay = selectedLesson
        HapticService.shared.mediumTap()
        SoundService.shared.play(.whoosh)
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
