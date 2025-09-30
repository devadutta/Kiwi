import Foundation
import KeyboardShortcuts
import Carbon
import AppKit

extension KeyboardShortcuts.Name {
    static let toggleMiniRecorder = Self("toggleMiniRecorder")
    static let toggleMiniRecorder2 = Self("toggleMiniRecorder2")
    static let pasteLastTranscription = Self("pasteLastTranscription")
    
    // Power Mode shortcuts - dynamically created based on config IDs
    static func powerMode(_ configId: UUID) -> Self {
        return Self("powerMode_\(configId.uuidString)")
    }
}

@MainActor
class HotkeyManager: ObservableObject {
    @Published var selectedHotkey1: HotkeyOption {
        didSet {
            UserDefaults.standard.set(selectedHotkey1.rawValue, forKey: "selectedHotkey1")
            setupHotkeyMonitoring()
        }
    }
    @Published var selectedHotkey2: HotkeyOption {
        didSet {
            if selectedHotkey2 == .none {
                KeyboardShortcuts.setShortcut(nil, for: .toggleMiniRecorder2)
            }
            UserDefaults.standard.set(selectedHotkey2.rawValue, forKey: "selectedHotkey2")
            setupHotkeyMonitoring()
        }
    }
    
    private var whisperState: WhisperState
    private var miniRecorderShortcutManager: MiniRecorderShortcutManager
    
    // Power Mode hotkey management
    private var powerModeHotkeyObserver: Any?
    
    // MARK: - Helper Properties
    private var canProcessHotkeyAction: Bool {
        whisperState.recordingState != .transcribing && whisperState.recordingState != .enhancing && whisperState.recordingState != .busy
    }
    
    // NSEvent monitoring for modifier keys
    private var globalEventMonitor: Any?
    private var localEventMonitor: Any?
    
    // Key state tracking
    private var currentKeyState = false
    private var keyPressStartTime: Date?
    private let briefPressThreshold = 1.7
    private var isHandsFreeMode = false
    
    // Debounce for Fn key
    private var fnDebounceTask: Task<Void, Never>?
    private var pendingFnKeyState: Bool? = nil
    
    // Performance optimization: Event debouncing and smart monitoring
    private var lastEventTime: Date = Date.distantPast
    private let eventDebounceInterval: TimeInterval = 0.05 // 50ms debounce
    private var isMonitoringEnabled = true
    private var appActiveObserver: Any?
    
    // Keyboard shortcut state tracking
    private var shortcutKeyPressStartTime: Date?
    private var isShortcutHandsFreeMode = false
    private var shortcutCurrentKeyState = false
    private var lastShortcutTriggerTime: Date?
    private let shortcutCooldownInterval: TimeInterval = 0.5
    
    enum HotkeyOption: String, CaseIterable {
        case none = "none"
        case rightOption = "rightOption"
        case leftOption = "leftOption"
        case leftControl = "leftControl" 
        case rightControl = "rightControl"
        case fn = "fn"
        case rightCommand = "rightCommand"
        case rightShift = "rightShift"
        case custom = "custom"
        
        var displayName: String {
            switch self {
            case .none: return "None"
            case .rightOption: return "Right Option (⌥)"
            case .leftOption: return "Left Option (⌥)"
            case .leftControl: return "Left Control (⌃)"
            case .rightControl: return "Right Control (⌃)"
            case .fn: return "Fn"
            case .rightCommand: return "Right Command (⌘)"
            case .rightShift: return "Right Shift (⇧)"
            case .custom: return "Custom"
            }
        }
        
        var keyCode: CGKeyCode? {
            switch self {
            case .rightOption: return 0x3D
            case .leftOption: return 0x3A
            case .leftControl: return 0x3B
            case .rightControl: return 0x3E
            case .fn: return 0x3F
            case .rightCommand: return 0x36
            case .rightShift: return 0x3C
            case .custom, .none: return nil
            }
        }
        
        var isModifierKey: Bool {
            return self != .custom && self != .none
        }
    }
    
