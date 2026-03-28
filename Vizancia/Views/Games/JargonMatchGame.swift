import SwiftUI

struct JargonMatchGame: View {
    @Bindable var user: UserProfile
    @Environment(\.dismiss) private var dismiss

    @State private var score = 0
    @State private var timeRemaining = 30
    @State private var isGameOver = false
    @State private var timer: Timer?
    @State private var currentTerm: JargonTerm?
    @State private var shuffledOptions: [String] = []
    @State private var flashColor: Color = .clear
    @State private var showTutorial = true
    @State private var terms: [JargonTerm] = []

    var body: some View {
        ZStack {
            Color.aiBackground.ignoresSafeArea()

            if showTutorial {
                GameTutorialView(
                    title: "Jargon Match",
                    icon: "character.book.closed",
                    color: .aiPrimary,
                    rules: [
                        "You'll see an AI term",
                        "Pick the correct definition fast",
                        "30 seconds on the clock",
                        "How many can you match?"
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
        VStack(spacing: 16) {
            gameHeader

            Spacer()

            if let term = currentTerm {
                termDisplay(term)
                optionsList(term)
            }

            Spacer()
        }
        .padding(.top)
    }

    private var gameHeader: some View {
        HStack {
            Button { endGame() } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(.aiTextSecondary)
            }
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "clock.fill")
                    .foregroundColor(timeRemaining <= 10 ? .aiError : .aiPrimary)
                Text("\(timeRemaining)s")
                    .font(.aiRounded(.title2, weight: .bold))
                    .foregroundColor(timeRemaining <= 10 ? .aiError : .aiPrimary)
            }
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundColor(.aiWarning)
                Text("\(score)")
                    .font(.aiRounded(.title2, weight: .bold))
                    .foregroundColor(.aiTextPrimary)
            }
        }
        .padding(.horizontal)
    }

    private func termDisplay(_ term: JargonTerm) -> some View {
        VStack(spacing: 8) {
            Text("What is")
                .font(.aiCaption())
                .foregroundColor(.aiTextSecondary)
            Text(term.term)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.aiPrimary)
                .multilineTextAlignment(.center)
            Text("?")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.aiPrimary)
        }
        .padding(.horizontal)
    }

    private func optionsList(_ term: JargonTerm) -> some View {
        VStack(spacing: 10) {
            ForEach(shuffledOptions, id: \.self) { option in
                Button {
                    checkAnswer(option, for: term)
                } label: {
                    Text(option)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
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
        .padding(.horizontal)
    }

    // MARK: - Game Over
    private var gameOverView: some View {
        VStack(spacing: 24) {
            Image(systemName: "character.book.closed")
                .font(.system(size: 50))
                .foregroundColor(.aiPrimary)
            Text("Time's Up!")
                .font(.aiLargeTitle)
            Text("Score: \(score)")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundColor(.aiPrimary)

            if score > (user.gameHighScores["jargonMatch"] ?? 0) {
                Text("New High Score!")
                    .font(.aiHeadline())
                    .foregroundColor(.aiWarning)
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

    // MARK: - Logic
    private func startGame() {
        terms = JargonTerm.all.shuffled()
        score = 0
        timeRemaining = 30
        nextTerm()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                endGame()
            }
        }
    }

    private func nextTerm() {
        if terms.isEmpty {
            terms = JargonTerm.all.shuffled()
        }
        let term = terms.removeFirst()
        currentTerm = term

        // Build 4 options: 1 correct + 3 wrong
        var options = [term.definition]
        let otherDefs = JargonTerm.all
            .filter { $0.term != term.term }
            .map { $0.definition }
            .shuffled()
            .prefix(3)
        options.append(contentsOf: otherDefs)
        shuffledOptions = options.shuffled()
    }

    private func checkAnswer(_ answer: String, for term: JargonTerm) {
        if answer == term.definition {
            score += 1
            flashColor = .aiSuccess
            HapticService.shared.success()
            SoundService.shared.play(.correct)
        } else {
            flashColor = .aiError
            HapticService.shared.error()
            SoundService.shared.play(.wrong)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { flashColor = .clear }
        nextTerm()
    }

    private func endGame() {
        timer?.invalidate()
        let xp = score * 8
        user.addXP(xp)
        user.todayXP += xp
        user.gamesPlayed += 1
        if score > (user.gameHighScores["jargonMatch"] ?? 0) {
            user.gameHighScores["jargonMatch"] = score
        }
        isGameOver = true
    }
}

// MARK: - Jargon Term Data
struct JargonTerm {
    let term: String
    let definition: String

    static let all: [JargonTerm] = [
        JargonTerm(term: "LLM", definition: "Large Language Model — AI trained on massive text data"),
        JargonTerm(term: "Token", definition: "A chunk of text (word or part of word) that AI processes"),
        JargonTerm(term: "RAG", definition: "Retrieval-Augmented Generation — AI that looks up info before answering"),
        JargonTerm(term: "Hallucination", definition: "When AI generates confident but incorrect information"),
        JargonTerm(term: "Fine-tuning", definition: "Training a pre-built model further on specific data"),
        JargonTerm(term: "Embedding", definition: "A numerical representation of text that captures meaning"),
        JargonTerm(term: "Transformer", definition: "The architecture behind GPT, Claude, and most modern AI"),
        JargonTerm(term: "GPU", definition: "Graphics chip that's ideal for AI training and inference"),
        JargonTerm(term: "Inference", definition: "When a trained model generates output from new input"),
        JargonTerm(term: "Perceptron", definition: "The simplest type of neural network — a single neuron"),
        JargonTerm(term: "Neural Network", definition: "Layers of connected nodes that process information"),
        JargonTerm(term: "Gradient Descent", definition: "How AI improves by adjusting in the direction of less error"),
        JargonTerm(term: "Epoch", definition: "One complete pass through the entire training dataset"),
        JargonTerm(term: "Overfitting", definition: "When a model memorizes training data but fails on new data"),
        JargonTerm(term: "Attention", definition: "Mechanism that lets AI focus on the most relevant parts of input"),
        JargonTerm(term: "Parameter", definition: "An adjustable value in a model — billions in large models"),
        JargonTerm(term: "Context Window", definition: "The maximum amount of text an AI can process at once"),
        JargonTerm(term: "Temperature", definition: "Setting that controls how creative or random AI output is"),
        JargonTerm(term: "MCP", definition: "Model Context Protocol — standard for connecting AI to external tools"),
        JargonTerm(term: "Agent", definition: "AI that can take actions and make decisions autonomously"),
        JargonTerm(term: "Prompt", definition: "The input text you give to an AI model"),
        JargonTerm(term: "Supervised Learning", definition: "Training AI with labeled examples that show correct answers"),
        JargonTerm(term: "Unsupervised Learning", definition: "AI finds patterns in data without being told what to look for"),
        JargonTerm(term: "CNN", definition: "Convolutional Neural Network — specialized for image processing"),
        JargonTerm(term: "GAN", definition: "Two neural networks competing to generate realistic content"),
        JargonTerm(term: "Diffusion Model", definition: "AI that creates images by gradually removing noise"),
        JargonTerm(term: "RLHF", definition: "Training AI using human feedback on what's helpful and safe"),
        JargonTerm(term: "Backpropagation", definition: "How errors flow backward through a network to improve it"),
        JargonTerm(term: "TPU", definition: "Google's custom chip designed specifically for AI workloads"),
        JargonTerm(term: "Edge AI", definition: "Running AI models directly on devices instead of the cloud"),
    ]
}
