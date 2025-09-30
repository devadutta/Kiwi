//
//  AppConfiguration.swift
//  Kiwi
//
//  Created by Assistant on $(date)
//

import Foundation

/// Centralized configuration for the Kiwi application
/// This serves as the equivalent of a .env file for Swift applications
struct AppConfiguration {
    
    // MARK: - App Identity
    
    /// Application display name
    static let appName = "Kiwi"
    
    /// Application internal name (for technical references)
    static let appInternalName = "Kiwi"
    
    // MARK: - Bundle Identifiers
    
    /// Main application bundle identifier
    static let bundleIdentifier = "com.devadutta.Kiwi"
    
    /// Bundle identifier for logging subsystem (lowercase convention)
    static let loggingSubsystem = "com.devadutta.Kiwi"
    
    /// Transient pasteboard type identifier
    static let transientPasteboardType = "com.devadutta.Kiwi.transient"
    
    // MARK: - Directory Names
    
    /// Application support directory name
    static let appSupportDirectoryName = "com.devadutta.Kiwi"
    
    /// User-facing application support directory name
    static let userFacingDirectoryName = "Kiwi"
    
    // MARK: - Contact Information
    
    /// Support email address
    static let supportEmail = "support@devadutta.com" // Update this with your actual support email
    
    // MARK: - Computed Properties
    
    /// Returns the current bundle identifier from the main bundle
    /// Falls back to the configured identifier if not available
    static var currentBundleIdentifier: String {
        return Bundle.main.bundleIdentifier ?? bundleIdentifier
    }
    
    /// Returns the application support directory URL
    static var applicationSupportDirectory: URL? {
        return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(appSupportDirectoryName, isDirectory: true)
    }
}
