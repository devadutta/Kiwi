import AppKit
import Combine
import Foundation
import SwiftUI
import CoreAudio

/// Controls media playback during recording
class MediaController: ObservableObject {
    static let shared = MediaController()
    
    private init() {
        // MediaController now only handles playback control
    }
    

}

extension UserDefaults {
    func contains(key: String) -> Bool {
        return object(forKey: key) != nil
    }
}