    init(whisperState: WhisperState) {
        // One-time migration from legacy single-hotkey settings
        if UserDefaults.standard.object(forKey: "didMigrateHotkeys_v2") == nil {
            // If legacy push-to-talk modifier key was enabled, carry it over
            if UserDefaults.standard.bool(forKey: "isPushToTalkEnabled"),
               let legacyRaw = UserDefaults.standard.string(forKey: "pushToTalkKey"),
               let legacyKey = HotkeyOption(rawValue: legacyRaw) {
                UserDefaults.standard.set(legacyKey.rawValue, forKey: "selectedHotkey1")
            }
            // If a custom shortcut existed, mark hotkey-1 as custom (shortcut itself already persisted)
            if KeyboardShortcuts.getShortcut(for: .toggleMiniRecorder) != nil {
                UserDefaults.standard.set(HotkeyOption.custom.rawValue, forKey: "selectedHotkey1")
            }
            // Leave second hotkey as .none
            UserDefaults.standard.set(true, forKey: "didMigrateHotkeys_v2")
        }
        // ---- normal initialisation ----
        self.selectedHotkey1 = HotkeyOption(rawValue: UserDefaults.standard.string(forKey: "selectedHotkey1") ?? "") ?? .rightCommand
        self.selectedHotkey2 = HotkeyOption(rawValue: UserDefaults.standard.string(forKey: "selectedHotkey2") ?? "") ?? .none
        self.whisperState = whisperState
        self.miniRecorderShortcutManager = MiniRecorderShortcutManager(whisperState: whisperState)

        if KeyboardShortcuts.getShortcut(for: .pasteLastTranscription) == nil {
            let defaultPasteShortcut = KeyboardShortcuts.Shortcut(.v, modifiers: [.command, .option])
            KeyboardShortcuts.setShortcut(defaultPasteShortcut, for: .pasteLastTranscription)
        }
        
        KeyboardShortcuts.onKeyUp(for: .pasteLastTranscription) { [weak self] in
            guard let self = self else { return }
            Task { @MainActor in
                LastTranscriptionService.pasteLastTranscription(from: self.whisperState.modelContext)
            }
        }
        
        NSLog("🔧 HotkeyManager: Initializing...")
        
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 100_000_000)
            NSLog("🔧 HotkeyManager: Setting up hotkey monitoring...")
            self.setupHotkeyMonitoring()
            NSLog("🔧 HotkeyManager: Setting up Power Mode hotkeys...")
            self.setupPowerModeHotkeys()
            NSLog("🔧 HotkeyManager: Setting up app state monitoring...")
            self.setupAppStateMonitoring()
            NSLog("🔧 HotkeyManager: Initialization complete")
        }
    }
    
    private func setupHotkeyMonitoring() {
        removeAllMonitoring()
        
        setupModifierKeyMonitoring()
        setupCustomShortcutMonitoring()
    }
    
    private func setupModifierKeyMonitoring() {
        // Only set up if at least one hotkey is a modifier key
        guard (selectedHotkey1.isModifierKey && selectedHotkey1 != .none) || (selectedHotkey2.isModifierKey && selectedHotkey2 != .none) else { return }

        globalEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            guard let self = self else { return }
            // Performance optimization: Skip processing if monitoring is disabled or event is too recent
            guard self.isMonitoringEnabled else { return }
            let now = Date()
            guard now.timeIntervalSince(self.lastEventTime) >= self.eventDebounceInterval else { return }
            self.lastEventTime = now
            
            Task { @MainActor in
                await self.handleModifierKeyEvent(event)
            }
        }
        
        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            guard let self = self else { return event }
            // Performance optimization: Skip processing if monitoring is disabled or event is too recent
            guard self.isMonitoringEnabled else { return event }
            let now = Date()
            guard now.timeIntervalSince(self.lastEventTime) >= self.eventDebounceInterval else { return event }
            self.lastEventTime = now
            
            Task { @MainActor in
                await self.handleModifierKeyEvent(event)
            }
            return event
        }
    }
    
    private func setupCustomShortcutMonitoring() {
        // Hotkey 1
        if selectedHotkey1 == .custom {
            KeyboardShortcuts.onKeyDown(for: .toggleMiniRecorder) { [weak self] in
                Task { @MainActor in await self?.handleCustomShortcutKeyDown() }
            }
            KeyboardShortcuts.onKeyUp(for: .toggleMiniRecorder) { [weak self] in
                Task { @MainActor in await self?.handleCustomShortcutKeyUp() }
            }
        }
        // Hotkey 2
        if selectedHotkey2 == .custom {
            KeyboardShortcuts.onKeyDown(for: .toggleMiniRecorder2) { [weak self] in
                Task { @MainActor in await self?.handleCustomShortcutKeyDown() }
            }
            KeyboardShortcuts.onKeyUp(for: .toggleMiniRecorder2) { [weak self] in
                Task { @MainActor in await self?.handleCustomShortcutKeyUp() }
            }
        }
    }
    
    private func removeAllMonitoring() {
        if let monitor = globalEventMonitor {
            NSEvent.removeMonitor(monitor)
            globalEventMonitor = nil
        }
        
        if let monitor = localEventMonitor {
            NSEvent.removeMonitor(monitor)
            localEventMonitor = nil
        }
        
        resetKeyStates()
    }
    
    private func resetKeyStates() {
        currentKeyState = false
        keyPressStartTime = nil
        isHandsFreeMode = false
        shortcutCurrentKeyState = false
        shortcutKeyPressStartTime = nil
        isShortcutHandsFreeMode = false
    }
    
    private func handleModifierKeyEvent(_ event: NSEvent) async {
        let keycode = event.keyCode
        let flags = event.modifierFlags
        
        // Determine which hotkey (if any) is being triggered
        let activeHotkey: HotkeyOption?
        if selectedHotkey1.isModifierKey && selectedHotkey1.keyCode == keycode {
            activeHotkey = selectedHotkey1
        } else if selectedHotkey2.isModifierKey && selectedHotkey2.keyCode == keycode {
            activeHotkey = selectedHotkey2
        } else {
            activeHotkey = nil
        }
        
        guard let hotkey = activeHotkey else { return }
        
        var isKeyPressed = false
        
        switch hotkey {
        case .rightOption, .leftOption:
            isKeyPressed = flags.contains(.option)
        case .leftControl, .rightControl:
            isKeyPressed = flags.contains(.control)
        case .fn:
            isKeyPressed = flags.contains(.function)
            // Debounce Fn key
            pendingFnKeyState = isKeyPressed
            fnDebounceTask?.cancel()
            fnDebounceTask = Task { [pendingState = isKeyPressed] in
                try? await Task.sleep(nanoseconds: 75_000_000) // 75ms
                if pendingFnKeyState == pendingState {
                    await MainActor.run {
                        self.processKeyPress(isKeyPressed: pendingState)
                    }
                }
            }
            return
        case .rightCommand:
            isKeyPressed = flags.contains(.command)
        case .rightShift:
            isKeyPressed = flags.contains(.shift)
        case .custom, .none:
            return // Should not reach here
        }
        
        processKeyPress(isKeyPressed: isKeyPressed)
    }
    
    private func processKeyPress(isKeyPressed: Bool) {
        guard isKeyPressed != currentKeyState else { return }
        currentKeyState = isKeyPressed
        
        if isKeyPressed {
            keyPressStartTime = Date()
            
            if isHandsFreeMode {
                isHandsFreeMode = false
                Task { @MainActor in
                    guard canProcessHotkeyAction else { return }
                    await whisperState.handleToggleMiniRecorder()
                }
                return
            }
            
            if !whisperState.isMiniRecorderVisible {
                Task { @MainActor in
                    guard canProcessHotkeyAction else { return }
                    await whisperState.handleToggleMiniRecorder()
                }
            }
        } else {
            let now = Date()
            
            if let startTime = keyPressStartTime {
                let pressDuration = now.timeIntervalSince(startTime)
                
                if pressDuration < briefPressThreshold {
                    isHandsFreeMode = true
                } else {
                    Task { @MainActor in
                        guard canProcessHotkeyAction else { return }
                        await whisperState.handleToggleMiniRecorder()
                    }
                }
            }
            
            keyPressStartTime = nil
        }
    }
    
    private func handleCustomShortcutKeyDown() async {
        if let lastTrigger = lastShortcutTriggerTime,
           Date().timeIntervalSince(lastTrigger) < shortcutCooldownInterval {
            return
        }
        
        guard !shortcutCurrentKeyState else { return }
        shortcutCurrentKeyState = true
        lastShortcutTriggerTime = Date()
        shortcutKeyPressStartTime = Date()
        
        if isShortcutHandsFreeMode {
            isShortcutHandsFreeMode = false
            guard canProcessHotkeyAction else { return }
            await whisperState.handleToggleMiniRecorder()
            return
        }
        
        if !whisperState.isMiniRecorderVisible {
            guard canProcessHotkeyAction else { return }
            await whisperState.handleToggleMiniRecorder()
        }
    }
    
    private func handleCustomShortcutKeyUp() async {
        guard shortcutCurrentKeyState else { return }
        shortcutCurrentKeyState = false
        
        let now = Date()
        
        if let startTime = shortcutKeyPressStartTime {
            let pressDuration = now.timeIntervalSince(startTime)
            
            if pressDuration < briefPressThreshold {
                isShortcutHandsFreeMode = true
            } else {
                guard canProcessHotkeyAction else { return }
                await whisperState.handleToggleMiniRecorder()
            }
        }
        
        shortcutKeyPressStartTime = nil
    }
    
    // Computed property for backward compatibility with UI
    var isShortcutConfigured: Bool {
        let isHotkey1Configured = (selectedHotkey1 == .custom) ? (KeyboardShortcuts.getShortcut(for: .toggleMiniRecorder) != nil) : true
        let isHotkey2Configured = (selectedHotkey2 == .custom) ? (KeyboardShortcuts.getShortcut(for: .toggleMiniRecorder2) != nil) : true
        return isHotkey1Configured && isHotkey2Configured
    }
    
    func updateShortcutStatus() {
        // Called when a custom shortcut changes
        if selectedHotkey1 == .custom || selectedHotkey2 == .custom {
            setupHotkeyMonitoring()
        }
    }
    
    // MARK: - Power Mode Hotkey Management
    private func setupPowerModeHotkeys() {
        NSLog("🔧 HotkeyManager: Setting up Power Mode hotkeys...")
        
        // Set up observer for hotkey changes
        powerModeHotkeyObserver = NotificationCenter.default.addObserver(
            forName: .powerModeHotkeyChanged,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let userInfo = notification.userInfo,
                  let configId = userInfo["configId"] as? UUID,
                  let enabled = userInfo["enabled"] as? Bool else { 
                NSLog("❌ HotkeyManager: Invalid notification data")
                return 
            }
            
            NSLog("📢 HotkeyManager: Received hotkey change notification - configId: \(configId), enabled: \(enabled)")
            
            Task { @MainActor in
                if enabled {
                    self.registerPowerModeHotkey(for: configId)
                } else {
                    self.unregisterPowerModeHotkey(for: configId)
                }
            }
        }
        
        // Register existing hotkeys
        let configs = PowerModeManager.shared.configurations
        NSLog("🔧 HotkeyManager: Found \(configs.count) Power Mode configurations")
        
        let hotkeyConfigs = configs.filter { $0.hasHotkey }
        NSLog("🔧 HotkeyManager: \(hotkeyConfigs.count) configurations have hotkeys enabled")
        
        for config in hotkeyConfigs {
            NSLog("🔧 HotkeyManager: Registering hotkey for '\(config.name)' (\(config.id))")
            registerPowerModeHotkey(for: config.id)
        }
    }
    
    private func registerPowerModeHotkey(for configId: UUID) {
        let shortcutName = KeyboardShortcuts.Name.powerMode(configId)
        
        NSLog("🔥 Registering Power Mode hotkey for config: \(configId)")
        
        KeyboardShortcuts.onKeyUp(for: shortcutName) { [weak self] in
            NSLog("🚀 Power Mode hotkey triggered for config: \(configId)")
            guard let self = self else { return }
            Task { @MainActor in
                guard self.canProcessHotkeyAction else { 
                    NSLog("❌ Cannot process hotkey action - app is busy")
                    return 
                }
                NSLog("✅ Activating Power Mode: \(configId)")
                
                // First activate the Power Mode configuration
                await PowerModeManager.shared.activatePowerMode(with: configId)
                
                // Then trigger recording (same as main transcription hotkey)
                NSLog("🎙️ Starting recording with Power Mode configuration")
                await self.whisperState.handleToggleMiniRecorder()
            }
        }
    }
    
    private func unregisterPowerModeHotkey(for configId: UUID) {
        let shortcutName = KeyboardShortcuts.Name.powerMode(configId)
        KeyboardShortcuts.setShortcut(nil, for: shortcutName)
    }
    
    /// Set up app state monitoring to optimize event processing
    private func setupAppStateMonitoring() {
        // Monitor app activation state to reduce CPU usage when app is in background
        appActiveObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.isMonitoringEnabled = true
            NSLog("🔧 HotkeyManager: App became active - enabling event monitoring")
        }
        
        // Reduce monitoring when app goes to background (but don't disable completely for global hotkeys)
        NotificationCenter.default.addObserver(
            forName: NSApplication.didResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            // Keep monitoring enabled for global hotkeys, but the debouncing will reduce CPU usage
            NSLog("🔧 HotkeyManager: App resigned active - monitoring remains enabled for global hotkeys")
        }
    }
    
    /// Enable or disable monitoring (useful for power management)
    func setMonitoringEnabled(_ enabled: Bool) {
        isMonitoringEnabled = enabled
        NSLog("🔧 HotkeyManager: Monitoring \(enabled ? "enabled" : "disabled")")
    }
    
    deinit {
        if let observer = powerModeHotkeyObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        if let observer = appActiveObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        // Remove all notification observers
        NotificationCenter.default.removeObserver(self)
        
        Task { @MainActor in
            removeAllMonitoring()
        }
    }
}


