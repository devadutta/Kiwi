# 🥝 Kiwi

Kiwi is a fork of [VoiceInk](https://github.com/Beingpax/VoiceInk) with a ton of opinionated changes.

<div align="center">

**AI-Powered Voice Transcription for macOS**

A powerful, privacy-focused voice transcription app with advanced AI enhancement capabilities, context-aware automation, and flexible hotkey controls.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![macOS](https://img.shields.io/badge/macOS-11.0+-blue.svg)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org/)

[Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [Configuration](#%EF%B8%8F-configuration) • [Development](#-development) • [License](#-license)

</div>

---

## ✨ Features

### 🎤 Multi-Engine Transcription
Kiwi supports multiple transcription engines to fit your needs:

- **Local Models** (Whisper.cpp)
  - Tiny, Base, Small, Medium, Large variants
  - English-only and multilingual models
  - Complete offline privacy
  
- **Parakeet V3** (NVIDIA)
  - Lightning-fast transcription
  - Multi-lingual support (English + European languages)
  - Optimized for speed and accuracy

- **Apple Speech Framework** (macOS 26+)
  - Native macOS integration
  - Supports 20+ languages and dialects
  - System-level optimization

- **Cloud Services**
  - Groq (ultra-fast cloud transcription)
  - Deepgram (real-time streaming)
  - ElevenLabs (high-quality multilingual)
  - Mistral AI
  - Google Gemini
  - Custom OpenAI-compatible endpoints

### 🧠 AI Enhancement
Transform your transcriptions with powerful AI post-processing:

- **Multiple AI Providers**
  - OpenAI (GPT-4, GPT-3.5)
  - Anthropic (Claude)
  - Ollama (local AI models)
  - Google Gemini
  - Groq
  - OpenRouter
  - Custom endpoints

- **Smart Context Awareness**
  - Screen capture context (OCR from active window)
  - Clipboard context integration
  - Custom prompts and templates

- **Built-in Prompt Library**
  - Grammar and formatting correction
  - Summarization
  - Email drafting
  - Meeting notes
  - Custom user-defined prompts

### ⚡ Power Mode
Automate your workflow with context-aware configurations:

- **App-Based Automation**: Automatically switch settings based on the active application
- **URL-Based Automation**: Trigger specific configurations for websites (e.g., different modes for Notion vs Gmail)
- **Per-Mode Settings**:
  - Custom transcription models
  - Specific AI prompts
  - Language preferences
  - Enhancement settings
  - Auto-send to clipboard/paste

### ⌨️ Flexible Hotkey System
Control Kiwi your way with multiple input methods:

- **Modifier Keys**: Right/Left Option, Control, Command, Shift, Fn
- **Custom Keyboard Shortcuts**: Define your own key combinations
- **Dual Hotkey Support**: Set up two independent hotkeys
- **Two Recording Modes**:
  - **Push-to-Talk**: Press and hold to record, release to stop
  - **Hands-Free**: Quick tap to start, tap again to stop
- **App Shortcuts Integration**: Siri Shortcuts support

### 📊 Comprehensive Metrics
Track your productivity and usage:

- Total transcriptions and duration
- Words per minute stats
- Audio processing time
- AI enhancement analytics
- Model usage distribution
- Cost tracking for cloud services

### 🎯 Additional Features
- **Audio File Transcription**: Drag and drop audio files for batch processing
- **Dictionary System**: Custom word replacements and corrections
- **Transcription History**: Searchable history with audio playback
- **Export/Import**: CSV export and configuration backup
- **Mini Recorder Window**: Compact floating recorder interface
- **Menu Bar Integration**: Quick access from the menu bar
- **Launch at Login**: Optional startup automation
- **Auto-paste**: Automatically paste transcriptions to active app
- **Zero Data Retention**: Optional automatic cleanup of audio and transcriptions

---

## 📋 Requirements

- macOS 11.0 or later
- Xcode 15.0+ (for building from source)
- At least 4GB RAM (8GB+ recommended for larger models)
- Microphone access permission
- Screen recording permission (for screen context feature)
- Accessibility permission (for auto-paste feature)

---

## 🚀 Installation

### From Source

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/Kiwi.git
   cd Kiwi
   ```

2. **Open in Xcode**
   ```bash
   open Kiwi.xcodeproj
   ```

3. **Install dependencies**
   
   Dependencies are managed via Swift Package Manager and will be automatically resolved by Xcode:
   - [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) - Global keyboard shortcuts
   - [LaunchAtLogin-Modern](https://github.com/sindresorhus/LaunchAtLogin-Modern) - Launch at login support
   - [MediaRemote-Adapter](https://github.com/ejbills/mediaremote-adapter) - Media playback control
   - [Zip](https://github.com/marmelroy/Zip) - Archive handling
   - [FluidAudio](https://github.com/FluidInference/FluidAudio) - Audio processing for Parakeet

4. **Build and run**
   ```bash
   # Command line build
   ./build.sh
   
   # Or use Xcode: Product > Build (⌘B)
   ```

### Build Script

The included `build.sh` script builds a Release version:
```bash
chmod +x build.sh
./build.sh
```

---

## 💡 Usage

### First Launch

1. **Onboarding**: On first launch, Kiwi will guide you through:
   - Setting up your preferred hotkey
   - Choosing a transcription model
   - Granting necessary permissions (Microphone, Accessibility, Screen Recording)

2. **Download Models**: If using local Whisper models, download your preferred model size from the AI Models tab

### Basic Transcription

1. **Start Recording**:
   - **Push-to-Talk**: Press and hold your configured hotkey
   - **Hands-Free**: Quick tap your hotkey to start, tap again to stop
   
2. **Speak**: The mini recorder window shows audio levels and recording status

3. **Stop Recording**: Release the key (push-to-talk) or tap again (hands-free)

4. **Get Results**: 
   - Transcription appears in the mini recorder
   - Automatically copied to clipboard
   - Optionally auto-pasted to active application

### AI Enhancement

1. Navigate to **Enhancement** settings
2. Configure your AI provider (API key required for cloud services)
3. Enable "AI Enhancement"
4. Select a prompt or create custom ones
5. Your transcriptions will be automatically enhanced

### Power Mode

1. Navigate to **Power Mode**
2. Create a new configuration
3. Select target apps or URLs
4. Configure settings (model, prompt, language, etc.)
5. Enable the configuration

Power Mode will automatically activate when you switch to the configured app or website.

### Audio File Transcription

1. Navigate to **Transcribe Audio**
2. Drag and drop audio files or click to select
3. Choose your transcription model
4. Optionally enable AI enhancement
5. View results and manage transcription history

---

## ⚙️ Configuration

### Settings Overview

#### Audio Input
- Select input device (microphone)
- Adjust audio settings
- Configure automatic device switching

#### AI Models
- Download and manage local Whisper models
- Configure cloud service API keys
- Add custom transcription endpoints
- Model performance comparison

#### Enhancement
- Configure AI providers (OpenAI, Anthropic, Ollama, etc.)
- Manage custom prompts
- Enable screen/clipboard context
- Set up automatic text formatting

#### Power Mode
- Create app/URL-based configurations
- Set hotkeys for quick mode switching
- Configure default modes
- Enable/disable specific configurations

#### Dictionary
- Add custom word replacements
- Import/export dictionary entries
- Enable/disable dictionary processing

#### Settings
- Configure hotkeys and shortcuts
- Set default behaviors
- Enable launch at login
- Configure auto-paste
- Privacy settings (auto-cleanup)
- Menu bar preferences

---

## 🛠️ Development

### Project Structure

```
Kiwi/
├── Kiwi/
│   ├── AppDelegate.swift          # App lifecycle
│   ├── Kiwi.swift                 # Main app entry
│   ├── AppConfiguration.swift     # App configuration
│   ├── Recorder.swift             # Audio recording
│   ├── HotkeyManager.swift        # Hotkey handling
│   ├── MenuBarManager.swift       # Menu bar integration
│   │
│   ├── Models/                    # Data models
│   │   ├── TranscriptionModel.swift
│   │   ├── PredefinedModels.swift
│   │   └── CustomPrompt.swift
│   │
│   ├── Services/                  # Business logic
│   │   ├── TranscriptionService.swift
│   │   ├── LocalTranscriptionService.swift
│   │   ├── NativeAppleTranscriptionService.swift
│   │   ├── ParakeetTranscriptionService.swift
│   │   ├── AIEnhancementService.swift
│   │   ├── AudioDeviceManager.swift
│   │   └── CloudTranscription/
│   │
│   ├── Views/                     # UI components
│   │   ├── ContentView.swift
│   │   ├── Recorder/
│   │   ├── Settings/
│   │   ├── Metrics/
│   │   └── Onboarding/
│   │
│   ├── PowerMode/                 # Power Mode feature
│   │   ├── PowerModeView.swift
│   │   ├── PowerModeConfig.swift
│   │   ├── PowerModeSessionManager.swift
│   │   └── ActiveWindowService.swift
│   │
│   ├── Whisper/                   # Whisper.cpp integration
│   │   └── [Whisper implementation files]
│   │
│   ├── AppIntents/                # Siri Shortcuts
│   │   └── AppShortcuts.swift
│   │
│   └── Resources/                 # Assets and resources
│       ├── models/                # Bundled models
│       ├── Sounds/                # Sound effects
│       └── *.scpt                 # Browser URL scripts
│
├── Kiwi.xcodeproj/               # Xcode project
├── KiwiTests/                    # Unit tests
├── KiwiUITests/                  # UI tests
└── build.sh                      # Build script
```

### Key Technologies

- **SwiftUI**: Modern declarative UI framework
- **SwiftData**: Data persistence and management
- **Whisper.cpp**: Local speech recognition
- **AVFoundation**: Audio recording and playback
- **AppKit**: Native macOS integration
- **Combine**: Reactive programming
- **Async/Await**: Modern concurrency

### Adding a New Transcription Provider

1. Create a new service conforming to `TranscriptionService` protocol
2. Add the provider to `ModelProvider` enum in `TranscriptionModel.swift`
3. Implement the service in `Services/CloudTranscription/` (or appropriate location)
4. Add model definitions to `PredefinedModels.swift`
5. Update UI to display the new provider option

### Adding a New AI Enhancement Provider

1. Add provider to `AIProvider` enum in `AIService.swift`
2. Implement API integration in `AIEnhancementService.swift`
3. Add configuration UI in `EnhancementSettingsView.swift`
4. Update model selection logic

---

## 🔐 Privacy & Security

Kiwi takes privacy seriously:

- **Local-First**: All local transcription happens on-device
- **Optional Cloud**: Cloud services are opt-in only
- **API Key Security**: Keys stored securely in macOS Keychain
- **Zero Data Retention**: Optional auto-cleanup of audio files and transcriptions
- **No Analytics**: No usage data collection or telemetry
- **Open Source**: Full transparency with GPL v3 license

### Permissions Required

- **Microphone**: Required for audio recording
- **Accessibility**: Required for auto-paste and keyboard monitoring features
- **Screen Recording**: Optional, for screen context in AI enhancement

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Commit your changes** (`git commit -m 'Add some amazing feature'`)
4. **Push to the branch** (`git push origin feature/amazing-feature`)
5. **Open a Pull Request**

### Guidelines

- Follow Swift style guidelines
- Add tests for new features
- Update documentation as needed
- Ensure all tests pass before submitting

---

## 🐛 Known Issues & Limitations

- Native Apple Speech Framework requires macOS 26 (Tahoe) or later
- Some cloud providers may have rate limits
- Large Whisper models require significant RAM (4GB+ for Large v3)
- Screen capture context requires Screen Recording permission

---

## 📝 Changelog

See the git commit history for detailed changes.

---

## 📧 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/Kiwi/issues)
- **Email**: support@devadutta.com
- **Videos**: [YouTube Channel](https://www.youtube.com/@tryKiwi/videos)

---

## 📜 License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

### What this means:
- ✅ Free to use, modify, and distribute
- ✅ Can be used commercially
- ⚠️ Must disclose source code
- ⚠️ Must include original license
- ⚠️ Derivative works must use GPL v3

---

## 🙏 Acknowledgments

- [Whisper.cpp](https://github.com/ggerganov/whisper.cpp) - OpenAI's Whisper implementation in C++
- [NVIDIA Parakeet](https://github.com/NVIDIA/NeMo) - Fast ASR model
- [Sindre Sorhus](https://github.com/sindresorhus) - KeyboardShortcuts and LaunchAtLogin libraries
- All contributors and users of Kiwi

---

## 🗺️ Roadmap

- [ ] Real-time streaming transcription
- [ ] Speaker diarization
- [ ] Multi-language auto-detection
- [ ] Custom model training support
- [ ] iOS/iPadOS companion app
- [ ] Cloud sync for configurations
- [ ] Pronunciation dictionary
- [ ] Advanced audio preprocessing

---

<div align="center">

**Made with ❤️ for the macOS community**

If you find Kiwi useful, consider starring ⭐ the repository!

</div>
