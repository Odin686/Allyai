import SwiftUI
import GameKit

// MARK: - Duel View
struct DuelView: View {
    @Bindable var user: UserProfile
    @Environment(\.dismiss) private var dismiss
    @StateObject private var gameKit = GameKitService.shared
    @StateObject private var duelService = DuelService.shared

    @State private var showMatchmaker = false
    @State private var activeDuel: GKTurnBasedMatch?
    @State private var duelQuestions: [Question] = []
    @State private var currentQuestionIndex = 0
    @State private var correctCount = 0
    @State private var answers: [String: Bool] = [:]
    @State private var selectedAnswer: String?
    @State private var showResult = false
    @State private var isCreating = false
    @State private var duelStartTime = Date()
    @State private var showDuelResult = false
    @State private var completedDuelData: DuelMatchData?
    @State private var phase: DuelPhase = .lobby

    // Bot duel state
    @State private var showBotPicker = false
    @State private var showGameModePicker = false
    @State private var isBotDuel = false
    @State private var botDifficulty: BotDifficulty = .medium
    @State private var selectedGameMode: DuelGameMode = .quiz
    @State private var showNoOpponentAlert = false
    @State private var botOpponentName: String? = nil

    // Bot turn-based state
    @State private var isBotTurn = false
    @State private var botThinking = false
    @State private var botGotItRight = false
    @State private var showBotTurnResult = false
    @State private var botScore = 0
    @State private var botAnswers: [String: Bool] = [:]

    enum DuelPhase {
        case lobby
        case playing
        case submitting
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.aiBackground.ignoresSafeArea()

