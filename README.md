<p align="center">
  <img src="LinkStow/Assets.xcassets/LinkStow_BigIcon.imageset/LinkStow-big-logo.jpeg" alt="LinkStow" width="640">
</p>

# LinkStow

A link management app for iOS. Save, organize, and retrieve URLs with rich metadata, visual customization, and authentication-gated hidden-link views.

## Features

- **Smart link saving** — Paste a URL to auto-fetch the page title, description, and favicon
- **Groups** — Organize links into custom groups with icons and colors
- **Library filtering** — Select groups and sort by title; text filtering is currently dormant
- **Hidden links** — Gate selected UI transitions with device-owner authentication (biometrics or passcode)
- **Reminder fields** — Store reminder intent; the editor controls are dormant and notification scheduling is not implemented
- **QR codes** — Generate a QR code for any saved link
- **Custom symbols** — Override the default favicon with an SF Symbol or emoji
- **Appearance settings** — Control title and caption line limits

## Requirements

- Xcode 26+ with the iOS SDK
- iOS 26+ on iPhone or an iPhone simulator; no macOS target is configured
- The project currently uses Swift 5 language mode

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
│   └── UserDefaults.swift         # Typed preference helper (tests only; UI uses AppStorage)
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

The native Plus+C model decomposes stakeholder needs into requirements, the system boundary, logical subsystems, and source components. Open this repository folder in Plus+C to use `project.plc` and `diagrams/`. See [system diagrams and code traceability](docs/traceability.md) for the reading order, source mappings, known gaps, and verification instructions.

The [code connection index](docs/code-connections.md) adds 51 direct call-site-to-definition mappings. Plus+C's Home canvas can also show automatic file dependencies; the `10 Code call paths` sequence diagram details the save flow.

The app follows an **MVVM + Controller** pattern:

