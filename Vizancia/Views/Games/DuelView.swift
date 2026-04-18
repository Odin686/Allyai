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
                        duelQuestionView
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
                MatchmakerSheet { match in
                    showMatchmaker = false
                    startDuel(with: match)
                }
            }
            .fullScreenCover(isPresented: $showDuelResult) {
                if let duelData = completedDuelData {
                    DuelResultView(
                        user: user,
                        duelData: duelData,
                        localPlayerId: GKLocalPlayer.local.teamPlayerID
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
                        Text("Sign in to Game Center to duel")
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

            // Score
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.aiSuccess)
                Text("\(correctCount) correct")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.aiTextSecondary)
            }

            Spacer()
        }
        .padding(.top, 16)
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
                }
            } else {
                finishDuel()
            }
        }
    }

    private func finishDuel() {
        phase = .submitting
        let time = Date().timeIntervalSince(duelStartTime)

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

    func makeUIViewController(context: Context) -> GKTurnBasedMatchmakerViewController {
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 2
        let vc = GKTurnBasedMatchmakerViewController(matchRequest: request)
        vc.turnBasedMatchmakerDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: GKTurnBasedMatchmakerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onMatch: onMatch) }

    class Coordinator: NSObject, GKTurnBasedMatchmakerViewControllerDelegate {
        let onMatch: (GKTurnBasedMatch) -> Void
        init(onMatch: @escaping (GKTurnBasedMatch) -> Void) { self.onMatch = onMatch }

        func turnBasedMatchmakerViewControllerWasCancelled(_ viewController: GKTurnBasedMatchmakerViewController) {
            viewController.dismiss(animated: true)
        }

        func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFailWithError error: Error) {
            viewController.dismiss(animated: true)
        }

        func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFind match: GKTurnBasedMatch) {
            viewController.dismiss(animated: true)
            onMatch(match)
        }
    }
}
