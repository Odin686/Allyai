import SwiftUI

struct AITimelineGame: View {
    @Bindable var user: UserProfile
    @Environment(\.dismiss) private var dismiss

    @State private var score = 0
    @State private var round = 0
    @State private var isGameOver = false
    @State private var showTutorial = true
    @State private var showResult = false
    @State private var roundScore = 0
    @State private var timeRemaining = 8
    @State private var timer: Timer?
    @State private var currentMilestones: [(name: String, year: Int)] = []
    @State private var flashColor: Color = .clear

    private let totalRounds = 5

    private let milestoneSets: [[(name: String, year: Int)]] = [
        [
            ("Turing Test proposed", 1950),
            ("Dartmouth Conference", 1956),
            ("ELIZA chatbot", 1966),
            ("Deep Blue beats Kasparov", 1997),
            ("AlphaGo beats Lee Sedol", 2016)
        ],
        [
            ("First neural network", 1958),
            ("AI Winter begins", 1974),
            ("World Wide Web", 1991),
            ("ImageNet created", 2009),
            ("Transformer paper", 2017)
        ],
        [
            ("Siri launches", 2011),
            ("AlexNet wins ImageNet", 2012),
            ("GPT-2 released", 2019),
            ("DALL-E announced", 2021),
            ("ChatGPT launches", 2022)
        ],
        [
            ("Backpropagation popularized", 1986),
            ("DeepMind founded", 2010),
            ("IBM Watson wins Jeopardy", 2011),
            ("GPT-3 released", 2020),
            ("EU AI Act passed", 2024)
        ],
        [
            ("McCarthy coins \"AI\"", 1956),
            ("Expert systems boom", 1980),
            ("Deep learning revival", 2012),
            ("AlphaFold solves proteins", 2020),
            ("Claude released", 2023)
        ]
    ]

