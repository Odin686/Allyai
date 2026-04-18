import SwiftUI

struct FactOrFictionGame: View {
    @Bindable var user: UserProfile
    @Environment(\.dismiss) private var dismiss

    @State private var score = 0
    @State private var currentIndex = 0
    @State private var isGameOver = false
    @State private var showTutorial = true
    @State private var showResult = false
    @State private var lastCorrect = false
    @State private var flashColor: Color = .clear
    @State private var shuffledClaims: [(claim: String, isFact: Bool, explanation: String)] = []

    private let totalQuestions = 15

    private let claims: [(claim: String, isFact: Bool, explanation: String)] = [
        ("GPT-4 can process images as input", true, "GPT-4 is multimodal and can analyze images."),
        ("AI can smell food through your phone", false, "AI cannot process physical smells — it only works with digital data."),
        ("Netflix uses AI to recommend shows", true, "Netflix's recommendation engine uses ML to personalize content."),
        ("AI models dream when they sleep", false, "AI doesn't sleep or dream — it only runs when processing."),
        ("Spotify uses AI to create Discover Weekly playlists", true, "Spotify's recommendation system uses collaborative filtering and NLP."),
        ("ChatGPT was trained on the entire internet", false, "It was trained on a large but curated subset of internet text, not everything."),
        ("AI can detect some cancers better than doctors", true, "Studies show AI matching or exceeding radiologists for certain cancers."),
        ("Self-driving cars use a single AI model", false, "They use multiple AI systems working together — vision, planning, control."),
        ("The word 'robot' is over 100 years old", true, "It was coined in 1920 in Karel Čapek's play R.U.R."),
        ("AI can generate human DNA sequences", false, "While AI can analyze DNA, it cannot create functional human genetic code."),
        ("Google's AI once beat the world champion at Go", true, "AlphaGo defeated Lee Sedol in 2016."),
        ("All AI is based on neural networks", false, "Many AI techniques exist including decision trees, SVMs, and rule-based systems."),
        ("DALL-E is named after Salvador Dalí and WALL-E", true, "The name combines the surrealist artist with Pixar's robot character."),
        ("AI can write music that sounds like a specific artist", true, "AI voice cloning and style transfer can mimic specific musical styles."),
        ("Training GPT-3 used more energy than a car uses in its lifetime", false, "Training used significant energy but not more than a car's lifetime fuel consumption.")
    ]

    var body: some View {
        ZStack {
            Color.aiBackground.ignoresSafeArea()

            if showTutorial {
                GameTutorialView(
                    title: "Fact or Fiction",
                    icon: "hand.thumbsup.fill",
                    color: .aiSuccess,
                    rules: [
                        "You'll see a claim about AI",
                        "Decide if it's a fact or fiction",
                        "See the explanation after each answer",
                        "15 claims — how well do you know AI?"
                    ]
                ) { showTutorial = false }
            } else if isGameOver {
                gameOverView
            } else if currentIndex < min(totalQuestions, shuffledClaims.count) {
                let item = shuffledClaims[currentIndex]
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Button { endGame() } label: {
                            Image(systemName: "xmark")
                                .font(.title3)
                                .foregroundColor(.aiTextSecondary)
                        }
                        Spacer()
                        Text("\(currentIndex + 1)/\(totalQuestions)")
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

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.aiTextSecondary.opacity(0.15))
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.aiSuccess)
                                .frame(width: geo.size.width * CGFloat(currentIndex) / CGFloat(totalQuestions), height: 6)
                        }
                    }
                    .frame(height: 6)
                    .padding(.horizontal)

                    Spacer()

                    // Claim card
                    VStack(spacing: 16) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.aiPrimary)

                        Text(item.claim)
                            .font(.aiTitle3())
                            .foregroundColor(.aiTextPrimary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 24)

                    if showResult {
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: lastCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                Text(lastCorrect ? "Correct!" : "Wrong!")
                            }
                            .font(.aiHeadline())
                            .foregroundColor(lastCorrect ? .aiSuccess : .aiError)

                            Text(item.isFact ? "This is a FACT" : "This is FICTION")
                                .font(.aiRounded(.body, weight: .bold))
                                .foregroundColor(.aiPrimary)

                            Text(item.explanation)
                                .font(.aiCaption())
                                .foregroundColor(.aiTextSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                        .transition(.opacity)
                    } else {
                        // Fact / Fiction buttons
                        HStack(spacing: 16) {
                            Button { answerTapped(isFact: true) } label: {
                                VStack(spacing: 6) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title)
                                    Text("Fact")
                                        .font(.aiHeadline())
                                }
                                .foregroundColor(.aiSuccess)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.aiSuccess.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.aiSuccess.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }

                            Button { answerTapped(isFact: false) } label: {
                                VStack(spacing: 6) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title)
                                    Text("Fiction")
                                        .font(.aiHeadline())
                                }
                                .foregroundColor(.aiError)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.aiError.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.aiError.opacity(0.3), lineWidth: 1)
                                        )
                                )
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
        .onAppear { shuffledClaims = claims.shuffled() }
    }

    private var gameOverView: some View {
        VStack(spacing: 24) {
            Image(systemName: "hand.thumbsup.fill")
                .font(.system(size: 50))
                .foregroundColor(.aiSuccess)
            Text("Game Over!")
                .font(.aiLargeTitle)
            Text("\(score)/\(totalQuestions)")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundColor(.aiPrimary)

            if score > (user.gameHighScores["factOrFiction"] ?? 0) {
                Text("🎉 New High Score!")
                    .font(.aiHeadline())
                    .foregroundColor(.aiWarning)
            }

            VStack(spacing: 12) {
                Button {
                    currentIndex = 0
                    score = 0
                    isGameOver = false
                    shuffledClaims = claims.shuffled()
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

    private func answerTapped(isFact: Bool) {
        let item = shuffledClaims[currentIndex]
        lastCorrect = item.isFact == isFact
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
            currentIndex += 1
            if currentIndex >= totalQuestions {
                endGame()
            }
        }
    }

    private func endGame() {
        let xp = score * 6
        user.addXP(xp)
        user.todayXP += xp
        user.gamesPlayed += 1
        if score > (user.gameHighScores["factOrFiction"] ?? 0) {
            user.gameHighScores["factOrFiction"] = score
        }
        GameKitService.shared.submitTotalXP(user.totalXP)
        isGameOver = true
    }
}