| Layer | Responsibility |
|---|---|
| [`MainController`](LinkStow/Controllers/MainController.swift#L7) | CRUD operations, URL scheme validation, metadata coordination |
| [`LinkEditorViewModel`](LinkStow/ViewModels/LinkEditorViewModel.swift#L5) | Form state for creating/editing links |
| [`LinkMetadataService`](LinkStow/Services/LinkMetadataService.swift#L5) | HTTP requests for page title, description, and favicon |
| [Views](LinkStow/View/MainView.swift#L43) | Presentation and user interaction |

Data is persisted with **SwiftData**. Models use `@Model` and relationships are managed automatically — links and groups have a many-to-many relationship; deleting a group nullifies the group reference on its links rather than deleting them.

## Data Models

**[`LinkModel`](LinkStow/Models/Link.swift#L13)** — A saved URL with metadata and settings
- `url`, `title`, `caption` — Core link data
- `symbol: SymbolModel` — Visual icon (favicon, SF Symbol, or emoji)
- `groups: [GroupModel]` — Group assignments
- `isHidden: Bool` — Hidden-list selection; authentication guards selected UI transitions
- `reminderEnabled`, `reminderDate`, `reminderAllDay` — Stored reminder intent; no notification scheduling

**[`GroupModel`](LinkStow/Models/Group.swift#L6)** — A named collection of links
- `name`, `symbol` — Display info
- `links: [LinkModel]` — Inverse relationship maintained by SwiftData

**[`SymbolModel`](LinkStow/Models/Symbol.swift#L62)** — Shared visual representation for links and groups
- Stores a favicon (`Data?`), SF Symbol name, or emoji
- Color stored as RGBA components for SwiftData compatibility

## Running Tests

```bash
xcodebuild test \
  -project LinkStow.xcodeproj \
  -scheme LinkStow \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

Or run from Xcode with `⌘U`. Model and controller tests use an in-memory `ModelContainer` so they don't affect persisted data.

**Test targets:**
- `LinkStowTests` — Unit tests for models, controllers, services, and view models
- `LinkStowUITests` — Project target exists; no UI test sources are currently checked in

For saved diagram and source-reference integrity, run `python3 scripts/check_traceability.py`.

## Diagram and code traceability

Plus+C stores section-level **diagram → README → source** links in `project.plc`. The README is explanatory documentation; its links do not claim test execution or stakeholder approval. The [README trace index](docs/readme-traces.md) lists exact anchors and native relationships.

| Diagram | README explanation | Implementation evidence |
| --- | --- | --- |
| [01 Stakeholder needs](<diagrams/01 Stakeholder needs.plc>) | [Overview](#linkstow) and [features](#features) describe the capabilities from which needs were inferred | [MainView](LinkStow/View/MainView.swift#L43), [LinkModel](LinkStow/Models/Link.swift#L13) |
| [02 System requirements](<diagrams/02 System requirements.plc>) | [Features](#features), [architecture](#architecture), and [data models](#data-models) summarize current behavior and limits | [MainController](LinkStow/Controllers/MainController.swift#L7), [LinkEditorViewModel](LinkStow/ViewModels/LinkEditorViewModel.swift#L5) |
| [03 System context](<diagrams/03 System context.plc>) | [Getting started](#getting-started) describes local storage and the account-free application boundary | [AppModelContainer](LinkStow/App/ModelContainerProvider.swift#L3), [LinkMetadataService](LinkStow/Services/LinkMetadataService.swift#L5), [authenticateUser](LinkStow/Services/Authentication.swift#L6) |
| [04 Component architecture](<diagrams/04 Component architecture.plc>) | [Architecture](#architecture) explains the MVVM/controller responsibilities | [RootView](LinkStow/App/RootView.swift#L5), [MainController](LinkStow/Controllers/MainController.swift#L7), [LinkEditorViewModel](LinkStow/ViewModels/LinkEditorViewModel.swift#L5) |
| [05 Subsystems to code](<diagrams/05 Subsystems to code.plc>) | [Project structure](#project-structure) maps responsibilities to files | [App entry](LinkStow/App/LinkStowApp.swift#L5), [MainView](LinkStow/View/MainView.swift#L43), [LinkEditorView](LinkStow/View/LinkEditorView.swift#L10) |
| [06 Save-link flow](<diagrams/06 Save-link flow.plc>) | [Smart link saving](#features) and [architecture](#architecture) explain capture and save coordination | [Metadata verification](LinkStow/Services/LinkMetadataService.swift#L19), [Editor save](LinkStow/ViewModels/LinkEditorViewModel.swift#L77), [Add link](LinkStow/Controllers/MainController.swift#L38) |
| [07 Data model](<diagrams/07 Data model.plc>) | [Data models](#data-models) and the relationship description explain persisted fields and inverse groups | [LinkModel](LinkStow/Models/Link.swift#L13), [GroupModel](LinkStow/Models/Group.swift#L6), [SymbolModel](LinkStow/Models/Symbol.swift#L62) |
| [08 Main state machine](<diagrams/08 Main state machine.plc>) | [Library filtering](#features) states that text filtering is dormant while group filtering and sorting work | [MainButtonState](LinkStow/View/MainView.swift#L28), [Filter selection](LinkStow/View/MainView.swift#L525), [Filtered records](LinkStow/View/MainView.swift#L757) |
| [09 Hidden-link security](<diagrams/09 Hidden-link security.plc>) | [Hidden links](#features) and [LinkModel](#data-models) describe UI authentication and visibility | [authenticateUser](LinkStow/Services/Authentication.swift#L6), [Hidden editor toggle](LinkStow/ViewModels/LinkEditorViewModel.swift#L144), [Hidden filter](LinkStow/View/MainView.swift#L490) |
| [10 Code call paths](<diagrams/10 Code call paths.plc>) | [Architecture](#architecture) identifies the editor → controller → model save path | [Editor Save action](LinkStow/View/LinkEditorView.swift#L60), [View-model save](LinkStow/ViewModels/LinkEditorViewModel.swift#L77), [Model update](LinkStow/Models/Link.swift#L61) |
