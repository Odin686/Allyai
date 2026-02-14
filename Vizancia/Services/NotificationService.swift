import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    private let messages = [
        "Your AI knowledge streak is waiting! 🔥",
        "5 minutes of learning today keeps the AI confusion away 🧠",
        "Your brain called — it wants more AI facts! ⚡",
        "Quick lesson? It only takes 2 minutes! 🎯",
        "Time to level up your AI knowledge! 🚀",
        "Your daily AI lesson awaits! 📚",
        "Stay curious — learn something new about AI today! ✨",
        "AI is changing the world. Stay ahead of the curve! 🌍"
    ]
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }
    
    func scheduleReminders(at time: Date, days: [Int], streak: Int) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)
        
        for day in days {
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            dateComponents.weekday = day
            
            var message = messages.randomElement() ?? messages[0]
            if streak > 0 {
                message = "Don't break your \(streak)-day streak! Keep going! 🏔️"
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Vizancia"
            content.body = message
            content.sound = .default
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "reminder_\(day)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func scheduleDailyReminder(hour: Int, minute: Int) {
        scheduleReminders(at: {
            var components = DateComponents()
            components.hour = hour
            components.minute = minute
            return Calendar.current.date(from: components) ?? Date()
        }(), days: [1, 2, 3, 4, 5, 6, 7], streak: 0)
    }
}
