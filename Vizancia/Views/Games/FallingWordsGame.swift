import SwiftUI

struct FallingWordsGame: View {
    @Bindable var user: UserProfile
    @Environment(\.dismiss) private var dismiss

    @State private var score = 0
    @State private var lives = 3
    @State private var isGameOver = false
    @State private var showTutorial = true
    @State private var currentCategory = ""
    @State private var fallingWords: [FallingWord] = []
    @State private var timer: Timer?
    @State private var spawnTimer: Timer?
    @State private var roundSets: [WordCategory] = []
    @State private var currentSetIndex = 0

    struct WordCategory {
        let category: String
        let correct: [String]
        let wrong: [String]
    }

    private let allSets: [WordCategory] = [
        WordCategory(category: "AI Models", correct: ["GPT", "Claude", "Gemini", "Llama", "Mistral"], wrong: ["Python", "Docker", "Linux", "React", "Swift"]),
        WordCategory(category: "Neural Network Parts", correct: ["Layer", "Node", "Weight", "Bias", "Neuron"], wrong: ["Pixel", "Token", "Cloud", "Cache", "Stack"]),
        WordCategory(category: "Training Terms", correct: ["Epoch", "Batch", "Loss", "Gradient", "Overfit"], wrong: ["Deploy", "Merge", "Branch", "Debug", "Compile"]),
        WordCategory(category: "AI Companies", correct: ["OpenAI", "Google", "Meta", "NVIDIA", "Anthropic"], wrong: ["Netflix", "Spotify", "Airbnb", "Uber", "Stripe"]),
        WordCategory(category: "AI Applications", correct: ["Chatbot", "Vision", "Search", "Filter", "Siri"], wrong: ["Printer", "Scanner", "Router", "Modem", "Cable"]),
    ]

    var body: some View {
        ZStack {
            Color.aiBackground.ignoresSafeArea()

            if showTutorial {
                GameTutorialView(
                    title: "Falling Words",
                    icon: "arrow.down.circle.fill",
                    color: .aiWarning,
                    rules: [
                        "Words fall from the top of the screen",
                        "Tap words that match the category",
                        "Avoid words that don't belong",
                        "Miss 3 correct words and it's over!"
                    ]
                ) { showTutorial = false; startGame() }
            } else if isGameOver {
                gameOverView
            } else {
                gamePlayView
            }
        }
        .onDisappear { stopTimers() }
    }

    // MARK: - Gameplay
    private var gamePlayView: some View {
        ZStack {
            // Header
            VStack {
                HStack {
                    Button { endGame() } label: {
                        Image(systemName: "xmark").font(.title3).foregroundColor(.aiTextSecondary)
                    }
                    Spacer()
                    // Lives
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { i in
                            Image(systemName: i < lives ? "heart.fill" : "heart")
                                .font(.system(size: 14))
                                .foregroundColor(i < lives ? .aiError : .aiTextSecondary.opacity(0.3))
                        }
                    }
                    Spacer()
                    Text("Score: \(score)")
                        .font(.aiRounded(.body, weight: .bold))
                        .foregroundColor(.aiPrimary)
                }
                .padding(.horizontal)

                Text("Tap: \(currentCategory)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.aiPrimary)
                    .padding(.top, 4)

                Spacer()
            }
            .padding(.top)

            // Falling words
            ForEach(fallingWords) { word in
                Text(word.text)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(word.tapped ? .white : .aiTextPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(word.tapped ? (word.isCorrect ? Color.aiSuccess : Color.aiError) : Color.aiCard)
                            .shadow(color: .black.opacity(0.06), radius: 3, y: 2)
                    )
                    .position(x: word.x, y: word.y)
                    .onTapGesture {
                        tapWord(word)
                    }
            }
        }
    }