    var body: some View {
        ZStack {
            Color.aiBackground.ignoresSafeArea()

            if showTutorial {
                GameTutorialView(
                    title: "AI Timeline",
                    icon: "clock.arrow.circlepath",
                    color: .aiOrange,
                    rules: [
                        "Put 5 AI milestones in chronological order",
                        "Tap the arrows to move items up or down",
                        "You have 8 seconds per round",
                        "10 points for each milestone in the correct position",
                        "5 rounds — how well do you know AI history?"
                    ]
                ) { showTutorial = false; startRound() }
            } else if isGameOver {
                gameOverView
            } else if showResult {
                roundResultView
            } else {
                VStack(spacing: 16) {
                    // Header
                    HStack {
                        Button { endGame() } label: {
                            Image(systemName: "xmark")
                                .font(.title3)
                                .foregroundColor(.aiTextSecondary)
                        }
                        Spacer()
                        HStack(spacing: 6) {
                            Image(systemName: "clock.fill")
                                .foregroundColor(timeRemaining <= 3 ? .aiError : .aiOrange)
                            Text("\(timeRemaining)s")
                                .font(.aiRounded(.title2, weight: .bold))
                                .foregroundColor(timeRemaining <= 3 ? .aiError : .aiOrange)
                        }
                        Spacer()
                        Text("Round \(round + 1)/\(totalRounds)")
                            .font(.aiCaption())
                            .foregroundColor(.aiTextSecondary)
                    }
                    .padding(.horizontal)

                    Text("Arrange from earliest to latest")
                        .font(.aiCaption())
                        .foregroundColor(.aiTextSecondary)

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.aiWarning)
                        Text("\(score)")
                            .font(.aiRounded(.body, weight: .bold))
                            .foregroundColor(.aiPrimary)
                    }

                    // Milestone list with up/down buttons
                    VStack(spacing: 8) {
                        ForEach(Array(currentMilestones.enumerated()), id: \.element.name) { index, milestone in
                            HStack(spacing: 12) {
                                VStack(spacing: 4) {
                                    Button {
                                        guard index > 0 else { return }
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            currentMilestones.swapAt(index, index - 1)
                                        }
                                        HapticService.shared.lightTap()
                                    } label: {
                                        Image(systemName: "chevron.up")
                                            .font(.caption.bold())
                                            .foregroundColor(index > 0 ? .aiPrimary : .aiTextSecondary.opacity(0.3))
                                    }
                                    .disabled(index == 0)

                                    Button {
                                        guard index < currentMilestones.count - 1 else { return }
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            currentMilestones.swapAt(index, index + 1)
                                        }
                                        HapticService.shared.lightTap()
                                    } label: {
                                        Image(systemName: "chevron.down")
                                            .font(.caption.bold())
                                            .foregroundColor(index < currentMilestones.count - 1 ? .aiPrimary : .aiTextSecondary.opacity(0.3))
                                    }
                                    .disabled(index == currentMilestones.count - 1)
                                }
                                .frame(width: 30)

                                Text(milestone.name)
                                    .font(.aiBody())
                                    .foregroundColor(.aiTextPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text("\(index + 1)")
                                    .font(.aiRounded(.caption, weight: .bold))
                                    .foregroundColor(.aiTextSecondary)
                                    .frame(width: 24, height: 24)
                                    .background(Circle().fill(Color.aiCard))
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.aiCard)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.aiTextSecondary.opacity(0.15), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    .padding(.horizontal)

                    Spacer()

                    Button { submitOrder() } label: {
                        Text("Lock In Order")
                            .font(.aiHeadline())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color.aiPrimaryGradient))
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .padding(.top)
            }

            flashColor.opacity(0.15).ignoresSafeArea()
                .allowsHitTesting(false)
                .animation(.easeOut(duration: 0.3), value: flashColor)
        }
        .onDisappear { timer?.invalidate() }
    }

    private var roundResultView: some View {
        VStack(spacing: 20) {
            Text("Round \(round) Result")
                .font(.aiTitle3())
                .foregroundColor(.aiTextPrimary)

            Text("+\(roundScore) points")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.aiPrimary)

            VStack(spacing: 6) {
                let correctOrder = milestoneSets[round - 1].sorted(by: { $0.year < $1.year })
                ForEach(Array(correctOrder.enumerated()), id: \.element.name) { index, milestone in
                    HStack {
                        Text("\(index + 1).")
                            .font(.aiRounded(.body, weight: .bold))
                            .foregroundColor(.aiTextSecondary)
                            .frame(width: 24)
                        Text(milestone.name)
                            .font(.aiBody())
                            .foregroundColor(.aiTextPrimary)
                        Spacer()
                        Text("\(milestone.year)")
                            .font(.aiRounded(.body, weight: .bold))
                            .foregroundColor(.aiOrange)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, 8)

            Button {
                showResult = false
                if round >= totalRounds {
                    endGame()
                } else {
                    startRound()
                }
            } label: {
                Text(round >= totalRounds ? "See Results" : "Next Round")
                    .font(.aiHeadline())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.aiPrimaryGradient))
            }
            .padding(.horizontal, 30)
        }
    }

    private var gameOverView: some View {
        VStack(spacing: 24) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 50))
                .foregroundColor(.aiOrange)
            Text("Timeline Complete!")
                .font(.aiLargeTitle)
            Text("\(score)/\(totalRounds * 50)")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundColor(.aiPrimary)

            if score > (user.gameHighScores["aiTimeline"] ?? 0) {
                Text("🎉 New High Score!")
                    .font(.aiHeadline())
                    .foregroundColor(.aiWarning)
            }

            VStack(spacing: 12) {
                Button {
                    round = 0
                    score = 0
                    isGameOver = false
                    startRound()
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

    private func startRound() {
        timeRemaining = 8
        let correctOrder = milestoneSets[round]
        currentMilestones = correctOrder.shuffled()
        // Make sure it's not accidentally in correct order
        let sorted = correctOrder.sorted(by: { $0.year < $1.year })
        while currentMilestones.map({ $0.name }) == sorted.map({ $0.name }) {
            currentMilestones.shuffle()
        }
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                submitOrder()
            }
        }
    }

    private func submitOrder() {
        timer?.invalidate()
        let correctOrder = milestoneSets[round].sorted(by: { $0.year < $1.year })
        roundScore = 0
        for i in 0..<currentMilestones.count {
            if currentMilestones[i].name == correctOrder[i].name {
                roundScore += 10
            }
        }
        score += roundScore

        if roundScore > 0 {
            flashColor = .aiSuccess
            HapticService.shared.success()
        } else {
            flashColor = .aiError
            HapticService.shared.error()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { flashColor = .clear }

        round += 1
        showResult = true
    }

    private func endGame() {
        timer?.invalidate()
        let xp = score * 2
        user.addXP(xp)
        user.todayXP += xp
        user.gamesPlayed += 1
        if score > (user.gameHighScores["aiTimeline"] ?? 0) {
            user.gameHighScores["aiTimeline"] = score
        }
        GameKitService.shared.submitTotalXP(user.totalXP)
        isGameOver = true
    }
}
