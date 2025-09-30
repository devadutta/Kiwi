import Foundation
import AppKit
import SwiftUI

class SoundManager {
    static let shared = SoundManager()
    
    @AppStorage("isSoundFeedbackEnabled") private var isSoundFeedbackEnabled = true
    
    private init() {
        // No initialization needed for system sounds - they're always ready!
    }
    
    func playStartSound() {
        guard isSoundFeedbackEnabled else { return }
        // Use system sound for recording start - instant and no loading required
        NSSound.beep()
    }
    
    func playStopSound() {
        guard isSoundFeedbackEnabled else { return }
        // Use system sound for recording stop - instant and no loading required  
        NSSound.beep()
    }
    
    func playEscSound() {
        guard isSoundFeedbackEnabled else { return }
        // Use system sound for escape - instant and no loading required
        NSSound.beep()
    }
    
    var isEnabled: Bool {
        get { isSoundFeedbackEnabled }
        set { isSoundFeedbackEnabled = newValue }
    }
} 
