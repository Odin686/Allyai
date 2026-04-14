import SwiftUI

struct FallingWordsGame: View {
    @Bindable var user: UserProfile
    @Environment(\.dismiss) private var dismiss

    @State private var score = 0
    @State private var lives = 3
    @State private var combo = 0
    @State private var maxCombo = 0
    @State private var multiplier = 1
    @State private var isGameOver = false
    @State private var showTutorial = true
    @State private var fallingWords: [FallingWord] = []
    @State private var roundSets: [WordCategory] = []
    @State private var currentSetIndex = 0
    @State private var roundTimeRemaining: Double = 15
    @State private var roundActive = false
    @State private var showRoundIntro = false
    @State private var introCountdown = 3
    @State private var draggedWord: FallingWord?
    @State private var dragOffset: CGSize = .zero
    @State private var dragPosition: CGPoint = .zero
    @State private var showComboText = false
    @State private var lastFeedback: (correct: Bool, text: String)? = nil
    @State private var showFeedback = false
    @State private var bucketHighlight: String? = nil
    @State private var screenSize: CGSize = .zero
    @State private var animationTimer: Timer?
    @State private var roundTimer: Timer?
    @State private var spawnTimer: Timer?

    struct WordCategory {
        let category: String
        let correct: [String]
        let wrong: [String]
    }

    private let allSets: [WordCategory] = [
        WordCategory(category: "AI Models", correct: ["GPT-4", "Claude", "Gemini", "Llama", "Mistral", "DALL-E", "Midjourney"], wrong: ["Python", "Docker", "Linux", "React", "Swift", "Java"]),
        WordCategory(category: "Neural Network Parts", correct: ["Layer", "Node", "Weight", "Bias", "Neuron", "Activation", "Kernel"], wrong: ["Pixel", "Token", "Cloud", "Cache", "Stack", "Queue"]),
        WordCategory(category: "Training Terms", correct: ["Epoch", "Batch", "Loss", "Gradient", "Overfit", "Backprop", "Dropout"], wrong: ["Deploy", "Merge", "Branch", "Debug", "Compile", "Commit"]),
        WordCategory(category: "AI Companies", correct: ["OpenAI", "Google", "Meta", "NVIDIA", "Anthropic", "Cohere", "Hugging Face"], wrong: ["Netflix", "Spotify", "Airbnb", "Uber", "Stripe", "Slack"]),
        WordCategory(category: "AI Applications", correct: ["Chatbot", "Vision", "Search", "Copilot", "Siri", "Alexa", "Translation"], wrong: ["Printer", "Scanner", "Router", "Modem", "Cable", "USB"]),
        WordCategory(category: "NLP Concepts", correct: ["Token", "Embedding", "Attention", "Transformer", "BERT", "Prompt", "Context"], wrong: ["Widget", "Button", "Slider", "Toggle", "Modal", "Grid"]),
        WordCategory(category: "Computer Vision", correct: ["CNN", "YOLO", "Segment", "Detect", "ResNet", "GAN", "Filter"], wrong: ["SQL", "JSON", "REST", "HTTP", "SMTP", "FTP"]),
        WordCategory(category: "ML Types", correct: ["Supervised", "Unsupervised", "Reinforcement", "Transfer", "Few-Shot", "Zero-Shot"], wrong: ["Recursive", "Iterative", "Linear", "Binary", "Boolean", "Static"]),
        WordCategory(category: "AI Ethics", correct: ["Bias", "Fairness", "Privacy", "Consent", "Explainable", "Responsible"], wrong: ["Revenue", "Profit", "Market", "Sales", "Growth", "IPO"]),
        WordCategory(category: "Deep Learning", correct: ["RNN", "LSTM", "Attention", "Encoder", "Decoder", "Diffusion", "LoRA"], wrong: ["HTML", "CSS", "PHP", "Ruby", "Perl", "Bash"]),
    ]