                switch phase {
                case .lobby:
                    lobbyView
                case .playing:
                    if currentQuestionIndex < duelQuestions.count {
                        if isBotDuel && isBotTurn {
                            botTurnView
                        } else {
                            duelQuestionView
                        }
                    }
                case .submitting:
                    submittingView
                }
            }
            .navigationTitle(phase == .lobby ? "1v1 Duel" : "Duel ⚔️")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if phase == .lobby {
                        Button("Done") { dismiss() }
                    }
                }
            }
            .sheet(isPresented: $showMatchmaker) {
                MatchmakerSheet(
                    onMatch: { match in
                        showMatchmaker = false
                        startDuel(with: match)
                    },
                    onCancel: {
                        showMatchmaker = false
                        showNoOpponentAlert = true
                    }
                )
            }
            .sheet(isPresented: $showBotPicker) {
                BotDifficultyPicker { difficulty in
                    showBotPicker = false
                    botDifficulty = difficulty
                    botOpponentName = difficulty.displayName
                    // Show game mode picker next
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showGameModePicker = true
                    }
                }
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $showGameModePicker) {
                DuelGameModePicker { mode in
                    showGameModePicker = false
                    startBotDuel(difficulty: botDifficulty, gameMode: mode)
                }
                .presentationDetents([.medium])
            }
            .alert("No Opponents Found", isPresented: $showNoOpponentAlert) {
                Button("Play vs Bot") { showBotPicker = true }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("No players are available right now. Would you like to duel against a bot instead?")
            }
            .fullScreenCover(isPresented: $showDuelResult) {
                if let duelData = completedDuelData {
                    DuelResultView(
                        user: user,
                        duelData: duelData,
                        localPlayerId: isBotDuel ? duelData.player1Id : GKLocalPlayer.local.teamPlayerID,
                        opponentName: botOpponentName
                    )
                }
            }
            .task {
                await duelService.loadActiveMatches()
            }
        }
    }

    // MARK: - Lobby
    private var lobbyView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.aiPrimary)
                    Text("Challenge a Player")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.aiTextPrimary)
                    Text("Answer 10 questions head-to-head.\nHighest score wins!")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.aiTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)

                // XP Rewards Info
                HStack(spacing: 16) {
                    rewardPill(icon: "trophy.fill", text: "Win: +\(DuelRewards.winXP) XP", color: .aiWarning)
                    rewardPill(icon: "equal.circle.fill", text: "Tie: +\(DuelRewards.tieXP) XP", color: .aiSecondary)
                    rewardPill(icon: "heart.fill", text: "Lose: +\(DuelRewards.loseXP) XP", color: .aiError)
                }
                .padding(.horizontal)

                // Start Duel Button
                if gameKit.isAuthenticated {
                    Button {
                        showMatchmaker = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "bolt.fill")
                            Text(isCreating ? "Finding Opponent..." : "Start New Duel")
                        }
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.aiPrimaryGradient)
                        )
                    }
                    .disabled(isCreating)
                    .padding(.horizontal)
                } else {
                    // Not signed in
                    VStack(spacing: 10) {
                        Image(systemName: "gamecontroller")
                            .font(.system(size: 28))
                            .foregroundColor(.aiTextSecondary.opacity(0.4))
                        Text("Sign in to Game Center to duel online")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.aiTextSecondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.aiCard)
                    )
                    .padding(.horizontal)
                }

                // Play vs Bot Button (always available)
                Button {
                    showBotPicker = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "cpu")
                        Text("Play vs Bot")
                    }
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.aiPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.aiPrimary.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.aiPrimary.opacity(0.25), lineWidth: 1.5)
                            )
                    )
                }
                .padding(.horizontal)

                // Active Duels
                if !duelService.activeMatches.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Active Duels")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.aiTextPrimary)
                            .padding(.horizontal)

                        ForEach(duelService.activeMatches, id: \.matchID) { match in
                            activeDuelCard(match: match)
                        }
                    }
                }

                Spacer(minLength: 30)
            }
        }
    }

    private func rewardPill(icon: String, text: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
            Text(text)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundColor(.aiTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.aiCard)
                .shadow(color: .black.opacity(0.03), radius: 3, y: 2)
        )
    }

    private func activeDuelCard(match: GKTurnBasedMatch) -> some View {
        let status = duelService.status(for: match)
        let opponent = match.participants.first { $0.player != GKLocalPlayer.local }

        return Button {
            if status == .yourTurn {
                startDuel(with: match)
            } else if status == .completed {
                if let data = duelService.loadDuelData(from: match) {
                    completedDuelData = data
                    showDuelResult = true
                }
            }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(statusColor(status).opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: statusIcon(status))
                        .font(.system(size: 16))
                        .foregroundColor(statusColor(status))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("vs \(opponent?.player?.displayName ?? "Opponent")")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.aiTextPrimary)
                    Text(statusLabel(status))
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(statusColor(status))
                }

                Spacer()

                if status == .yourTurn {
                    Text("PLAY")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.aiPrimary))
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.aiTextSecondary.opacity(0.4))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.aiCard)
                    .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(status == .yourTurn ? Color.aiPrimary.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .padding(.horizontal)
    }

    // MARK: - Duel Question View
    private var duelQuestionView: some View {
        let question = duelQuestions[currentQuestionIndex]

        return VStack(spacing: 24) {
            // Turn indicator
            if isBotDuel {
                HStack(spacing: 8) {
                    Image(systemName: "person.fill")
                        .foregroundColor(.aiPrimary)
                    Text("Your Turn")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.aiPrimary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.aiPrimary.opacity(0.1)))
            }

            // Progress bar
            HStack(spacing: 8) {
                ForEach(0..<duelQuestions.count, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(i < currentQuestionIndex ? Color.aiSuccess :
                              i == currentQuestionIndex ? Color.aiPrimary :
                              Color.aiPrimary.opacity(0.15))
                        .frame(height: 4)
                }
            }
            .padding(.horizontal)

            // Question counter
            Text("Question \(currentQuestionIndex + 1) of \(duelQuestions.count)")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.aiTextSecondary)

            // Question
            Text(question.questionText)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.aiTextPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Options
            VStack(spacing: 10) {
                ForEach(question.options, id: \.self) { option in
                    Button {
                        answerQuestion(option: option, question: question)
                    } label: {
                        HStack {
                            Text(option)
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(optionColor(option, question: question))
                                .multilineTextAlignment(.leading)
                            Spacer()
                            if selectedAnswer == option {
                                Image(systemName: option == question.correctAnswer ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(option == question.correctAnswer ? .aiSuccess : .aiError)
                            }
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(optionBackground(option, question: question))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(optionBorder(option, question: question), lineWidth: 1.5)
                        )
                    }
                    .disabled(selectedAnswer != nil)
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top, 16)
    }

    // MARK: - Bot Turn View
    private var botTurnView: some View {
        VStack(spacing: 24) {
            // Progress bar
            HStack(spacing: 8) {
                ForEach(0..<duelQuestions.count, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(i < currentQuestionIndex ? Color.aiSuccess :
                              i == currentQuestionIndex ? Color.aiOrange :
                              Color.aiPrimary.opacity(0.15))
                        .frame(height: 4)
                }
            }
            .padding(.horizontal)

            Text("Question \(currentQuestionIndex + 1) of \(duelQuestions.count)")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.aiTextSecondary)

            Spacer()

            if showBotTurnResult {
                // Bot result
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill((botGotItRight ? Color.aiSuccess : Color.aiError).opacity(0.12))
                            .frame(width: 80, height: 80)
                        Image(systemName: botGotItRight ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(botGotItRight ? .aiSuccess : .aiError)
                    }
                    .transition(.scale.combined(with: .opacity))

                    Text(botGotItRight ? "\(botOpponentName ?? "Bot") got it right!" : "\(botOpponentName ?? "Bot") got it wrong!")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(botGotItRight ? .aiSuccess : .aiError)
                }
            } else {
                // Bot thinking animation
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color.aiOrange.opacity(0.12))
                            .frame(width: 80, height: 80)
                        Image(systemName: "cpu")
                            .font(.system(size: 36))
                            .foregroundColor(.aiOrange)
                            .symbolEffect(.pulse, isActive: botThinking)
                    }

                    HStack(spacing: 8) {
                        Image(systemName: "cpu")
                            .foregroundColor(.aiOrange)
                        Text("\(botOpponentName ?? "Bot")'s Turn")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.aiOrange)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.aiOrange.opacity(0.1)))

                    Text("Thinking...")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.aiTextSecondary)
                }
            }

            Spacer()
        }
        .padding(.top, 16)
        .onAppear {
            performBotTurn()
        }
    }

    // MARK: - Submitting View
    private var submittingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.3)
            Text("Submitting your answers...")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.aiTextSecondary)
        }
    }

    // MARK: - Actions

    private func startDuel(with match: GKTurnBasedMatch) {
        isBotDuel = false
        botOpponentName = nil
        activeDuel = match
        duelQuestions = duelService.questionsForMatch(match)

        // If no questions yet (new match), select fresh ones and save to match
        if duelQuestions.isEmpty {
            duelQuestions = duelService.selectDuelQuestions()
            let matchData = DuelMatchData(
                questionIds: duelQuestions.map { $0.id },
                categoryId: "duel_mixed",
                player1Id: GKLocalPlayer.local.teamPlayerID
            )
            duelService.currentDuelData = matchData
            duelService.currentMatch = match
        }

        currentQuestionIndex = 0
        correctCount = 0
        answers = [:]
        selectedAnswer = nil
        duelStartTime = Date()
        phase = .playing
    }

    private func startBotDuel(difficulty: BotDifficulty, gameMode: DuelGameMode = .quiz) {
        isBotDuel = true
        botDifficulty = difficulty
        selectedGameMode = gameMode
        botOpponentName = difficulty.displayName
        activeDuel = nil
        duelQuestions = duelService.selectDuelQuestions()
        currentQuestionIndex = 0
        correctCount = 0
        botScore = 0
        botAnswers = [:]
        answers = [:]
        selectedAnswer = nil
        isBotTurn = false
        botThinking = false
        showBotTurnResult = false
        duelStartTime = Date()
        phase = .playing
    }

    private func answerQuestion(option: String, question: Question) {
        guard selectedAnswer == nil else { return }
        selectedAnswer = option
        let isCorrect = option == question.correctAnswer
        answers[question.id] = isCorrect
        if isCorrect {
            correctCount += 1
            HapticService.shared.success()
            SoundService.shared.play(.correct)
        } else {
            HapticService.shared.error()
            SoundService.shared.play(.wrong)
        }

        // Advance after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            if currentQuestionIndex + 1 < duelQuestions.count {
                withAnimation(.spring(response: 0.3)) {
                    currentQuestionIndex += 1
                    selectedAnswer = nil
                    // In bot duels, alternate turns
                    if isBotDuel {
                        isBotTurn = true
                    }
                }
            } else {
                finishDuel()
            }
        }
    }

    private func performBotTurn() {
        let question = duelQuestions[currentQuestionIndex]
        botThinking = true
        showBotTurnResult = false

        // Simulate thinking delay
        let thinkTime = Double.random(in: 1.2...2.2)
        DispatchQueue.main.asyncAfter(deadline: .now() + thinkTime) {
            let correct = Double.random(in: 0...1) < botDifficulty.accuracy
            botAnswers[question.id] = correct
            if correct { botScore += 1 }
            botGotItRight = correct
            botThinking = false

            withAnimation(.spring(response: 0.4)) {
                showBotTurnResult = true
            }

            if correct {
                HapticService.shared.lightTap()
            }

            // Advance after showing result
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                if currentQuestionIndex + 1 < duelQuestions.count {
                    withAnimation(.spring(response: 0.3)) {
                        currentQuestionIndex += 1
                        isBotTurn = false
                        showBotTurnResult = false
                        selectedAnswer = nil
                    }
                } else {
                    finishDuel()
                }
            }
        }
    }

    private func finishDuel() {
        let time = Date().timeIntervalSince(duelStartTime)

        if isBotDuel {
            finishBotDuel(playerTime: time)
            return
        }

        phase = .submitting

        Task {
            guard let match = activeDuel else {
                dismiss()
                return
            }

            do {
                try await duelService.submitAnswers(
                    for: match,
                    answers: answers,
                    score: correctCount,
                    time: time
                )

                // Calculate XP
                if let duelData = duelService.currentDuelData, duelData.isComplete {
                    let localPlayer = GKLocalPlayer.local.teamPlayerID
                    let isWinner: Bool?
                    if duelData.isTie {
                        isWinner = nil
                    } else {
                        isWinner = duelData.winnerId == localPlayer
                    }
                    let xp = duelService.xpReward(
                        for: duelData,
                        isWinner: isWinner,
                        isPerfect: correctCount == duelQuestions.count
                    )

                    user.addXP(xp)
                    user.todayXP += xp
                    user.duelWins += (isWinner == true ? 1 : 0)
                    user.duelLosses += (isWinner == false ? 1 : 0)
                    user.duelTies += (isWinner == nil && duelData.isComplete ? 1 : 0)
                    user.totalDuelsPlayed += 1

                    GameKitService.shared.submitTotalXP(user.totalXP)
                    GameKitService.shared.submitDuelWins(user.duelWins)

                    completedDuelData = duelData
                    showDuelResult = true
                } else {
                    // Waiting for opponent
                    dismiss()
                }
            } catch {
                print("DuelView: Failed to submit answers: \(error.localizedDescription)")
                dismiss()
            }
        }
    }

    private func finishBotDuel(playerTime: TimeInterval) {
        // Bot answers were already recorded during turn-based play
        // Fill in any remaining questions the bot didn't answer during turns
        for question in duelQuestions where botAnswers[question.id] == nil {
            let correct = Double.random(in: 0...1) < botDifficulty.accuracy
            botAnswers[question.id] = correct
            if correct { botScore += 1 }
        }

        // Simulate bot total time (faster on harder difficulties)
        let botTime: TimeInterval
        switch botDifficulty {
        case .easy: botTime = Double.random(in: 25...45)
        case .medium: botTime = Double.random(in: 15...30)
        case .hard: botTime = Double.random(in: 8...18)
        }

        // Build a complete DuelMatchData
        let localPlayerId = GKLocalPlayer.local.isAuthenticated
            ? GKLocalPlayer.local.teamPlayerID
            : "local_player"

        var duelData = DuelMatchData(
            questionIds: duelQuestions.map { $0.id },
            categoryId: "duel_bot",
            player1Id: localPlayerId,
            gameMode: selectedGameMode
        )
        duelData.player1Score = correctCount
        duelData.player1Answers = answers
        duelData.player1Time = playerTime
        duelData.player2Id = "bot_\(botDifficulty.rawValue)"
        duelData.player2Score = botScore
        duelData.player2Answers = botAnswers
        duelData.player2Time = botTime

        // Calculate result
        let isWinner: Bool?
        if duelData.isTie {
            isWinner = nil
        } else {
            isWinner = duelData.winnerId == localPlayerId
        }

        // Bot duels use scaled XP
        let isPerfect = correctCount == duelQuestions.count
        var xp: Int
        if let isWinner {
            xp = isWinner
                ? DuelRewards.botWinXP(difficulty: botDifficulty)
                : DuelRewards.botLoseXP(difficulty: botDifficulty)
        } else {
            xp = DuelRewards.botTieXP(difficulty: botDifficulty)
        }
        if isPerfect { xp += DuelRewards.botPerfectBonusXP(difficulty: botDifficulty) }

        user.addXP(xp)
        user.todayXP += xp
        user.duelWins += (isWinner == true ? 1 : 0)
        user.duelLosses += (isWinner == false ? 1 : 0)
        user.duelTies += (isWinner == nil ? 1 : 0)
        user.totalDuelsPlayed += 1
        user.gamesPlayed += 1

        // Record activity for streak calendar
        user.recordActivity(xpEarned: xp)

        GameKitService.shared.submitTotalXP(user.totalXP)
        if isWinner == true {
            GameKitService.shared.submitDuelWins(user.duelWins)
            // Duel win is a positive moment — prompt for review
            AppReviewService.shared.recordPositiveMoment()
        }

        // Check for newly unlocked achievements
        for achievement in AchievementData.all {
            if !user.unlockedAchievementIds.contains(achievement.id) && achievement.condition(user) {
                user.unlockedAchievementIds.append(achievement.id)
                break
            }
        }

        completedDuelData = duelData
        showDuelResult = true
    }

    // MARK: - Option Styling

    private func optionColor(_ option: String, question: Question) -> Color {
        guard let selected = selectedAnswer else { return .aiTextPrimary }
        if option == question.correctAnswer { return .aiSuccess }
        if option == selected { return .aiError }
        return .aiTextSecondary
    }

    private func optionBackground(_ option: String, question: Question) -> Color {
        guard let selected = selectedAnswer else { return Color.aiCard }
        if option == question.correctAnswer { return Color.aiSuccess.opacity(0.08) }
        if option == selected { return Color.aiError.opacity(0.08) }
        return Color.aiCard
    }

    private func optionBorder(_ option: String, question: Question) -> Color {
        guard let selected = selectedAnswer else { return Color.aiTextSecondary.opacity(0.1) }
        if option == question.correctAnswer { return Color.aiSuccess.opacity(0.4) }
        if option == selected { return Color.aiError.opacity(0.4) }
        return Color.aiTextSecondary.opacity(0.1)
    }

    private func statusColor(_ status: DuelStatus) -> Color {
        switch status {
        case .yourTurn: return .aiPrimary
        case .waitingForOpponent, .waitingForResult: return .aiOrange
        case .completed: return .aiSuccess
        case .expired: return .aiTextSecondary
        }
    }

    private func statusIcon(_ status: DuelStatus) -> String {
        switch status {
        case .yourTurn: return "play.fill"
        case .waitingForOpponent, .waitingForResult: return "hourglass"
        case .completed: return "checkmark.circle.fill"
        case .expired: return "xmark.circle"
        }
    }

    private func statusLabel(_ status: DuelStatus) -> String {
        switch status {
        case .yourTurn: return "Your turn — tap to play!"
        case .waitingForOpponent: return "Waiting for opponent..."
        case .waitingForResult: return "Waiting for opponent's answers..."
        case .completed: return "Duel complete — tap to see results"
        case .expired: return "Expired"
        }
    }
}

