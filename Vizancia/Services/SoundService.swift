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
    }
    
    func play(_ effect: SoundEffect) {
        guard isEnabled else { return }
        // System sounds as fallback since we don't bundle audio files
        switch effect {
        case .correct:
            AudioServicesPlaySystemSound(1057)
        case .wrong:
            AudioServicesPlaySystemSound(1053)
        case .lessonComplete:
            AudioServicesPlaySystemSound(1025)
        case .levelUp:
            AudioServicesPlaySystemSound(1026)
        case .streak:
            AudioServicesPlaySystemSound(1020)
        case .tap:
            AudioServicesPlaySystemSound(1104)
        }
    }
}
