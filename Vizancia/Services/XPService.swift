import Foundation

class XPService {
    static let shared = XPService()
    
    let correctFirstTry = 15
    let correctRetry = 5
    let lessonBonus = 25
    let perfectLessonBonus = 50
    let dailyGoalBonus = 30
    
    func xpForCorrectAnswer(firstTry: Bool) -> Int {
        firstTry ? correctFirstTry : correctRetry
    }
    
    func xpForLessonComplete(isPerfect: Bool) -> Int {
        var xp = lessonBonus
        if isPerfect { xp += perfectLessonBonus }
        return xp
    }
    
    func levelFor(xp: Int) -> LevelDefinition {
        LevelDefinition.all.last(where: { $0.xpRequired <= xp }) ?? LevelDefinition.all[0]
    }
    
    func didLevelUp(oldXP: Int, newXP: Int) -> LevelDefinition? {
        let oldLevel = levelFor(xp: oldXP)
        let newLevel = levelFor(xp: newXP)
        return newLevel.level > oldLevel.level ? newLevel : nil
    }
    
    func progressToNextLevel(xp: Int) -> Double {
        let current = levelFor(xp: xp)
        guard let nextIndex = LevelDefinition.all.firstIndex(where: { $0.level == current.level + 1 }) else { return 1.0 }
        let next = LevelDefinition.all[nextIndex]
        let range = next.xpRequired - current.xpRequired
        guard range > 0 else { return 1.0 }
        return Double(xp - current.xpRequired) / Double(range)
    }
}
