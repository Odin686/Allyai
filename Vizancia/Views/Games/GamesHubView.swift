import SwiftUI

struct GamesHubView: View {
    @Bindable var user: UserProfile
    @State private var showGame: GameType?
    @State private var showDuel = false
    @State private var showLesson: PlayLessonLaunch?

    private let provider = LessonContentProvider.shared

    struct PlayLessonLaunch: Identifiable {
        let id = UUID()
        let lesson: LessonData
        let category: CategoryData
    }

    private let games: [(type: GameType, title: String, description: String, icon: String, color: Color)] = [
        (.speedRound, "Speed Round", "Answer as many questions as you can in 60 seconds!", "bolt.fill", .aiOrange),
        (.aiPairs, "AI Pairs", "Match AI concept cards by answering questions!", "square.grid.3x3.fill", .aiPrimary),
        (.buzzwordBuster, "Buzzword Buster", "True or false: Is this AI term real or made up?", "textformat.abc", .aiSecondary),
        (.jargonMatch, "Jargon Match", "Match AI terms to definitions — fast!", "character.book.closed", .aiSecondary),
        (.aiTimeline, "AI Timeline", "Put AI milestones in the right order!", "clock.arrow.circlepath", .aiOrange),
        (.factOrFiction, "Fact or Fiction", "Is this AI claim true or false?", "hand.thumbsup.fill", .aiSuccess),
        (.whoMadeIt, "Who Made It?", "Match AI tools to their creators!", "building.2.fill", .aiPrimary),
        (.wordScramble, "Word Scramble", "Unscramble AI terms before time runs out!", "textformat.abc.dottedunderline", .aiOrange),
        (.fallingWords, "Falling Words", "Tap the right words before they fall!", "arrow.down.circle.fill", .aiWarning),
        (.memoryGrid, "Memory Grid", "Flip cards and match AI pairs!", "square.grid.3x3.topleft.filled", .aiSecondary),
        (.wordSearch, "Word Search", "Find hidden AI terms in the grid!", "magnifyingglass", .aiPrimary),
    ]

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

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Greeting
                    greetingHeader
                        .padding(.horizontal)

                    // Continue Learning (hero card)
                    if let continueInfo = continueWhere {
                        continueCard(category: continueInfo.0, lesson: continueInfo.1)
                    }

                    // 1v1 Duel Quick Access
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 6) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.aiPrimary)
                            Text("Quick Match")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.aiTextSecondary)
                                .textCase(.uppercase)
                        }
                        .padding(.horizontal, 4)

                        Button { showDuel = true } label: {
                            HStack(spacing: 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.aiPrimary, Color.aiGradientEnd],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ).opacity(0.15)
                                        )
                                        .frame(width: 52, height: 52)
                                    Image(systemName: "person.2.fill")
                                        .font(.title3)
                                        .foregroundColor(.aiPrimary)
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("1v1 Duel")
                                        .font(.aiHeadline())
                                        .foregroundColor(.aiTextPrimary)
                                    Text("Challenge a friend — who knows AI better?")
                                        .font(.aiCaption())
                                        .foregroundColor(.aiTextSecondary)
                                        .lineLimit(1)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.aiTextSecondary)
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.aiCard)
                                    .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.aiPrimary.opacity(0.12), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal)

                    // Solo Games
                    HStack {
                        HStack(spacing: 6) {
                            Image(systemName: "gamecontroller.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.aiSecondary)
                            Text("Solo Games")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.aiTextSecondary)
                                .textCase(.uppercase)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)

                    ForEach(games, id: \.type) { game in
                        GameCard(
                            title: game.title,
                            description: game.description,
                            icon: game.icon,
                            color: game.color,
                            highScore: user.gameHighScores[game.type.rawValue] ?? 0
                        ) {
                            showGame = game.type
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color.aiBackground.ignoresSafeArea())
            .navigationTitle("Play")
            .fullScreenCover(item: $showGame) { type in
                gameView(for: type)
            }
            .fullScreenCover(isPresented: $showDuel) {
                DuelView(user: user)
            }
            .fullScreenCover(item: $showLesson) { launch in
                LessonView(user: user, lesson: launch.lesson, category: launch.category)
            }
        }
    }

    // MARK: - Greeting
    private var greetingHeader: some View {
        let name = user.userName.isEmpty ? user.name : user.userName
        let displayName = (name == "Learner" || name.isEmpty) ? "there" : name
        let greeting: String = {
            let hour = Calendar.current.component(.hour, from: Date())
            if hour < 12 { return "Good morning, \(displayName)" }
            if hour < 17 { return "Good afternoon, \(displayName)" }
            return "Good evening, \(displayName)"
        }()

        return HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.aiTextPrimary)
                HStack(spacing: 12) {
                    Label("\(user.totalXP) XP", systemImage: "star.fill")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.aiPrimary)
                    if user.currentStreak > 0 {
                        Label("\(user.currentStreak) day streak", systemImage: "flame.fill")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.aiOrange)
                    }
                }
            }
            Spacer()
            HeartsDisplay(hearts: user.hearts, showTimer: true, heartsLastRefill: user.heartsLastRefill)
        }
    }

    // MARK: - Continue Card
    private func continueCard(category: CategoryData, lesson: LessonData) -> some View {
        Button {
            showLesson = PlayLessonLaunch(lesson: lesson, category: category)
            HapticService.shared.mediumTap()
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 48, height: 48)
                    Image(systemName: "play.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("CONTINUE")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .tracking(1)
                    Text(lesson.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Text(category.name)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color.aiPrimary, Color.aiGradientEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .aiPrimary.opacity(0.3), radius: 8, y: 4)
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

    @ViewBuilder
    private func gameView(for type: GameType) -> some View {
        switch type {
        case .speedRound: SpeedRoundGame(user: user)
        case .aiPairs: AIPairsGame(user: user)
        case .buzzwordBuster: BuzzwordBusterGame(user: user)
        case .jargonMatch: JargonMatchGame(user: user)
        case .aiTimeline: AITimelineGame(user: user)
        case .factOrFiction: FactOrFictionGame(user: user)
        case .whoMadeIt: WhoMadeItGame(user: user)
        case .wordScramble: WordScrambleGame(user: user)
        case .fallingWords: FallingWordsGame(user: user)
        case .memoryGrid: MemoryGridGame(user: user)
        case .wordSearch: WordSearchGame(user: user)
        }
    }
}

// MARK: - Game Card
struct GameCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let highScore: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(color.opacity(0.15))
                        .frame(width: 56, height: 56)
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.aiHeadline())
                        .foregroundColor(.aiTextPrimary)
                    Text(description)
                        .font(.aiCaption())
                        .foregroundColor(.aiTextSecondary)
                        .lineLimit(2)
                }
                Spacer()
                VStack(spacing: 2) {
                    if highScore > 0 {
                        Text("Best")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(.aiTextSecondary)
                        Text("\(highScore)")
                            .font(.aiRounded(.body, weight: .bold))
                            .foregroundColor(color)
                    }
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.aiTextSecondary)
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
}
