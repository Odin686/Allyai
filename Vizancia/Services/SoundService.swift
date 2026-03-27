import Foundation
import AVFoundation

class SoundService {
    static let shared = SoundService()
    var isEnabled = true
    private var audioPlayer: AVAudioPlayer?

    enum SoundEffect: String {
        case correct = "correct"
        case wrong = "wrong"
        case lessonComplete = "lesson_complete"
        case levelUp = "level_up"
        case streak = "streak"
        case tap = "tap"
        case select = "select"
        case comboTick = "combo_tick"
        case whoosh = "whoosh"
        case cardFlip = "card_flip"
        case perfectFanfare = "perfect_fanfare"
    }

    func play(_ effect: SoundEffect) {
        guard isEnabled else { return }
        switch effect {
        case .correct:
            AudioServicesPlaySystemSound(1057)
        case .wrong:
            AudioServicesPlaySystemSound(1053)
        case .lessonComplete:
            AudioServicesPlaySystemSound(1025)
        case .levelUp:
            // Distinct rising fanfare
            AudioServicesPlaySystemSound(1026)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                AudioServicesPlaySystemSound(1027)
            }
        case .streak:
            AudioServicesPlaySystemSound(1020)
        case .tap:
            AudioServicesPlaySystemSound(1104)
        case .select:
            // Subtle pop on answer selection
            AudioServicesPlaySystemSound(1519)
        case .comboTick:
            // Rising pitch for combos
            AudioServicesPlaySystemSound(1306)
        case .whoosh:
            // Page transition
            AudioServicesPlaySystemSound(1001)
        case .cardFlip:
            // Card flip sound
            AudioServicesPlaySystemSound(1105)
        case .perfectFanfare:
            // Celebration sequence
            AudioServicesPlaySystemSound(1025)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                AudioServicesPlaySystemSound(1026)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                AudioServicesPlaySystemSound(1027)
            }
        }
    }
}
