import Foundation

class StreakService {
    static let shared = StreakService()
    
    func updateStreak(for user: UserProfile) {
        let today = Date().startOfDay
        guard let lastActive = user.lastActiveDate else {
            user.currentStreak = 1
            user.lastActiveDate = today
            return
        }
        let lastActiveDay = lastActive.startOfDay
        if lastActiveDay.isSameDay(as: today) { return }
        let daysSince = lastActiveDay.daysBetween(today)
        if daysSince == 1 {
            user.currentStreak += 1
            if user.currentStreak > user.longestStreak { user.longestStreak = user.currentStreak }
            checkStreakFreeze(for: user)
        } else if daysSince == 2 && user.streakFreezes > 0 {
            user.streakFreezes -= 1
            user.currentStreak += 1
            if user.currentStreak > user.longestStreak { user.longestStreak = user.currentStreak }
        } else {
            user.currentStreak = 1
        }
        user.lastActiveDate = today
    }
    
    func checkStreakFreeze(for user: UserProfile) {
        if user.currentStreak > 0 && user.currentStreak % 7 == 0 && user.streakFreezes < 2 {
            user.streakFreezes = min(2, user.streakFreezes + 1)
        }
    }
    
    func streakMilestones() -> [Int] { [3, 7, 14, 30, 60, 100, 365] }
    
    func isStreakMilestone(_ streak: Int) -> Bool { streakMilestones().contains(streak) }
}
