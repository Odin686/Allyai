import Foundation
import SwiftData

// MARK: - Spaced Repetition Card
struct SpacedRepetitionCard: Codable {
    var box: Int              // 1-5 (Leitner box)
    var lastReviewDate: Date?
    var correctCount: Int
    var incorrectCount: Int
    var totalReviews: Int
}

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
    var missedQuestionIds: [String] = []
    var lastDailyChallengeDate: String = ""
    var dailyChallengeStreak: Int = 0
    var categoryCorrectCounts: [String: Int] = [:]
    var categoryQuestionCounts: [String: Int] = [:]
    var inProgressLessonId: String = ""
    var inProgressQuestionIndex: Int = 0
    var inProgressCorrectCount: Int = 0
    var inProgressXPEarned: Int = 0
    var inProgressQuestionOrder: [String] = []
    var experienceLevelRaw: String = "beginner"
    var userRoleRaw: String = "curious"
    var userName: String = ""
    var duelWins: Int = 0
    var duelLosses: Int = 0
    var duelTies: Int = 0
    var totalDuelsPlayed: Int = 0
    var spacedRepetitionCardsData: Data = Data()

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
        self.missedQuestionIds = []
        self.lastDailyChallengeDate = ""
        self.dailyChallengeStreak = 0
        self.categoryCorrectCounts = [:]
        self.categoryQuestionCounts = [:]
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

    // MARK: - Spaced Repetition Cards (stored as Data for SwiftData)
    var spacedRepetitionCards: [String: SpacedRepetitionCard] {
        get {
            guard !spacedRepetitionCardsData.isEmpty,
                  let decoded = try? JSONDecoder().decode([String: SpacedRepetitionCard].self, from: spacedRepetitionCardsData)
            else { return [:] }
            return decoded
        }
        set {
            spacedRepetitionCardsData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
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

    func addMissedQuestion(_ questionId: String) {
        if !missedQuestionIds.contains(questionId) {
            missedQuestionIds.append(questionId)
        }
    }

    func removeMissedQuestion(_ questionId: String) {
        missedQuestionIds.removeAll { $0 == questionId }
    }

    func saveLessonProgress(lessonId: String, questionIndex: Int, correctCount: Int, xpEarned: Int, questionOrder: [String]) {
        inProgressLessonId = lessonId
        inProgressQuestionIndex = questionIndex
        inProgressCorrectCount = correctCount
        inProgressXPEarned = xpEarned
        inProgressQuestionOrder = questionOrder
    }

    func clearLessonProgress() {
        inProgressLessonId = ""
        inProgressQuestionIndex = 0
        inProgressCorrectCount = 0
        inProgressXPEarned = 0
        inProgressQuestionOrder = []
    }

    func recordCategoryAnswer(categoryId: String, correct: Bool) {
        categoryQuestionCounts[categoryId] = (categoryQuestionCounts[categoryId] ?? 0) + 1
        if correct {
            categoryCorrectCounts[categoryId] = (categoryCorrectCounts[categoryId] ?? 0) + 1
        }
    }

    func categoryAccuracy(for categoryId: String) -> Double {
        let total = categoryQuestionCounts[categoryId] ?? 0
        let correct = categoryCorrectCounts[categoryId] ?? 0
        guard total > 0 else { return 0 }
        return Double(correct) / Double(total)
    }

    var hasCompletedDailyChallenge: Bool {
        lastDailyChallengeDate == Date().dateKey
    }

    enum ExperienceLevel: String, CaseIterable {
        case beginner, familiar, regular, builder
        var displayName: String {
            switch self {
            case .beginner: return "Beginner"
            case .familiar: return "Familiar"
            case .regular: return "Regular User"
            case .builder: return "Builder"
            }
        }
    }

    enum UserRole: String, CaseIterable {
        case curious, student, professional, fun
        var displayName: String {
            switch self {
            case .curious: return "Curiosity"
            case .student: return "School / Study"
            case .professional: return "Career"
            case .fun: return "Just for Fun"
            }
        }
    }

    var experienceLevel: ExperienceLevel {
        get { ExperienceLevel(rawValue: experienceLevelRaw) ?? .beginner }
        set { experienceLevelRaw = newValue.rawValue }
    }

    var userRole: UserRole {
        get { UserRole(rawValue: userRoleRaw) ?? .curious }
        set { userRoleRaw = newValue.rawValue }
    }

    func completeDailyChallenge(xp: Int) {
        let today = Date().dateKey
        let yesterday = Date().daysAgo(1).dateKey
        if lastDailyChallengeDate == yesterday {
            dailyChallengeStreak += 1
        } else if lastDailyChallengeDate != today {
            dailyChallengeStreak = 1
        }
        lastDailyChallengeDate = today
        addXP(xp)
        todayXP += xp
    }

    /// Records today as an active day and logs XP earned.
    func recordActivity(xpEarned: Int = 0) {
        let today = Date().dateKey
        if !activeDays.contains(today) {
            activeDays.append(today)
        }
        dailyXPLog[today] = (dailyXPLog[today] ?? 0) + xpEarned
    }
}
