import SwiftUI
import AppKit

class MiniWindowManager: ObservableObject {
    @Published var isVisible = false
    private var windowController: NSWindowController?
    private var miniPanel: MiniRecorderPanel?
    private var hostingController: NSHostingController<AnyView>?
    private let whisperState: WhisperState
    private let recorder: Recorder
    
    init(whisperState: WhisperState, recorder: Recorder) {
        self.whisperState = whisperState
        self.recorder = recorder
        setupNotifications()
        // Pre-create the window for instant first show
        initializeWindowIfNeeded()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        cleanupWindow()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleHideNotification),
            name: NSNotification.Name("HideMiniRecorder"),
            object: nil
        )
    }
    
    @objc private func handleHideNotification() {
        hide()
    }
    
    func show() {
        if isVisible { return }
        
        // Ensure window exists (should already be pre-created)
        initializeWindowIfNeeded()
        
        // Update position for current screen
        let metrics = MiniRecorderPanel.calculateWindowMetrics()
        miniPanel?.setFrame(metrics, display: false)
        
        self.isVisible = true
        miniPanel?.orderFrontRegardless()
    }
    
    func hide() {
        guard isVisible else { return }
        
        self.isVisible = false
        miniPanel?.orderOut(nil)
    }
    
    private func initializeWindowIfNeeded() {
        // Only create if it doesn't exist
        guard miniPanel == nil else { return }
        
        let metrics = MiniRecorderPanel.calculateWindowMetrics()
        let panel = MiniRecorderPanel(contentRect: metrics)
        
        let miniRecorderView = MiniRecorderView(whisperState: whisperState, recorder: recorder)
            .environmentObject(self)
            .environmentObject(whisperState.enhancementService!)
        
        let hostingController = NSHostingController(rootView: AnyView(miniRecorderView))
        panel.contentView = hostingController.view
        
        self.miniPanel = panel
        self.hostingController = hostingController
        self.windowController = NSWindowController(window: panel)
    }
    
    private func cleanupWindow() {
        miniPanel?.close()
        windowController = nil
        miniPanel = nil
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