// MARK: - Matchmaker Sheet
struct MatchmakerSheet: UIViewControllerRepresentable {
    let onMatch: (GKTurnBasedMatch) -> Void
    var onCancel: (() -> Void)? = nil

    func makeUIViewController(context: Context) -> GKTurnBasedMatchmakerViewController {
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 2
        let vc = GKTurnBasedMatchmakerViewController(matchRequest: request)
        vc.turnBasedMatchmakerDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: GKTurnBasedMatchmakerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onMatch: onMatch, onCancel: onCancel) }

    class Coordinator: NSObject, GKTurnBasedMatchmakerViewControllerDelegate {
        let onMatch: (GKTurnBasedMatch) -> Void
        let onCancel: (() -> Void)?
        init(onMatch: @escaping (GKTurnBasedMatch) -> Void, onCancel: (() -> Void)?) {
            self.onMatch = onMatch
            self.onCancel = onCancel
        }

        func turnBasedMatchmakerViewControllerWasCancelled(_ viewController: GKTurnBasedMatchmakerViewController) {
            viewController.dismiss(animated: true) {
                self.onCancel?()
            }
        }

        func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFailWithError error: Error) {
            viewController.dismiss(animated: true) {
                self.onCancel?()
            }
        }

        func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFind match: GKTurnBasedMatch) {
            viewController.dismiss(animated: true)
            onMatch(match)
        }
    }
}

