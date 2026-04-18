import SwiftUI

struct WordScrambleGame: View {
    @Bindable var user: UserProfile
    @Environment(\.dismiss) private var dismiss

    @State private var score = 0
    @State private var round = 0
    @State private var isGameOver = false
    @State private var showTutorial = true
    @State private var timeRemaining = 10
    @State private var timer: Timer?
    @State private var currentWord = ""
    @State private var currentHint = ""
    @State private var scrambledLetters: [ScrambleLetter] = []
    @State private var selectedLetters: [ScrambleLetter] = []
    @State private var flashColor: Color = .clear
    @State private var words: [(word: String, hint: String)] = []

    private let totalRounds = 8

    private let allWords: [(word: String, hint: String)] = [
        ("TOKEN", "A chunk of text AI processes"),
        ("MODEL", "A trained AI system"),
        ("AGENT", "AI that acts autonomously"),
        ("LAYER", "One level in a neural network"),
        ("EPOCH", "One pass through training data"),
        ("BATCH", "A group of training examples"),
        ("TRAIN", "Teaching AI with data"),
        ("LEARN", "What machines do with data"),
        ("SCALE", "Making AI bigger or faster"),
        ("CLOUD", "Remote servers for AI"),
        ("EMBED", "Converting text to numbers"),
        ("PROMPT", "Input you give to AI"),
        ("NEURAL", "Brain-inspired computing"),
        ("WEIGHT", "Connection strength in AI"),
        ("INPUT", "Data fed into a model"),
        ("PIXEL", "Tiny dot in an image"),
        ("BIAS", "Unfair patterns in AI"),
        ("DATA", "Information AI learns from"),
        ("NODE", "Single unit in a network"),
        ("LOSS", "How wrong the AI is"),
    ]

    var body: some View {
        ZStack {
            Color.aiBackground.ignoresSafeArea()

            if showTutorial {
                GameTutorialView(
                    title: "Word Scramble",
                    icon: "textformat.abc.dottedunderline",
                    color: .aiOrange,
                    rules: [
                        "An AI term is scrambled up",
                        "Tap letters in the right order to spell it",
                        "Use the hint if you're stuck",
                        "10 seconds per word — be quick!"
                    ]
                ) { showTutorial = false; startGame() }
            } else if isGameOver {
                gameOverView
            } else {
                gamePlayView
            }

            flashColor.opacity(0.15).ignoresSafeArea()
                .allowsHitTesting(false)
                .animation(.easeOut(duration: 0.3), value: flashColor)
        }
        .onDisappear { timer?.invalidate() }
    }

    // MARK: - Gameplay
    private var gamePlayView: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Button { endGame() } label: {
                    Image(systemName: "xmark").font(.title3).foregroundColor(.aiTextSecondary)
                }
                Spacer()
                Text("\(timeRemaining)s")
                    .font(.aiRounded(.title2, weight: .bold))
                    .foregroundColor(timeRemaining <= 3 ? .aiError : .aiPrimary)
                Spacer()
                Text("Score: \(score)")
                    .font(.aiRounded(.body, weight: .bold))
                    .foregroundColor(.aiPrimary)
            }
            .padding(.horizontal)

            Text("Round \(round + 1)/\(totalRounds)")
                .font(.aiCaption())
                .foregroundColor(.aiTextSecondary)

            Spacer()

            // Hint
            Text(currentHint)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.aiTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Selected letters (answer area)
            HStack(spacing: 6) {
                ForEach(0..<currentWord.count, id: \.self) { i in
                    if i < selectedLetters.count {
                        letterTile(selectedLetters[i].character, filled: true) {
                            // Tap to remove
                            let letter = selectedLetters[i]
                            selectedLetters.remove(at: i)
                            if let idx = scrambledLetters.firstIndex(where: { $0.id == letter.id }) {
                                scrambledLetters[idx].isUsed = false
                            }
                        }
                    } else {
                        emptySlot
                    }
                }
            }

            // Scrambled letters
            HStack(spacing: 6) {
                ForEach(scrambledLetters) { letter in
                    if !letter.isUsed {
                        letterTile(letter.character, filled: false) {
                            selectLetter(letter)
                        }
                    } else {
                        Color.clear.frame(width: 44, height: 44)
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical)
    }

    private func letterTile(_ char: String, filled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(char)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(filled ? .white : .aiPrimary)
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(filled ? Color.aiPrimary : Color.aiCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.aiPrimary.opacity(filled ? 0 : 0.3), lineWidth: 1.5)
                        )
                )
        }
    }

    private var emptySlot: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(Color.aiTextSecondary.opacity(0.2), style: StrokeStyle(lineWidth: 1.5, dash: [5]))
            .frame(width: 44, height: 44)
    }

    // MARK: - Game Over
    private var gameOverView: some View {
        VStack(spacing: 24) {
            Image(systemName: "textformat.abc.dottedunderline")
                .font(.system(size: 50)).foregroundColor(.aiOrange)
            Text("Word Master!").font(.aiLargeTitle)
            Text("Score: \(score)")
                .font(.system(size: 44, weight: .bold, design: .rounded)).foregroundColor(.aiPrimary)
            if score > (user.gameHighScores["wordScramble"] ?? 0) {
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
        words = allWords.shuffled()
        score = 0
        round = 0
        loadWord()
    }

    private func loadWord() {
        guard round < totalRounds, !words.isEmpty else { endGame(); return }
        let pair = words.removeFirst()
        currentWord = pair.word
        currentHint = pair.hint
        selectedLetters = []
        scrambledLetters = currentWord.map { char in
            ScrambleLetter(character: String(char))
        }.shuffled()
        timeRemaining = 10
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                // Time's up — move to next
                timer?.invalidate()
                flashColor = .aiError
                HapticService.shared.error()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { flashColor = .clear }
                round += 1
                if round < totalRounds { loadWord() } else { endGame() }
            }
        }
    }

    private func selectLetter(_ letter: ScrambleLetter) {
        if let idx = scrambledLetters.firstIndex(where: { $0.id == letter.id }) {
            scrambledLetters[idx].isUsed = true
        }
        selectedLetters.append(letter)
        HapticService.shared.lightTap()

        // Check if complete
        if selectedLetters.count == currentWord.count {
            let attempt = selectedLetters.map { $0.character }.joined()
            if attempt == currentWord {
                score += 10 + timeRemaining
                flashColor = .aiSuccess
                HapticService.shared.success()
                SoundService.shared.play(.correct)
            } else {
                flashColor = .aiError
                HapticService.shared.error()
                SoundService.shared.play(.wrong)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { flashColor = .clear }
            timer?.invalidate()
            round += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if round < totalRounds { loadWord() } else { endGame() }
            }
        }
    }

    private func endGame() {
        timer?.invalidate()
        let xp = score
        user.addXP(xp); user.todayXP += xp; user.gamesPlayed += 1
        if score > (user.gameHighScores["wordScramble"] ?? 0) {
            user.gameHighScores["wordScramble"] = score
        }
        GameKitService.shared.submitTotalXP(user.totalXP)
        isGameOver = true
    }
}

struct ScrambleLetter: Identifiable {
    let id = UUID()
    let character: String
    var isUsed = false
}
