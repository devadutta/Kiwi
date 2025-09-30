import SwiftUI
import AppKit

class NotchWindowManager: ObservableObject {
    @Published var isVisible = false
    private var windowController: NSWindowController?
    var notchPanel: NotchRecorderPanel?
    private var hostingController: NotchRecorderHostingController<AnyView>?
    private let whisperState: WhisperState
    private let recorder: Recorder
    
    init(whisperState: WhisperState, recorder: Recorder) {
        self.whisperState = whisperState
        self.recorder = recorder
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleHideNotification),
            name: NSNotification.Name("HideNotchRecorder"),
            object: nil
        )
        
        // Pre-create the window for instant first show
        initializeWindowIfNeeded()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        cleanupWindow()
    }
    
    @objc private func handleHideNotification() {
        hide()
    }
    
    func show() {
        if isVisible { return }
        
        // Ensure window is created (should already be from init)
        initializeWindowIfNeeded()
        
        // Update window position for current screen
        let metrics = NotchRecorderPanel.calculateWindowMetrics()
        notchPanel?.setFrame(metrics.frame, display: false)
        
        self.isVisible = true
        notchPanel?.orderFrontRegardless()
    }
    
    func hide() {
        guard isVisible else { return }
        
        self.isVisible = false
        notchPanel?.orderOut(nil)
    }
    
    private func initializeWindowIfNeeded() {
        // Only create if it doesn't exist
        guard notchPanel == nil else { return }
        
        let metrics = NotchRecorderPanel.calculateWindowMetrics()
        let panel = NotchRecorderPanel(contentRect: metrics.frame)
        
        let notchRecorderView = NotchRecorderView(whisperState: whisperState, recorder: recorder)
            .environmentObject(self)
            .environmentObject(whisperState.enhancementService!)
        
        let hostingController = NotchRecorderHostingController(rootView: AnyView(notchRecorderView))
        panel.contentView = hostingController.view
        
        self.notchPanel = panel
        self.hostingController = hostingController
        self.windowController = NSWindowController(window: panel)
    }
    
    private func cleanupWindow() {
        notchPanel?.close()
        windowController = nil
        notchPanel = nil
        hostingController = nil
    }
    
    func toggle() {
        if isVisible {
            hide()
        } else {
            show()
        }
    }
} 