// MARK: - Bot Difficulty Picker
struct BotDifficultyPicker: View {
    let onSelect: (BotDifficulty) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.aiBackground.ignoresSafeArea()

                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "cpu")
                            .font(.system(size: 40))
                            .foregroundColor(.aiPrimary)
                        Text("Choose Difficulty")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.aiTextPrimary)
                        Text("Pick how tough your bot opponent will be")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.aiTextSecondary)
                    }
                    .padding(.top, 10)

                    // Difficulty options
                    VStack(spacing: 12) {
                        ForEach(BotDifficulty.allCases, id: \.rawValue) { difficulty in
                            Button {
                                onSelect(difficulty)
                            } label: {
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .fill(difficulty.color.opacity(0.15))
                                            .frame(width: 48, height: 48)
                                        Image(systemName: difficulty.icon)
                                            .font(.system(size: 20))
                                            .foregroundColor(difficulty.color)
                                    }

                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(difficulty.displayName)
                                            .font(.system(size: 17, weight: .bold, design: .rounded))
                                            .foregroundColor(.aiTextPrimary)
                                        Text(difficulty.subtitle)
                                            .font(.system(size: 13, design: .rounded))
                                            .foregroundColor(.aiTextSecondary)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.caption.bold())
                                        .foregroundColor(.aiTextSecondary.opacity(0.4))
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.aiCard)
                                        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(difficulty.color.opacity(0.2), lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.aiTextSecondary)
                }
            }
        }
    }
}

