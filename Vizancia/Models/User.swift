import Foundation
import SwiftData

@Model
class UserProfile {
    var name: String
    var totalXP: Int
    var currentLevel: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastActiveDate: Date?
    var dailyXPGoal: Int
    var hearts: Int
    var heartsLastRefill: Date
    var streakFreezes: Int
    var totalLessonsCompleted: Int
    var totalCorrectAnswers: Int
    var totalQuestionsAnswered: Int
    var totalTimeLearning: TimeInterval
    var onboardingCompleted: Bool
    var soundEnabled: Bool
    var hapticsEnabled: Bool
    var notificationsEnabled: Bool
    var completedLessonIDs: [String]
    var perfectLessonIDs: [String]
    var unlockedAchievementIds: [String]
    var gameHighScores: [String: Int]
    var dailyXPLog: [String: Int]
    var categoryProgressList: [CategoryProgress]
    var gamesPlayed: Int
    var todayXP: Int
    var activeDays: [String]
    var dailyGoalTierRaw: String

    init(
        name: String = "Learner",
        dailyXPGoal: Int = 60
    ) {
        self.name = name
        self.totalXP = 0
        self.currentLevel = 1
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastActiveDate = nil
        self.dailyXPGoal = dailyXPGoal
        self.hearts = 5
        self.heartsLastRefill = Date().startOfDay
        self.streakFreezes = 0
        self.totalLessonsCompleted = 0
        self.totalCorrectAnswers = 0
        self.totalQuestionsAnswered = 0
        self.totalTimeLearning = 0
        self.onboardingCompleted = false
        self.soundEnabled = true
        self.hapticsEnabled = true
        self.notificationsEnabled = true
        self.completedLessonIDs = []
        self.perfectLessonIDs = []
        self.unlockedAchievementIds = []
        self.gameHighScores = [:]
        self.dailyXPLog = [:]
        self.categoryProgressList = []
        self.gamesPlayed = 0
        self.todayXP = 0
        self.activeDays = []
        self.dailyGoalTierRaw = "casual"
    }

    // MARK: - Daily Goal Tier
    var dailyGoalTier: DailyGoalTier {
        get { DailyGoalTier(rawValue: dailyGoalTierRaw) ?? .casual }
        set { dailyGoalTierRaw = newValue.rawValue }
    }

    // MARK: - Computed Properties

    var levelTitle: String {
        LevelDefinition.all.last(where: { $0.xpRequired <= totalXP })?.title ?? "AI Curious"
    }

    var xpForCurrentLevel: Int {
        let currentLevelDef = LevelDefinition.all.last(where: { $0.xpRequired <= totalXP })
        return currentLevelDef?.xpRequired ?? 0
    }

    var xpForNextLevel: Int {
        let nextLevelDef = LevelDefinition.all.first(where: { $0.xpRequired > totalXP })
        return nextLevelDef?.xpRequired ?? 10000
    }

    var levelProgress: Double {
        let current = xpForCurrentLevel
        let next = xpForNextLevel
        guard next > current else { return 1.0 }
        return Double(totalXP - current) / Double(next - current)
    }

    var dailyGoalProgress: Double {
        guard dailyXPGoal > 0 else { return 0 }
        return min(1.0, Double(todayXP) / Double(dailyXPGoal))
    }

    var dailyGoalMet: Bool {
        todayXP >= dailyXPGoal
    }

    var accuracyRate: Double {
        guard totalQuestionsAnswered > 0 else { return 0 }
        return Double(totalCorrectAnswers) / Double(totalQuestionsAnswered)
    }

    // MARK: - Methods

    func addXP(_ xp: Int) {
        totalXP += xp
        updateLevel()
    }

    func updateLevel() {
        let newLevel = LevelDefinition.all.last(where: { $0.xpRequired <= totalXP })?.level ?? 1
        currentLevel = newLevel
    }

    func loseHeart() {
        if hearts > 0 {
            hearts -= 1
        }
    }

    func refillHearts() {
        hearts = 5
        heartsLastRefill = Date().startOfDay
    }

    func checkHeartRefill() {
        let today = Date().startOfDay
        if heartsLastRefill < today {
            refillHearts()
        }
    }

    func earnHeart() {
        hearts = min(5, hearts + 1)
    }
}
