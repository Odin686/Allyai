import Foundation

struct AchievementData: Identifiable {
    let id: String
    let name: String
    let icon: String
    let description: String
    let condition: (UserProfile) -> Bool
    
    static let all: [AchievementData] = [
        AchievementData(
            id: "first_steps",
            name: "First Steps",
            icon: "🌱",
            description: "Complete your first lesson",
            condition: { $0.totalLessonsCompleted >= 1 }
        ),
        AchievementData(
            id: "on_fire",
            name: "On Fire",
            icon: "🔥",
            description: "Achieve a 3-day streak",
            condition: { $0.currentStreak >= 3 }
        ),
        AchievementData(
            id: "dedicated_learner",
            name: "Dedicated Learner",
            icon: "🏔️",
            description: "Achieve a 7-day streak",
            condition: { $0.currentStreak >= 7 }
        ),
        AchievementData(
            id: "perfectionist",
            name: "Perfectionist",
            icon: "💯",
            description: "Get a perfect score on 5 lessons",
            condition: { $0.perfectLessonIDs.count >= 5 }
        ),
        AchievementData(
            id: "ai_basics_master",
            name: "AI Basics Master",
            icon: "🧠",
            description: "Complete all AI Basics lessons",
            condition: { $0.categoryProgressList.first(where: { $0.categoryId == "ai_basics" })?.isComplete ?? false }
        ),
        AchievementData(
            id: "speed_demon",
            name: "Speed Demon",
            icon: "⚡",
            description: "Score 15+ in Speed Round",
            condition: { ($0.gameHighScores["speedRound"] ?? 0) >= 15 }
        ),
        AchievementData(
            id: "sharpshooter",
            name: "Sharpshooter",
            icon: "🎯",
            description: "Answer 100 questions correctly",
            condition: { $0.totalCorrectAnswers >= 100 }
        ),
        AchievementData(
            id: "well_rounded",
            name: "Well-Rounded",
            icon: "🌍",
            description: "Complete at least 1 lesson in every category",
            condition: { profile in
                let allCats = LessonContentProvider.shared.allCategories
                return allCats.allSatisfy { cat in
                    profile.categoryProgressList.first(where: { $0.categoryId == cat.id })?.completedLessonIds.isEmpty == false
                }
            }
        ),
        AchievementData(
            id: "half_way",
            name: "Halfway There",
            icon: "🏆",
            description: "Complete 30 lessons",
            condition: { $0.totalLessonsCompleted >= 30 }
        ),
        AchievementData(
            id: "graduate",
            name: "Graduate",
            icon: "🎓",
            description: "Complete all categories",
            condition: { profile in
                let allCats = LessonContentProvider.shared.allCategories
                return allCats.allSatisfy { cat in
                    profile.categoryProgressList.first(where: { $0.categoryId == cat.id })?.isComplete ?? false
                }
            }
        ),
        AchievementData(
            id: "game_night",
            name: "Game Night",
            icon: "🕹️",
            description: "Play 10 mini-games",
            condition: { $0.gamesPlayed >= 10 }
        ),
        AchievementData(
            id: "bookworm",
            name: "Bookworm",
            icon: "📚",
            description: "Complete 50 total lessons",
            condition: { $0.totalLessonsCompleted >= 50 }
        ),
        AchievementData(
            id: "ethics_expert",
            name: "Ethics Expert",
            icon: "🔬",
            description: "Complete all AI Ethics lessons",
            condition: { $0.categoryProgressList.first(where: { $0.categoryId == "ai_ethics" })?.isComplete ?? false }
        ),
        AchievementData(
            id: "survivor",
            name: "Survivor",
            icon: "❤️",
            description: "Complete a lesson with only 1 heart remaining",
            condition: { $0.unlockedAchievementIds.contains("survivor") }
        ),
        AchievementData(
            id: "century_club",
            name: "Century Club",
            icon: "🎉",
            description: "Earn a 100-day streak",
            condition: { $0.currentStreak >= 100 }
        ),
        AchievementData(
            id: "rising_star",
            name: "Rising Star",
            icon: "⭐",
            description: "Reach Level 5",
            condition: { $0.currentLevel >= 5 }
        ),
        AchievementData(
            id: "to_the_moon",
            name: "To the Moon",
            icon: "🚀",
            description: "Reach Level 10",
            condition: { $0.currentLevel >= 10 }
        ),
        AchievementData(
            id: "puzzle_master",
            name: "Puzzle Master",
            icon: "🧩",
            description: "Score 10+ in Buzzword Buster",
            condition: { ($0.gameHighScores["buzzwordBuster"] ?? 0) >= 10 }
        ),
        AchievementData(
            id: "prompt_pro",
            name: "Prompt Pro",
            icon: "🤖",
            description: "Complete all Prompt Engineering lessons",
            condition: { $0.categoryProgressList.first(where: { $0.categoryId == "prompt_engineering" })?.isComplete ?? false }
        ),
        AchievementData(
            id: "ai_visionary",
            name: "AI Visionary",
            icon: "🌟",
            description: "Reach Level 12 (max level)",
            condition: { $0.currentLevel >= 12 }
        ),
    ]
}
