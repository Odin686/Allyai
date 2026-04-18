import Foundation
import SwiftUI

// MARK: - Bot Difficulty
enum BotDifficulty: String, Codable, CaseIterable {
    case easy, medium, hard

    var displayName: String {
        switch self {
        case .easy: return "Easy Bot"
        case .medium: return "Medium Bot"
        case .hard: return "Hard Bot"
        }
    }

    var icon: String {
        switch self {
        case .easy: return "tortoise.fill"
        case .medium: return "hare.fill"
        case .hard: return "flame.fill"
        }
    }

    var color: Color {
        switch self {
        case .easy: return .aiSuccess
        case .medium: return .aiWarning
        case .hard: return .aiError
        }
    }

    /// Probability of answering each question correctly
    var accuracy: Double {
        switch self {
        case .easy: return 0.4
        case .medium: return 0.65
        case .hard: return 0.85
        }
    }

    var subtitle: String {
        switch self {
        case .easy: return "Casual — gets ~4/10 right"
        case .medium: return "Balanced — gets ~6-7/10 right"
        case .hard: return "Expert — gets ~8-9/10 right"
        }
    }
}


// MARK: - Duel Match Data
/// Codable struct serialized to GKTurnBasedMatch.matchData
struct DuelMatchData: Codable {
    let questionIds: [String]
    let categoryId: String
    var player1Id: String
    var player2Id: String?
    var player1Score: Int?
    var player2Score: Int?
    var player1Answers: [String: Bool]?
    var player2Answers: [String: Bool]?
    var player1Time: TimeInterval?
    var player2Time: TimeInterval?
    var createdAt: Date

    init(questionIds: [String], categoryId: String, player1Id: String) {
        self.questionIds = questionIds
        self.categoryId = categoryId
        self.player1Id = player1Id
        self.createdAt = Date()
    }

    // Encode to Data for Game Center
    func encoded() -> Data? {
        try? JSONEncoder().encode(self)
    }

    // Decode from Game Center match data
    static func decode(from data: Data) -> DuelMatchData? {
        try? JSONDecoder().decode(DuelMatchData.self, from: data)
    }

    var isComplete: Bool {
        player1Score != nil && player2Score != nil
    }

    var winnerId: String? {
        guard let p1 = player1Score, let p2 = player2Score else { return nil }
        if p1 > p2 { return player1Id }
        if p2 > p1 { return player2Id }
        return nil // Tie
    }

    var isTie: Bool {
        guard let p1 = player1Score, let p2 = player2Score else { return false }
        return p1 == p2
    }
}

// MARK: - Duel Status
enum DuelStatus: String {
    case waitingForOpponent
    case yourTurn
    case waitingForResult
    case completed
    case expired
}

// MARK: - Duel XP Rewards
struct DuelRewards {
    static let winXP = 50
    static let loseXP = 15
    static let tieXP = 30
    static let perfectBonusXP = 25

    // Bot duels give reduced XP scaled by difficulty
    static func botWinXP(difficulty: BotDifficulty) -> Int {
        switch difficulty {
        case .easy: return 15
        case .medium: return 30
        case .hard: return 50
        }
    }

    static func botLoseXP(difficulty: BotDifficulty) -> Int {
        switch difficulty {
        case .easy: return 5
        case .medium: return 10
        case .hard: return 15
        }
    }

    static func botTieXP(difficulty: BotDifficulty) -> Int {
        switch difficulty {
        case .easy: return 10
        case .medium: return 20
        case .hard: return 30
        }
    }

    static func botPerfectBonusXP(difficulty: BotDifficulty) -> Int {
        switch difficulty {
        case .easy: return 5
        case .medium: return 15
        case .hard: return 25
        }
    }
}