    // MARK: - Game Over
    private var gameOverView: some View {
        VStack(spacing: 24) {
            Image(systemName: "arrow.down.circle.fill")
                .font(.system(size: 50)).foregroundColor(.aiWarning)
            Text("Game Over!").font(.aiLargeTitle)
            Text("Score: \(score)")
                .font(.system(size: 44, weight: .bold, design: .rounded)).foregroundColor(.aiPrimary)
            if score > (user.gameHighScores["fallingWords"] ?? 0) {
                Text("New High Score!").font(.aiHeadline()).foregroundColor(.aiWarning)
            }
            VStack(spacing: 12) {
                Button { isGameOver = false; startGame() } label: {
                    Text("Play Again").font(.aiHeadline()).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.aiPrimaryGradient))
                }
                Button("Done") { dismiss() }.font(.aiBody()).foregroundColor(.aiTextSecondary)
            }.padding(.horizontal, 30)
        }
    }

    // MARK: - Logic
    private func startGame() {
        score = 0
        lives = 3
        fallingWords = []
        currentSetIndex = 0
        roundSets = allSets.shuffled()
        loadNextCategory()
    }

    private func loadNextCategory() {
        guard currentSetIndex < roundSets.count else { endGame(); return }
        let set = roundSets[currentSetIndex]
        currentCategory = set.category
        fallingWords = []

        // More wrong words as rounds progress (harder)
        let wrongCount = min(3 + currentSetIndex, set.wrong.count)
        var wordsToSpawn: [(String, Bool)] = []
        for w in set.correct { wordsToSpawn.append((w, true)) }
        for w in set.wrong.prefix(wrongCount) { wordsToSpawn.append((w, false)) }
        wordsToSpawn.shuffle()

        // Faster spawn rate as rounds progress
        let spawnInterval = max(0.4, 0.8 - Double(currentSetIndex) * 0.1)
        // Faster fall speed as rounds progress
        let fallSpeed = 1.2 + Double(currentSetIndex) * 0.4

        let screenWidth = UIScreen.main.bounds.width
        var spawnIndex = 0

        spawnTimer?.invalidate()
        spawnTimer = Timer.scheduledTimer(withTimeInterval: spawnInterval, repeats: true) { _ in
            guard spawnIndex < wordsToSpawn.count else {
                spawnTimer?.invalidate()
                // Wait for remaining words to fall, then next category
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    currentSetIndex += 1
                    if lives > 0 { loadNextCategory() } else { endGame() }
                }
                return
            }
            let (text, isCorrect) = wordsToSpawn[spawnIndex]
            let word = FallingWord(
                text: text,
                isCorrect: isCorrect,
                x: CGFloat.random(in: 60...(screenWidth - 60)),
                y: -20
            )
            fallingWords.append(word)
            spawnIndex += 1
        }

        // Animate falling
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            for i in fallingWords.indices {
                if !fallingWords[i].tapped {
                    fallingWords[i].y += fallSpeed
                }
                // Fell off screen
                if fallingWords[i].y > UIScreen.main.bounds.height && !fallingWords[i].tapped {
                    if fallingWords[i].isCorrect {
                        lives -= 1
                        HapticService.shared.error()
                        if lives <= 0 { endGame(); return }
                    }
                    fallingWords[i].tapped = true // Mark as done
                }
            }
        }
    }

    private func tapWord(_ word: FallingWord) {
        guard let idx = fallingWords.firstIndex(where: { $0.id == word.id }), !fallingWords[idx].tapped else { return }
        fallingWords[idx].tapped = true

        if word.isCorrect {
            score += 10
            HapticService.shared.success()
            SoundService.shared.play(.correct)
        } else {
            lives -= 1
            HapticService.shared.error()
            SoundService.shared.play(.wrong)
            if lives <= 0 { endGame() }
        }
    }

    private func stopTimers() {
        timer?.invalidate()
        spawnTimer?.invalidate()
    }

    private func endGame() {
        stopTimers()
        let xp = score
        user.addXP(xp); user.todayXP += xp; user.gamesPlayed += 1
        if score > (user.gameHighScores["fallingWords"] ?? 0) {
            user.gameHighScores["fallingWords"] = score
        }
        isGameOver = true
    }
}

struct FallingWord: Identifiable {
    let id = UUID()
    let text: String
    let isCorrect: Bool
    var x: CGFloat
    var y: CGFloat
    var tapped = false
}
