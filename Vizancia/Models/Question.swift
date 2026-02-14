import Foundation

// MARK: - Question Type
enum QuestionType: String, Codable, CaseIterable {
    case multipleChoice
    case trueFalse
    case matchPairs
    case fillInBlank
    case sortOrder
    case scenarioJudgment
    
    var displayName: String {
        switch self {
        case .multipleChoice: return "Multiple Choice"
        case .trueFalse: return "True or False"
        case .matchPairs: return "Match Pairs"
        case .fillInBlank: return "Fill in the Blank"
        case .sortOrder: return "Sort Order"
        case .scenarioJudgment: return "Scenario Judgment"
        }
    }
}

// MARK: - Difficulty
enum Difficulty: String, Codable, CaseIterable {
    case beginner
    case intermediate
    case advanced
    
    var displayName: String {
        rawValue.capitalized
    }
}

// MARK: - Question
struct Question: Identifiable, Codable {
    let id: String
    let type: QuestionType
    let questionText: String
    let options: [String]
    let correctAnswer: String
    let correctAnswers: [String]
    let matchPairs: [MatchPair]
    let explanation: String
    let difficulty: Difficulty
    
    init(
        id: String = UUID().uuidString,
        type: QuestionType,
        questionText: String,
        options: [String] = [],
        correctAnswer: String = "",
        correctAnswers: [String] = [],
        matchPairs: [MatchPair] = [],
        explanation: String,
        difficulty: Difficulty = .beginner
    ) {
        self.id = id
        self.type = type
        self.questionText = questionText
        self.options = options
        self.correctAnswer = correctAnswer
        self.correctAnswers = correctAnswers.isEmpty && !correctAnswer.isEmpty ? [correctAnswer] : correctAnswers
        self.matchPairs = matchPairs
        self.explanation = explanation
        self.difficulty = difficulty
    }
}

// MARK: - Match Pair
struct MatchPair: Identifiable, Codable, Equatable {
    let id: String
    let term: String
    let definition: String
    
    init(id: String = UUID().uuidString, term: String, definition: String) {
        self.id = id
        self.term = term
        self.definition = definition
    }
}

// MARK: - Lesson
struct LessonData: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let categoryId: String
    let questions: [Question]
    let order: Int
    let difficulty: Difficulty
    
    var questionCount: Int { questions.count }
}

// MARK: - Category
struct CategoryData: Identifiable {
    let id: String
    let name: String
    let icon: String
    let colorName: String
    let description: String
    let lessons: [LessonData]
    let order: Int
    let unlockRequirement: UnlockRequirement
    
    var lessonCount: Int { lessons.count }
    var totalQuestions: Int { lessons.reduce(0) { $0 + $1.questionCount } }
}

// MARK: - Unlock Requirement
enum UnlockRequirement {
    case none
    case completeCategory(String)
    case completeCategoryMinimum(String)
    
    var requiredCategoryId: String? {
        switch self {
        case .none: return nil
        case .completeCategory(let id): return id
        case .completeCategoryMinimum(let id): return id
        }
    }
}

// MARK: - Category Progress
struct CategoryProgress: Codable, Equatable {
    var categoryId: String
    var completedLessonIds: [String]
    var lessonStars: [String: Int]
    var isComplete: Bool
    
    init(categoryId: String, completedLessonIds: [String] = [], lessonStars: [String: Int] = [:], isComplete: Bool = false) {
        self.categoryId = categoryId
        self.completedLessonIds = completedLessonIds
        self.lessonStars = lessonStars
        self.isComplete = isComplete
    }
    
    static func == (lhs: CategoryProgress, rhs: CategoryProgress) -> Bool {
        lhs.categoryId == rhs.categoryId
    }
}

// MARK: - Level Definition
struct LevelDefinition {
    let level: Int
    let title: String
    let xpRequired: Int
    
    static let all: [LevelDefinition] = [
        LevelDefinition(level: 1, title: "AI Curious", xpRequired: 0),
        LevelDefinition(level: 2, title: "Data Explorer", xpRequired: 100),
        LevelDefinition(level: 3, title: "Algorithm Apprentice", xpRequired: 300),
        LevelDefinition(level: 4, title: "Neural Networker", xpRequired: 600),
        LevelDefinition(level: 5, title: "Model Builder", xpRequired: 1000),
        LevelDefinition(level: 6, title: "Prompt Whisperer", xpRequired: 1500),
        LevelDefinition(level: 7, title: "AI Strategist", xpRequired: 2200),
        LevelDefinition(level: 8, title: "Ethics Guardian", xpRequired: 3000),
        LevelDefinition(level: 9, title: "Machine Master", xpRequired: 4000),
        LevelDefinition(level: 10, title: "AI Visionary", xpRequired: 5500),
        LevelDefinition(level: 11, title: "Digital Sage", xpRequired: 7500),
        LevelDefinition(level: 12, title: "Singularity Scholar", xpRequired: 10000),
    ]
}

// MARK: - Daily Goal Tier
enum DailyGoalTier: String, Codable, CaseIterable {
    case casual
    case regular
    case serious
    case intense
    
    var xpTarget: Int {
        switch self {
        case .casual: return 30
        case .regular: return 60
        case .serious: return 100
        case .intense: return 150
        }
    }
    
    var emoji: String {
        switch self {
        case .casual: return "🐢"
        case .regular: return "🚶"
        case .serious: return "🏃"
        case .intense: return "🔥"
        }
    }
}

// MARK: - Game Type
enum GameType: String, CaseIterable, Identifiable {
    case speedRound
    case aiOrNot
    case ethicsCourt
    case promptCraft
    case buzzwordBuster
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .speedRound: return "Speed Round"
        case .aiOrNot: return "AI or Not?"
        case .ethicsCourt: return "Ethics Court"
        case .promptCraft: return "Prompt Craft"
        case .buzzwordBuster: return "Buzzword Buster"
        }
    }
    
    var icon: String {
        switch self {
        case .speedRound: return "bolt.fill"
        case .aiOrNot: return "questionmark.circle.fill"
        case .ethicsCourt: return "scalemass.fill"
        case .promptCraft: return "text.cursor"
        case .buzzwordBuster: return "target"
        }
    }
    
    var description: String {
        switch self {
        case .speedRound: return "20 rapid-fire questions in 5 seconds each!"
        case .aiOrNot: return "Can AI really do this today?"
        case .ethicsCourt: return "You be the judge on AI ethics"
        case .promptCraft: return "Rank prompts from worst to best"
        case .buzzwordBuster: return "Real AI term or total nonsense?"
        }
    }
    
    var color: String {
        switch self {
        case .speedRound: return "#FDCB6E"
        case .aiOrNot: return "#00CEC9"
        case .ethicsCourt: return "#D63031"
        case .promptCraft: return "#E17055"
        case .buzzwordBuster: return "#6C5CE7"
        }
    }
    
    var xpReward: Int {
        switch self {
        case .speedRound: return 40
        case .aiOrNot: return 30
        case .ethicsCourt: return 50
        case .promptCraft: return 35
        case .buzzwordBuster: return 30
        }
    }
}
