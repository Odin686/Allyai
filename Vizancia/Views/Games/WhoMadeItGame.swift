import SwiftUI

struct WhoMadeItGame: View {
    @Bindable var user: UserProfile
    @Environment(\.dismiss) private var dismiss

    @State private var score = 0
    @State private var round = 0
    @State private var isGameOver = false
    @State private var showTutorial = true
    @State private var showResult = false
    @State private var lastCorrect = false
    @State private var flashColor: Color = .clear
    @State private var shuffledPairs: [(product: String, company: String)] = []
    @State private var currentOptions: [String] = []

    private let totalRounds = 12

    private let pairs: [(product: String, company: String)] = [
        ("ChatGPT", "OpenAI"),
        ("Claude", "Anthropic"),
        ("Gemini", "Google"),
        ("LLaMA", "Meta"),
        ("Mistral", "Mistral AI"),
        ("Copilot", "GitHub/Microsoft"),
        ("DALL-E", "OpenAI"),
        ("Midjourney", "Midjourney"),
        ("Stable Diffusion", "Stability AI"),
        ("Siri", "Apple"),
        ("Alexa", "Amazon"),
        ("Watson", "IBM"),
        ("AlphaFold", "Google DeepMind"),
        ("Sora", "OpenAI"),
        ("Flux", "Black Forest Labs"),
        ("Cursor", "Anysphere")
    ]

    private var allCompanies: [String] {
        Array(Set(pairs.map { $0.company }))
    }

    var body: some View {
        ZStack {
            Color.aiBackground.ignoresSafeArea()

            if showTutorial {
                GameTutorialView(
                    title: "Who Made It?",
                    icon: "building.2.fill",
                    color: .aiSecondary,
                    rules: [
                        "You'll see an AI product or tool",
                        "Pick the company that created it",
                        "Choose from 4 options each round",
                        "12 rounds — test your AI industry knowledge!"
                    ]
                ) { showTutorial = false; setupRound() }
            } else if isGameOver {
                gameOverView
            } else if round < min(totalRounds, shuffledPairs.count) {
                let current = shuffledPairs[round]
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Button { endGame() } label: {
                            Image(systemName: "xmark")
                                .font(.title3)
                                .foregroundColor(.aiTextSecondary)
                        }
                        Spacer()
                        Text("Round \(round + 1)/\(totalRounds)")
                            .font(.aiCaption())
                            .foregroundColor(.aiTextSecondary)
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.aiWarning)
                            Text("\(score)")
                                .font(.aiRounded(.body, weight: .bold))
                                .foregroundColor(.aiPrimary)
                        }
                    }
                    .padding(.horizontal)

                    Spacer()

                    // Product name
                    VStack(spacing: 12) {
                        Text("Who made")
                            .font(.aiCaption())
                            .foregroundColor(.aiTextSecondary)
                        Text(current.product)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.aiSecondary)
                        Text("?")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.aiTextSecondary)
                    }

                    if showResult {
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: lastCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                Text(lastCorrect ? "Correct!" : "Wrong!")
                            }
                            .font(.aiHeadline())
                            .foregroundColor(lastCorrect ? .aiSuccess : .aiError)

                            if !lastCorrect {
                                Text("It was made by \(current.company)")
                                    .font(.aiBody())
                                    .foregroundColor(.aiTextSecondary)
                            }
                        }
                        .transition(.opacity)
                    } else {
                        // Company options
                        VStack(spacing: 10) {
                            ForEach(currentOptions, id: \.self) { company in
                                Button {
                                    checkAnswer(company)
                                } label: {
                                    HStack {
                                        Image(systemName: "building.2.fill")
                                            .foregroundColor(.aiSecondary.opacity(0.6))
                                        Text(company)
                                            .font(.aiBody())
                                            .foregroundColor(.aiTextPrimary)
                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity)
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

                    Spacer()
                }
                .padding(.vertical)
            }

            flashColor.opacity(0.15).ignoresSafeArea()
                .allowsHitTesting(false)
                .animation(.easeOut(duration: 0.3), value: flashColor)
        }
        .onAppear { shuffledPairs = pairs.shuffled() }
    }

    private var gameOverView: some View {
        VStack(spacing: 24) {
            Image(systemName: "building.2.fill")
                .font(.system(size: 50))
                .foregroundColor(.aiSecondary)
            Text("Game Over!")
                .font(.aiLargeTitle)
            Text("\(score)/\(totalRounds)")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundColor(.aiPrimary)

            if score > (user.gameHighScores["whoMadeIt"] ?? 0) {
                Text("🎉 New High Score!")
                    .font(.aiHeadline())
                    .foregroundColor(.aiWarning)
            }

            VStack(spacing: 12) {
                Button {
                    round = 0
                    score = 0
                    isGameOver = false
                    shuffledPairs = pairs.shuffled()
                    setupRound()
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

    private func setupRound() {
        guard round < min(totalRounds, shuffledPairs.count) else { return }
        let correctCompany = shuffledPairs[round].company
        let wrongCompanies = allCompanies.filter { $0 != correctCompany }.shuffled()
        let distractors = Array(wrongCompanies.prefix(3))
        currentOptions = (distractors + [correctCompany]).shuffled()
    }

    private func checkAnswer(_ company: String) {
        let correct = shuffledPairs[round].company
        lastCorrect = company == correct
        if lastCorrect {
            score += 1
            flashColor = .aiSuccess
            HapticService.shared.success()
        } else {
            flashColor = .aiError
            HapticService.shared.error()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { flashColor = .clear }

        withAnimation { showResult = true }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showResult = false
            round += 1
            if round >= totalRounds {
                endGame()
            } else {
                setupRound()
            }
        }
    }

    private func endGame() {
        let xp = score * 5
        user.addXP(xp)
        user.todayXP += xp
        user.gamesPlayed += 1
        if score > (user.gameHighScores["whoMadeIt"] ?? 0) {
            user.gameHighScores["whoMadeIt"] = score
        }
        isGameOver = true
    }
}
