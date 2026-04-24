import Foundation
import GameKit
import SwiftUI

// MARK: - GameKit Service
@MainActor
class GameKitService: NSObject, ObservableObject {
    static let shared = GameKitService()

    // MARK: - Leaderboard IDs
    static let totalXPLeaderboard = "ca.vizancia.xp.total"
    static let weeklyXPLeaderboard = "ca.vizancia.xp.weekly"
    static let duelWinsLeaderboard = "ca.vizancia.duels.wins"

    // MARK: - Published State
    @Published var isAuthenticated = false
    @Published var localPlayerName = ""
    @Published var localPlayerPhoto: UIImage?
    @Published var authError: String?

    private override init() {
        super.init()
    }

    // MARK: - Authentication

    func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            Task { @MainActor in
                guard let self else { return }

                if let error {
                    self.authError = error.localizedDescription
                    self.isAuthenticated = false
                    return
                }

                if let vc = viewController {
                    // Present Game Center sign-in
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootVC = windowScene.windows.first?.rootViewController {
                        rootVC.present(vc, animated: true)
                    }
                    return
                }

                // Successfully authenticated
                let player = GKLocalPlayer.local
                self.isAuthenticated = player.isAuthenticated
                self.localPlayerName = player.displayName

                if player.isAuthenticated {
                    // Register for turn-based events
                    player.register(self)

                    // Load player photo
                    Task {
                        do {
                            let image = try await player.loadPhoto(for: .small)
                            await MainActor.run {
                                self.localPlayerPhoto = image
                            }
                        } catch {
                            // Photo loading is optional — fail silently
                        }
                    }
                }
            }
        }
    }

    // MARK: - Score Submission

    func submitScore(_ score: Int, to leaderboardID: String) {
        guard isAuthenticated else { return }
        Task {
            do {
                try await GKLeaderboard.submitScore(
                    score,
                    context: 0,
                    player: GKLocalPlayer.local,
                    leaderboardIDs: [leaderboardID]
                )
            } catch {
                // Score submission failure is not critical — fail silently
                print("GameKit: Failed to submit score: \(error.localizedDescription)")
            }
        }
    }

    func submitTotalXP(_ totalXP: Int) {
        submitScore(totalXP, to: Self.totalXPLeaderboard)
    }

    func submitWeeklyXP(_ weeklyXP: Int) {
        submitScore(weeklyXP, to: Self.weeklyXPLeaderboard)
    }

    func submitDuelWins(_ wins: Int) {
        submitScore(wins, to: Self.duelWinsLeaderboard)
    }

    // MARK: - Load Leaderboard Scores

    func loadTopScores(for leaderboardID: String, count: Int = 10) async -> [LeaderboardPlayer] {
        guard isAuthenticated else { return [] }
        do {
            let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [leaderboardID])
            guard let leaderboard = leaderboards.first else { return [] }

            let (_, scores, _) = try await leaderboard.loadEntries(
                for: .global,
                timeScope: .allTime,
                range: NSRange(location: 1, length: count)
            )

            return scores.map { entry in
                LeaderboardPlayer(
                    rank: entry.rank,
                    displayName: entry.player.displayName,
                    score: entry.score,
                    isLocalPlayer: entry.player == GKLocalPlayer.local
                )
            }
        } catch {
            print("GameKit: Failed to load scores: \(error.localizedDescription)")
            return []
        }
    }

    func loadLocalPlayerEntry(for leaderboardID: String) async -> LeaderboardPlayer? {
        guard isAuthenticated else { return nil }
        do {
            let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [leaderboardID])
            guard let leaderboard = leaderboards.first else { return nil }

            let (localEntry, _, _) = try await leaderboard.loadEntries(
                for: .global,
                timeScope: .allTime,
                range: NSRange(location: 1, length: 1)
            )

            guard let entry = localEntry else { return nil }
            return LeaderboardPlayer(
                rank: entry.rank,
                displayName: entry.player.displayName,
                score: entry.score,
                isLocalPlayer: true
            )
        } catch {
            return nil
        }
    }

    // MARK: - Show Game Center Dashboard

    func showGameCenterDashboard() {
        guard isAuthenticated else { return }
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            let gcVC = GKGameCenterViewController(state: .default)
            gcVC.gameCenterDelegate = self
            rootVC.present(gcVC, animated: true)
        }
    }

    func showLeaderboard(_ leaderboardID: String) {
        guard isAuthenticated else { return }
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            let gcVC = GKGameCenterViewController(
                leaderboardID: leaderboardID,
                playerScope: .global,
                timeScope: .allTime
            )
            gcVC.gameCenterDelegate = self
            rootVC.present(gcVC, animated: true)
        }
    }
}

// MARK: - GKGameCenterControllerDelegate
extension GameKitService: GKGameCenterControllerDelegate {
    nonisolated func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        Task { @MainActor in
            gameCenterViewController.dismiss(animated: true)
        }
    }
}

// MARK: - GKLocalPlayerListener (Turn-Based Events)
extension GameKitService: GKLocalPlayerListener {
    nonisolated func player(_ player: GKPlayer, receivedTurnEventFor match: GKTurnBasedMatch, didBecomeActive: Bool) {
        Task { @MainActor in
            NotificationCenter.default.post(name: .duelTurnReceived, object: match)
        }
    }

    nonisolated func player(_ player: GKPlayer, matchEnded match: GKTurnBasedMatch) {
        Task { @MainActor in
            NotificationCenter.default.post(name: .duelMatchEnded, object: match)
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let duelTurnReceived = Notification.Name("duelTurnReceived")
    static let duelMatchEnded = Notification.Name("duelMatchEnded")
}

// MARK: - Leaderboard Player
struct LeaderboardPlayer: Identifiable {
    let id = UUID()
    let rank: Int
    let displayName: String
    let score: Int
    let isLocalPlayer: Bool
}
