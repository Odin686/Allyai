import SwiftUI

struct AIPairsGame: View {
    @Bindable var user: UserProfile
    @Environment(\.dismiss) private var dismiss

    // Card state
    @State private var cards: [PairCard] = []
    @State private var flippedIndices: [Int] = []
    @State private var matchedIds: Set<String> = []
    @State private var flipAllowed = false

    // Question state
    @State private var currentQuestion: Question?
    @State private var selectedAnswer = ""
    @State private var showQuestion = false
    @State private var showAnswerResult = false
    @State private var answerCorrect = false
    @State private var flipsEarned = 0

    // Game state
    @State private var score = 0
    @State private var questionsAnswered = 0
    @State private var isGameOver = false
    @State private var showTutorial = true
    @State private var allQuestions: [Question] = []

    private let gridSize = 4 // 4x4 = 16 cards = 8 pairs
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)

    private let pairData: [(symbol: String, label: String)] = [
        ("brain.head.profile", "Neural\nNetwork"),
        ("cpu", "Machine\nLearning"),
        ("text.bubble", "Chatbot"),
        ("eye", "Computer\nVision"),
        ("waveform", "Speech\nRecognition"),
        ("lock.shield", "AI\nSafety"),
        ("chart.bar", "Data\nAnalytics"),
        ("sparkles", "Generative\nAI"),
    ]

    var body: some View {
        ZStack {
            Color.aiBackground.ignoresSafeArea()

            if showTutorial {
                GameTutorialView(
                    title: "AI Pairs",
                    icon: "square.grid.3x3.fill",
                    color: .aiPrimary,
                    rules: [
                        "Match pairs of AI concept cards",
                        "Answer a question to earn card flips",
                        "Correct = flip 2 cards, Wrong = cards shuffle",
                        "Find all 8 pairs to win!"
                    ]
                ) { showTutorial = false; setupGame() }
            } else if isGameOver {
                gameOverView
            } else if showQuestion, let q = currentQuestion {
                questionView(q)
            } else {
                gameBoard
            }
        }
    }

    // MARK: - Game Board
    private var gameBoard: some View {
        VStack(spacing: 16) {
            // Header
            gameBoardHeader

            // Pairs remaining
            let remaining = 8 - matchedIds.count / 2
            Text("\(remaining) pairs remaining")
                .font(.aiCaption())
                .foregroundColor(.aiTextSecondary)

            // Card Grid
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                    cardView(card: card, index: index)
                }
            }
            .padding(.horizontal)

            Spacer()

            // Tap to answer
            if !flipAllowed {
                Button {
                    loadQuestion()
                    showQuestion = true
                } label: {
                    Text("Answer Question to Flip Cards")
                        .font(.aiHeadline())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.aiPrimaryGradient))
                }
                .padding(.horizontal)
            } else {
                Text("Tap 2 cards to reveal!")
                    .font(.aiHeadline())
                    .foregroundColor(.aiPrimary)
            }
        }
        .padding(.vertical)
    }

    private var gameBoardHeader: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(.aiTextSecondary)
            }
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "square.grid.3x3.fill")
                    .foregroundColor(.aiPrimary)
                Text("AI Pairs")
                    .font(.aiCaption())
                    .foregroundColor(.aiPrimary)
            }
            Spacer()
            Text("Score: \(score)")
                .font(.aiRounded(.body, weight: .bold))
                .foregroundColor(.aiPrimary)
        }
        .padding(.horizontal)
    }

    // MARK: - Card View
    private func cardView(card: PairCard, index: Int) -> some View {
        let isFlipped = flippedIndices.contains(index)
        let isMatched = matchedIds.contains(card.pairId)
        let showFace = isFlipped || isMatched

        return Button {
            guard flipAllowed, !isMatched, !isFlipped, flippedIndices.count < 2 else { return }
            flipCard(at: index)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isMatched ? Color.aiSuccess.opacity(0.15) : showFace ? Color.aiPrimary.opacity(0.1) : Color.aiPrimary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isMatched ? Color.aiSuccess.opacity(0.4) : showFace ? Color.aiPrimary.opacity(0.3) : Color.clear, lineWidth: 1.5)
                    )

                if isMatched {
                    VStack(spacing: 4) {
                        Image(systemName: card.symbol)
                            .font(.system(size: 20))
                            .foregroundColor(.aiSuccess)
                        Text(card.label)
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundColor(.aiSuccess)
                            .multilineTextAlignment(.center)
                    }
                } else if showFace {
                    VStack(spacing: 4) {
                        Image(systemName: card.symbol)
                            .font(.system(size: 20))
                            .foregroundColor(.aiPrimary)
                        Text(card.label)
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundColor(.aiTextPrimary)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    Image(systemName: "questionmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .frame(height: 75)
        }
        .disabled(isMatched || !flipAllowed)
    }

    // MARK: - Question View
    private func questionView(_ q: Question) -> some View {
        VStack(spacing: 0) {
            questionHeader

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    Text(q.questionText)
                        .font(.aiBody())
                        .foregroundColor(.aiTextPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)

                    if showAnswerResult {
                        answerResultBanner(q)
                    } else {
                        questionOptions(q)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }

            if showAnswerResult {
                answerResultButton
            }
        }
    }

    private var questionHeader: some View {
        HStack {
            Button { showQuestion = false } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(.aiTextSecondary)
            }
            Spacer()
            Text("Answer to Flip Cards")
                .font(.aiCaption())
                .foregroundColor(.aiPrimary)
            Spacer()
            Text("Score: \(score)")
                .font(.aiRounded(.body, weight: .bold))
                .foregroundColor(.aiPrimary)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }

    private func answerResultBanner(_ q: Question) -> some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: answerCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(answerCorrect ? .aiSuccess : .aiError)
                    .font(.title2)
                Text(answerCorrect ? "Correct! Flip 2 cards!" : "Wrong — cards shuffled!")
                    .font(.aiHeadline())
                    .foregroundColor(answerCorrect ? .aiSuccess : .aiError)
                Spacer()
            }
            Text(q.explanation)
                .font(.aiBody())
                .foregroundColor(.aiTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill((answerCorrect ? Color.aiSuccess : Color.aiError).opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke((answerCorrect ? Color.aiSuccess : Color.aiError).opacity(0.3), lineWidth: 1)
                )
        )
    }

    private func questionOptions(_ q: Question) -> some View {
        let shuffledOptions = q.options.shuffled()
        return ForEach(shuffledOptions, id: \.self) { option in
            Button {
                checkQuestionAnswer(option, for: q)
            } label: {
                Text(option)
                    .font(.aiBody())
                    .foregroundColor(.aiTextPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.aiCard)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.aiTextSecondary.opacity(0.15), lineWidth: 1)
                            )
                    )
            }
        }
    }

    private var answerResultButton: some View {
        VStack {
            Divider()
            Button {
                showAnswerResult = false
                showQuestion = false
                if answerCorrect {
                    flipAllowed = true
                }
            } label: {
                Text(answerCorrect ? "Now Flip Cards!" : "Continue")
                    .font(.aiHeadline())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.aiPrimaryGradient))
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .background(Color.aiBackground)
    }

    // MARK: - Game Over
    private var gameOverView: some View {
        VStack(spacing: 24) {
            Image(systemName: "square.grid.3x3.fill")
                .font(.system(size: 50))
                .foregroundColor(.aiPrimary)
            Text("All Pairs Found!")
                .font(.aiLargeTitle)
            Text("Score: \(score)")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundColor(.aiPrimary)
            Text("\(questionsAnswered) questions answered")
                .font(.aiBody())
                .foregroundColor(.aiTextSecondary)
            if score > (user.gameHighScores["aiPairs"] ?? 0) {
                Text("New High Score!")
                    .font(.aiHeadline())
                    .foregroundColor(.aiWarning)
            }
            VStack(spacing: 12) {
                Button {
                    isGameOver = false
                    setupGame()
                } label: {
                    Text("Play Again")
                        .font(.aiHeadline())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.aiPrimaryGradient))
                }
                Button("Done") { dismiss() }
                    .font(.aiBody())
                    .foregroundColor(.aiTextSecondary)
            }
            .padding(.horizontal, 30)
        }
    }

    // MARK: - Logic
    private func setupGame() {
        // Create 8 pairs (16 cards)
        var newCards: [PairCard] = []
        for pair in pairData {
            let pairId = UUID().uuidString
            newCards.append(PairCard(pairId: pairId, symbol: pair.symbol, label: pair.label))
            newCards.append(PairCard(pairId: pairId, symbol: pair.symbol, label: pair.label))
        }
        cards = newCards.shuffled()
        matchedIds = []
        flippedIndices = []
        flipAllowed = false
        score = 0
        questionsAnswered = 0

        // Load questions pool
        let categories = LessonContentProvider.shared.allCategories
        let lessons = categories.flatMap { $0.lessons }
        let qs = lessons.flatMap { $0.questions }
        allQuestions = qs.filter { $0.type == .multipleChoice || $0.type == .trueFalse }.shuffled()
    }

    private func loadQuestion() {
        if allQuestions.isEmpty {
            let categories = LessonContentProvider.shared.allCategories
            let lessons = categories.flatMap { $0.lessons }
            let qs = lessons.flatMap { $0.questions }
            allQuestions = qs.filter { $0.type == .multipleChoice || $0.type == .trueFalse }.shuffled()
        }
        currentQuestion = allQuestions.removeFirst()
        selectedAnswer = ""
        showAnswerResult = false
    }

    private func checkQuestionAnswer(_ answer: String, for question: Question) {
        answerCorrect = answer == question.correctAnswer
        questionsAnswered += 1

        if answerCorrect {
            score += 10
            HapticService.shared.success()
            SoundService.shared.play(.correct)
        } else {
            // Shuffle unmatched cards
            HapticService.shared.error()
            SoundService.shared.play(.wrong)
            shuffleUnmatchedCards()
        }
        showAnswerResult = true
    }

    private func flipCard(at index: Int) {
        flippedIndices.append(index)
        HapticService.shared.lightTap()

        if flippedIndices.count == 2 {
            flipAllowed = false
            let first = flippedIndices[0]
            let second = flippedIndices[1]

            if cards[first].pairId == cards[second].pairId {
                // Match found
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.spring(response: 0.4)) {
                        matchedIds.insert(cards[first].pairId)
                        score += 25
                    }
                    flippedIndices = []
                    HapticService.shared.success()

                    // Check win
                    if matchedIds.count == pairData.count {
                        endGame()
                    }
                }
            } else {
                // No match — flip back
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation {
                        flippedIndices = []
                    }
                }
            }
        }
    }

    private func shuffleUnmatchedCards() {
        var unmatchedIndices: [Int] = []
        var unmatchedCards: [PairCard] = []
        for (i, card) in cards.enumerated() {
            if !matchedIds.contains(card.pairId) {
                unmatchedIndices.append(i)
                unmatchedCards.append(card)
            }
        }
        unmatchedCards.shuffle()
        for (i, idx) in unmatchedIndices.enumerated() {
            cards[idx] = unmatchedCards[i]
        }
        flippedIndices = []
    }

    private func endGame() {
        let xp = score
        user.addXP(xp)
        user.todayXP += xp
        user.gamesPlayed += 1
        if score > (user.gameHighScores["aiPairs"] ?? 0) {
            user.gameHighScores["aiPairs"] = score
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isGameOver = true
        }
    }
}

// MARK: - Pair Card Model
struct PairCard: Identifiable {
    let id = UUID()
    let pairId: String
    let symbol: String
    let label: String
}
