import Foundation
import GameKit

// MARK: - Duel Service
@MainActor
class DuelService: ObservableObject {
    static let shared = DuelService()

    @Published var activeMatches: [GKTurnBasedMatch] = []
    @Published var currentMatch: GKTurnBasedMatch?
    @Published var currentDuelData: DuelMatchData?

    private let questionsPerDuel = 10

    private init() {
        // Listen for turn events
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleTurnEvent(_:)),
            name: .duelTurnReceived, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleMatchEnded(_:)),
            name: .duelMatchEnded, object: nil
        )
    }

    // MARK: - Load Active Matches

    func loadActiveMatches() async {
        guard GameKitService.shared.isAuthenticated else { return }
        do {
            let matches = try await GKTurnBasedMatch.loadMatches()
            self.activeMatches = matches.filter { match in
                match.status == .open || match.status == .matching
            }
        } catch {
            print("DuelService: Failed to load matches: \(error.localizedDescription)")
        }
    }


    // MARK: - Submit Player's Answers

    func submitAnswers(
        for match: GKTurnBasedMatch,
        answers: [String: Bool],
        score: Int,
        time: TimeInterval
    ) async throws {
        guard var duelData = loadDuelData(from: match) ?? currentDuelData else { return }

        let localPlayer = GKLocalPlayer.local
        let isPlayer1 = duelData.player1Id == localPlayer.teamPlayerID

        if isPlayer1 {
            duelData.player1Score = score
            duelData.player1Answers = answers
            duelData.player1Time = time
        } else {
            duelData.player2Id = localPlayer.teamPlayerID
            duelData.player2Score = score
            duelData.player2Answers = answers
            duelData.player2Time = time
        }

        guard let encoded = duelData.encoded() else { return }

        if duelData.isComplete {
            // Both players answered — end the match
            let participants = match.participants
            for participant in participants {
                if let playerId = participant.player?.teamPlayerID {
                    if playerId == duelData.winnerId {
                        participant.matchOutcome = .won
                    } else if duelData.isTie {
                        participant.matchOutcome = .tied
                    } else {
                        participant.matchOutcome = .lost
                    }
                }
            }
            try await match.endMatchInTurn(withMatch: encoded)
        } else {
            // Pass turn to next participant
            let nextParticipants = match.participants.filter { $0.player != GKLocalPlayer.local }
            try await match.endTurn(
                withNextParticipants: nextParticipants,
                turnTimeout: 604800,  // 7-day timeout
                match: encoded
            )
        }

        self.currentDuelData = duelData

        // Submit duel win to leaderboard if applicable
        if duelData.isComplete && duelData.winnerId == localPlayer.teamPlayerID {
            // Duel wins leaderboard is cumulative — we'd need the user's total
            // This will be handled by the caller
        }
    }

    // MARK: - Select Questions for Duel

    func selectDuelQuestions() -> [Question] {
        let allCategories = LessonContentProvider.shared.allCategories
        let allQuestions = allCategories.flatMap { $0.lessons.flatMap { $0.questions } }

        // Filter to multiple choice and true/false for duels (most duel-friendly)
        let duelFriendly = allQuestions.filter { q in
            q.type == .multipleChoice || q.type == .trueFalse
        }

        // Shuffle and take 10
        return Array(duelFriendly.shuffled().prefix(questionsPerDuel))
    }

    // MARK: - Get Questions for Match

    func questionsForMatch(_ match: GKTurnBasedMatch) -> [Question] {
        guard let duelData = loadDuelData(from: match) else { return [] }
        let allCategories = LessonContentProvider.shared.allCategories
        let allQuestions = allCategories.flatMap { $0.lessons.flatMap { $0.questions } }
        let questionMap = Dictionary(uniqueKeysWithValues: allQuestions.map { ($0.id, $0) })
        return duelData.questionIds.compactMap { questionMap[$0] }
    }

    // MARK: - Load Duel Data from Match

    func loadDuelData(from match: GKTurnBasedMatch) -> DuelMatchData? {
        guard let data = match.matchData, !data.isEmpty else { return nil }
        return DuelMatchData.decode(from: data)
    }

    // MARK: - Duel Status

    func status(for match: GKTurnBasedMatch) -> DuelStatus {
        guard let duelData = loadDuelData(from: match) else { return .waitingForOpponent }

        if match.status == .ended { return .completed }

        let localPlayer = GKLocalPlayer.local
        let isPlayer1 = duelData.player1Id == localPlayer.teamPlayerID

        if isPlayer1 {
            if duelData.player1Score == nil { return .yourTurn }
            if duelData.player2Score == nil { return .waitingForResult }
            return .completed
        } else {
            if duelData.player2Score == nil { return .yourTurn }
            return .completed
        }
    }

    // MARK: - Calculate XP Reward

    func xpReward(for duelData: DuelMatchData, isWinner: Bool?, isPerfect: Bool) -> Int {
        var xp: Int
        if let isWinner {
            xp = isWinner ? DuelRewards.winXP : DuelRewards.loseXP
        } else {
            xp = DuelRewards.tieXP // Tie
        }
        if isPerfect { xp += DuelRewards.perfectBonusXP }
        return xp
    }

    // MARK: - Notification Handlers

    @objc private func handleTurnEvent(_ notification: Notification) {
        Task {
            await loadActiveMatches()

            // Fire push notification for any match where it's now our turn
            for match in activeMatches {
                if status(for: match) == .yourTurn {
                    let opponent = match.participants.first { $0.player != GKLocalPlayer.local }
                    let name = opponent?.player?.displayName ?? "Your opponent"
                    NotificationService.shared.scheduleDuelTurnNotification(opponentName: name)
                    break
                }
            }
        }
    }

    @objc private func handleMatchEnded(_ notification: Notification) {
        Task {
            await loadActiveMatches()
        }
    }
}