// MARK: - Duel Game Mode Picker
struct DuelGameModePicker: View {
    let onSelect: (DuelGameMode) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.aiBackground.ignoresSafeArea()

                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.aiPrimary)
                        Text("Choose Game Mode")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.aiTextPrimary)
                        Text("How do you want to duel?")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.aiTextSecondary)
                    }
                    .padding(.top, 10)

                    // Game mode options
                    VStack(spacing: 12) {
                        ForEach(DuelGameMode.allCases, id: \.rawValue) { mode in
                            Button {
                                onSelect(mode)
                            } label: {
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .fill(mode.color.opacity(0.15))
                                            .frame(width: 48, height: 48)
                                        Image(systemName: mode.icon)
                                            .font(.system(size: 20))
                                            .foregroundColor(mode.color)
                                    }

                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(mode.displayName)
                                            .font(.system(size: 17, weight: .bold, design: .rounded))
                                            .foregroundColor(.aiTextPrimary)
                                        Text(mode.description)
                                            .font(.system(size: 13, design: .rounded))
                                            .foregroundColor(.aiTextSecondary)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.caption.bold())
                                        .foregroundColor(.aiTextSecondary.opacity(0.4))
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.aiCard)
                                        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(mode.color.opacity(0.2), lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.aiTextSecondary)
                }
            }
        }
    }
}