    private var currentSet: WordCategory? {
        guard currentSetIndex < roundSets.count else { return nil }
        return roundSets[currentSetIndex]
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.aiBackground.ignoresSafeArea()

                if showTutorial {
                    GameTutorialView(
                        title: "Falling Words",
                        icon: "arrow.down.circle.fill",
                        color: .aiWarning,
                        rules: [
                            "Words fall from the top of the screen",
                            "Drag matching words into the ✅ bucket",
                            "Drag wrong words into the ❌ bucket",
                            "Build combos for multiplied scores!",
                            "Lose 3 lives and it's game over"
                        ]
                    ) {
                        showTutorial = false
                        screenSize = geo.size
                        startGame()
                    }
                } else if showRoundIntro {
                    roundIntroView
                } else if isGameOver {
                    gameOverView
                } else {
                    gamePlayView
                }
            }
            .onAppear { screenSize = geo.size }
        }
        .onDisappear { stopTimers() }
    }

    // MARK: - Round Intro (Countdown)
    private var roundIntroView: some View {
        VStack(spacing: 20) {
            Text("Round \(currentSetIndex + 1) of \(roundSets.count)")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.aiTextSecondary)

            Text(currentSet?.category ?? "")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.aiPrimary)

            Text("Sort the words!")
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(.aiTextSecondary)

            ZStack {
                Circle()
                    .stroke(Color.aiPrimary.opacity(0.15), lineWidth: 6)
                    .frame(width: 80, height: 80)
                Circle()
                    .trim(from: 0, to: Double(introCountdown) / 3.0)
                    .stroke(Color.aiPrimary, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: introCountdown)
                Text("\(introCountdown)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.aiPrimary)
            }
        }
        .onAppear {
            introCountdown = 3
            countdownTick()
        }
    }

    private func countdownTick() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            introCountdown -= 1
            if introCountdown > 0 {
                countdownTick()
            } else {
                showRoundIntro = false
                startRound()
            }
        }
    }

    // MARK: - Gameplay
    private var gamePlayView: some View {
        ZStack {
            // Header
            VStack(spacing: 0) {
                headerBar
                roundTimerBar
                Spacer()
            }

            // Falling words
            ForEach(fallingWords.filter { !$0.sorted && !$0.missed }) { word in
                wordBubble(word)
            }

            // Buckets at bottom
            VStack {
                Spacer()
                bucketsView
            }

            // Combo popup
            if showComboText && combo >= 2 {
                comboPopup
                    .transition(.scale.combined(with: .opacity))
            }

            // Feedback flash
            if showFeedback, let fb = lastFeedback {
                feedbackFlash(correct: fb.correct, text: fb.text)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    // MARK: - Header
    private var headerBar: some View {
        HStack {
            Button { endGame() } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(.aiTextSecondary)
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
            // Score + multiplier
            HStack(spacing: 6) {
                if multiplier > 1 {
                    Text("\(multiplier)×")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundColor(.aiWarning)
                }
                Text("\(score)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.aiPrimary)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    // MARK: - Round Timer
    private var roundTimerBar: some View {
        VStack(spacing: 6) {
            HStack {
                Text(currentSet?.category ?? "")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.aiPrimary)
                Spacer()
                Text("\(Int(roundTimeRemaining))s")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(roundTimeRemaining <= 5 ? .aiError : .aiTextSecondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.aiPrimary.opacity(0.1))
                    RoundedRectangle(cornerRadius: 3)
                        .fill(roundTimeRemaining <= 5 ? Color.aiError : Color.aiPrimary)
                        .frame(width: geo.size.width * (roundTimeRemaining / 15.0))
                        .animation(.linear(duration: 0.1), value: roundTimeRemaining)
                }
            }
            .frame(height: 4)
        }
        .padding(.horizontal)
        .padding(.top, 6)
    }

    // MARK: - Word Bubble (Draggable)
    private func wordBubble(_ word: FallingWord) -> some View {
        let isDragging = draggedWord?.id == word.id

        return Text(word.text)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: wordGradient(for: word),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: isDragging ? Color.aiPrimary.opacity(0.3) : .black.opacity(0.08), radius: isDragging ? 12 : 4, y: isDragging ? 0 : 2)
            )
            .scaleEffect(isDragging ? 1.15 : 1.0)
            .zIndex(isDragging ? 100 : 0)
            .position(
                x: isDragging ? dragPosition.x : word.x,
                y: isDragging ? dragPosition.y : word.y
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if draggedWord == nil {
                            draggedWord = word
                        }
                        dragPosition = value.location
                        // Highlight bucket on hover
                        checkBucketHover(at: value.location)
                    }
                    .onEnded { value in
                        dropWord(word, at: value.location)
                        draggedWord = nil
                        bucketHighlight = nil
                    }
            )
            .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.7), value: isDragging)
    }

    private func wordGradient(for word: FallingWord) -> [Color] {
        let hues: [Color] = [
            Color(red: 0.35, green: 0.45, blue: 0.85),
            Color(red: 0.45, green: 0.35, blue: 0.75),
            Color(red: 0.3, green: 0.5, blue: 0.7),
            Color(red: 0.4, green: 0.4, blue: 0.8),
        ]
        let idx = abs(word.text.hashValue) % hues.count
        return [hues[idx], hues[(idx + 1) % hues.count]]
    }

    // MARK: - Buckets
    private var bucketsView: some View {
        HStack(spacing: 16) {
            bucket(label: "✅ Belongs", id: "correct", color: .aiSuccess)
            bucket(label: "❌ Doesn't", id: "wrong", color: .aiError)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }

    private func bucket(label: String, id: String, color: Color) -> some View {
        let isHighlighted = bucketHighlight == id

        return VStack(spacing: 6) {
            Image(systemName: id == "correct" ? "tray.and.arrow.down.fill" : "trash.fill")
                .font(.system(size: 22))
                .foregroundColor(isHighlighted ? .white : color)
            Text(label)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(isHighlighted ? .white : color)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(isHighlighted ? color : color.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(color.opacity(isHighlighted ? 0 : 0.3), style: StrokeStyle(lineWidth: 2, dash: [6]))
                )
                .shadow(color: isHighlighted ? color.opacity(0.3) : .clear, radius: 10, y: 0)
        )
        .scaleEffect(isHighlighted ? 1.05 : 1.0)
        .animation(.spring(response: 0.25), value: isHighlighted)
    }

    // MARK: - Combo Popup
    private var comboPopup: some View {
        VStack(spacing: 4) {
            Text("\(combo)× COMBO!")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(.aiWarning)
            if multiplier > 1 {
                Text("Score ×\(multiplier)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.aiWarning.opacity(0.7))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.aiWarning.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.aiWarning.opacity(0.3), lineWidth: 1)
                )
        )
        .position(x: screenSize.width / 2, y: screenSize.height * 0.4)
    }

    // MARK: - Feedback Flash
    private func feedbackFlash(correct: Bool, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(correct ? .aiSuccess : .aiError)
            Text(text)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(correct ? .aiSuccess : .aiError)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill((correct ? Color.aiSuccess : Color.aiError).opacity(0.12))
        )
        .position(x: screenSize.width / 2, y: screenSize.height * 0.15)
    }

    // MARK: - Game Over
    private var gameOverView: some View {
        VStack(spacing: 24) {
            Image(systemName: "arrow.down.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.aiWarning)

            Text("Game Over!")
                .font(.aiLargeTitle)

            Text("\(score)")
                .font(.system(size: 52, weight: .bold, design: .rounded))
                .foregroundColor(.aiPrimary)
            Text("Points")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.aiTextSecondary)

            // Stats
            HStack(spacing: 20) {
                gameOverStat(value: "\(currentSetIndex)", label: "Rounds", icon: "flag.fill", color: .aiPrimary)
                gameOverStat(value: "\(maxCombo)×", label: "Max Combo", icon: "bolt.fill", color: .aiWarning)
                gameOverStat(value: "\(3 - lives)", label: "Mistakes", icon: "xmark.circle", color: .aiError)
            }

            if score > (user.gameHighScores["fallingWords"] ?? 0) {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.aiWarning)
                    Text("New High Score!")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.aiWarning)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.aiWarning.opacity(0.12))
                )
            }

            VStack(spacing: 12) {
                Button {
                    isGameOver = false
                    startGame()
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

    private func gameOverStat(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.aiTextPrimary)
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.aiTextSecondary)
        }
    }

    // MARK: - Game Logic

    private func startGame() {
        score = 0
        lives = 3
        combo = 0
        maxCombo = 0
        multiplier = 1
        fallingWords = []
        currentSetIndex = 0
        roundSets = allSets.shuffled()
        showRoundIntro = true
    }

    private func startRound() {
        guard let set = currentSet else { endGame(); return }
        fallingWords = []
        roundTimeRemaining = 15
        roundActive = true

        // Build words for this round
        let correctCount = min(5, set.correct.count)
        let wrongCount = min(3 + currentSetIndex, set.wrong.count)
        var wordsToSpawn: [(String, Bool)] = []
        for w in set.correct.shuffled().prefix(correctCount) { wordsToSpawn.append((w, true)) }
        for w in set.wrong.shuffled().prefix(wrongCount) { wordsToSpawn.append((w, false)) }
        wordsToSpawn.shuffle()

        // Spawn words with stagger
        let spawnInterval = max(0.6, 1.2 - Double(currentSetIndex) * 0.1)
        var spawnIndex = 0

        spawnTimer?.invalidate()
        spawnTimer = Timer.scheduledTimer(withTimeInterval: spawnInterval, repeats: true) { _ in
            guard spawnIndex < wordsToSpawn.count, roundActive else {
                spawnTimer?.invalidate()
                return
            }
            let (text, isCorrect) = wordsToSpawn[spawnIndex]
            let word = FallingWord(
                text: text,
                isCorrect: isCorrect,
                x: CGFloat.random(in: 60...(screenSize.width - 60)),
                y: -30
            )
            withAnimation(.easeIn(duration: 0.3)) {
                fallingWords.append(word)
            }
            spawnIndex += 1
        }

        // Fall animation - words stop at 2/3 down
        let maxY = screenSize.height * 0.6
        let fallSpeed: CGFloat = 0.8 + CGFloat(currentSetIndex) * 0.15

        animationTimer?.invalidate()
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
            for i in fallingWords.indices where !fallingWords[i].sorted && !fallingWords[i].missed {
                if fallingWords[i].y < maxY {
                    fallingWords[i].y += fallSpeed
                    if fallingWords[i].y > maxY {
                        fallingWords[i].y = maxY + CGFloat.random(in: -30...30)
                        // Slight horizontal drift when settled
                        fallingWords[i].x += CGFloat.random(in: -2...2)
                        fallingWords[i].x = max(50, min(screenSize.width - 50, fallingWords[i].x))
                    }
                }
            }
        }

        // Round countdown
        roundTimer?.invalidate()
        roundTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            roundTimeRemaining -= 0.1
            if roundTimeRemaining <= 0 {
                finishRound()
            }
        }
    }

    private func finishRound() {
        roundActive = false
        stopTimers()

        // Count unsorted correct words as misses
        let missed = fallingWords.filter { $0.isCorrect && !$0.sorted && !$0.missed }
        for word in missed {
            if let idx = fallingWords.firstIndex(where: { $0.id == word.id }) {
                fallingWords[idx].missed = true
            }
            lives -= 1
            if lives <= 0 {
                endGame()
                return
            }
        }

        // Next round
        currentSetIndex += 1
        if currentSetIndex < roundSets.count && lives > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                showRoundIntro = true
            }
        } else {
            endGame()
        }
    }

    private func checkBucketHover(at point: CGPoint) {
        let bucketY = screenSize.height - 80
        if point.y > bucketY - 40 {
            if point.x < screenSize.width / 2 {
                bucketHighlight = "correct"
            } else {
                bucketHighlight = "wrong"
            }
        } else {
            bucketHighlight = nil
        }
    }

    private func dropWord(_ word: FallingWord, at point: CGPoint) {
        guard let idx = fallingWords.firstIndex(where: { $0.id == word.id }), !fallingWords[idx].sorted else { return }

        let bucketY = screenSize.height - 80
        guard point.y > bucketY - 50 else {
            // Not dropped in bucket — snap back
            return
        }

        let droppedInCorrectBucket = point.x < screenSize.width / 2
        let wordIsCorrect = word.isCorrect
        let isRight = (droppedInCorrectBucket && wordIsCorrect) || (!droppedInCorrectBucket && !wordIsCorrect)

        withAnimation(.spring(response: 0.3)) {
            fallingWords[idx].sorted = true
        }

        if isRight {
            // Correct sort
            combo += 1
            maxCombo = max(maxCombo, combo)
            multiplier = min(4, 1 + combo / 3)
            let points = 10 * multiplier
            score += points
            HapticService.shared.success()
            SoundService.shared.play(.correct)

            showFeedbackMessage(correct: true, text: "+\(points) pts")

            if combo >= 2 {
                withAnimation(.spring(response: 0.3)) { showComboText = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation { showComboText = false }
                }
            }
        } else {
            // Wrong sort
            combo = 0
            multiplier = 1
            lives -= 1
            HapticService.shared.error()
            SoundService.shared.play(.wrong)

            showFeedbackMessage(correct: false, text: wordIsCorrect ? "That belongs!" : "Wrong bucket!")

            if lives <= 0 {
                endGame()
            }
        }

        // Check if round is complete (all words sorted)
        let remaining = fallingWords.filter { !$0.sorted && !$0.missed }
        if remaining.isEmpty {
            roundActive = false
            stopTimers()
            currentSetIndex += 1
            if currentSetIndex < roundSets.count && lives > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    showRoundIntro = true
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    endGame()
                }
            }
        }
    }

    private func showFeedbackMessage(correct: Bool, text: String) {
        lastFeedback = (correct: correct, text: text)
        withAnimation(.spring(response: 0.3)) { showFeedback = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation { showFeedback = false }
        }
    }

    private func stopTimers() {
        animationTimer?.invalidate()
        roundTimer?.invalidate()
        spawnTimer?.invalidate()
    }

    private func endGame() {
        stopTimers()
        roundActive = false
        let xp = max(score / 2, 5)
        user.addXP(xp)
        user.todayXP += xp
        user.gamesPlayed += 1
        if score > (user.gameHighScores["fallingWords"] ?? 0) {
            user.gameHighScores["fallingWords"] = score
        }
        isGameOver = true
    }
}

// MARK: - Falling Word Model
struct FallingWord: Identifiable {
    let id = UUID()
    let text: String
    let isCorrect: Bool
    var x: CGFloat
    var y: CGFloat
    var sorted = false
    var missed = false
}
