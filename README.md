<p align="center">
  <img src="LinkStow/Assets.xcassets/LinkStow_BigIcon.imageset/LinkStow-big-logo.jpeg" alt="LinkStow" width="640">
</p>

# LinkStow

A link management app for iOS. Save, organize, and retrieve URLs with rich metadata, visual customization, and biometric-protected hidden links.

## Features

- **Smart link saving** — Paste a URL to auto-fetch the page title, description, and favicon
- **Groups** — Organize links into custom groups with icons and colors
- **Search** — Filter links by name or group
- **Hidden links** — Protect sensitive links behind Face ID / Touch ID
- **Reminders** — Set date-based reminders on any link
- **QR codes** — Generate a QR code for any saved link
- **Custom symbols** — Override the default favicon with an SF Symbol or emoji
- **Appearance settings** — Control title and caption line limits

## Requirements

- Xcode 16+
- iOS 18+ / macOS 15+
- Swift 6

## Getting Started

1. Clone the repository
2. Open `LinkStow.xcodeproj` in Xcode
3. Select a simulator or device target
4. Build and run (`⌘R`)

No additional setup, API keys, or third-party accounts required. The app uses SwiftData for local-only persistence.

## Project Structure

```
LinkStow/
├── App/
│   ├── LinkStowApp.swift          # Entry point
│   ├── RootView.swift
│   └── ModelContainerProvider.swift
├── Models/
│   ├── Link.swift                 # LinkModel (SwiftData)
│   ├── Group.swift                # GroupModel (SwiftData)
│   ├── Symbol.swift               # SymbolModel + SymbolType enum
│   └── UserDefaults.swift         # AppStorage preference keys
├── Controllers/
│   └── MainController.swift       # CRUD operations, URL verification
├── ViewModels/
│   └── LinkEditorViewModel.swift  # Link editor form state
├── Services/
│   ├── LinkMetadataService.swift  # Title, description, favicon fetching
│   ├── QRCodeGenerator.swift
│   └── Authentication.swift       # LocalAuthentication wrapper
└── View/
    ├── MainView.swift             # Primary UI (home screen)
    ├── LinkEditorView.swift       # Create / edit link sheet
    ├── GroupEditorView.swift      # Create / edit group sheet
    ├── PreferencesView.swift      # App settings
    └── QRCodeView.swift
```

## Architecture

The app follows an **MVVM + Controller** pattern:

| Layer | Responsibility |
|---|---|
| `MainController` | CRUD operations, URL scheme validation, metadata coordination |
| `LinkEditorViewModel` | Form state for creating/editing links |
| `LinkMetadataService` | HTTP requests for page title, description, and favicon |
| Views | Presentation and user interaction |

Data is persisted with **SwiftData**. Models use `@Model` and relationships are managed automatically — links and groups have a many-to-many relationship; deleting a group nullifies the group reference on its links rather than deleting them.

## Data Models

**`LinkModel`** — A saved URL with metadata and settings
- `url`, `title`, `caption` — Core link data
- `symbol: SymbolModel` — Visual icon (favicon, SF Symbol, or emoji)
- `groups: [GroupModel]` — Group assignments
- `isHidden: Bool` — Biometric-protected visibility
- `reminderEnabled`, `reminderDate`, `reminderAllDay` — Optional reminder

**`GroupModel`** — A named collection of links
- `name`, `symbol` — Display info
- `links: [LinkModel]` — Inverse relationship maintained by SwiftData

**`SymbolModel`** — Shared visual representation for links and groups
- Stores a favicon (`Data?`), SF Symbol name, or emoji
- Color stored as RGBA components for SwiftData compatibility

## Running Tests

```bash
xcodebuild test \
  -project LinkStow.xcodeproj \
  -scheme LinkStow \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

Or run from Xcode with `⌘U`. Tests use an in-memory `ModelContainer` so they don't affect persisted data.

**Test targets:**
- `LinkStowTests` — Unit tests for models, controllers, services, and view models
- `LinkStowUITests` — UI automation tests
