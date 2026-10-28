# Diagram → README → code traces

All ten saved Plus+C diagrams link to exact README rows and relevant prose sections. Those README anchors link directly to implementation artifacts. The README also has feature-, architecture-, model-, setup- and test-section anchors.

## Navigation

Open this repository in Plus+C and use the Home trace links to open a diagram and README.md together. A README trace highlights the relevant row or section. Follow its source links to code. The Markdown links below provide the same file/line navigation outside Plus+C.

## Native semantics

- A diagram **represents** a README row or section: the prose explains its current behavior.
- A README anchor **represents** source evidence: the code/configuration implements or supports what the prose describes. These links do not represent runtime calls.
- A README section **refines** the complete README artifact, identifying its position within that document.
- The complete README **represents** the LinkStow system.
- Target build settings **implement** the documented deployment/platform/language prerequisites; the local verification script **implements** the README trace-integrity command.

Documentation anchors carry a whole-README SHA-256 and exact line ranges. Editing README.md requires reviewing/re-registering its anchors and refreshing the [machine-readable index](readme-traces.json). Every target source artifact retains its own path, range and hash. These links do not claim passing tests, stakeholder approval, or operation of dormant features.

## Complete diagram bridges

| Diagram | README row | Direct implementation evidence |
| --- | --- | --- |
| [01 Stakeholder needs](<../diagrams/01 Stakeholder needs.plc>) | [README line 121](../README.md#L121) | [MainView](../LinkStow/View/MainView.swift#L43), [LinkModel](../LinkStow/Models/Link.swift#L13) |
| [02 System requirements](<../diagrams/02 System requirements.plc>) | [README line 122](../README.md#L122) | [MainController](../LinkStow/Controllers/MainController.swift#L7), [LinkEditorViewModel](../LinkStow/ViewModels/LinkEditorViewModel.swift#L5), [MainView](../LinkStow/View/MainView.swift#L43), [LinkModel](../LinkStow/Models/Link.swift#L13) |
| [03 System context](<../diagrams/03 System context.plc>) | [README line 123](../README.md#L123) | [AppModelContainer](../LinkStow/App/ModelContainerProvider.swift#L3), [LinkMetadataService](../LinkStow/Services/LinkMetadataService.swift#L5), [authenticateUser](../LinkStow/Services/Authentication.swift#L6) |
| [04 Component architecture](<../diagrams/04 Component architecture.plc>) | [README line 124](../README.md#L124) | [RootView](../LinkStow/App/RootView.swift#L5), [MainController](../LinkStow/Controllers/MainController.swift#L7), [LinkEditorViewModel](../LinkStow/ViewModels/LinkEditorViewModel.swift#L5) |
| [05 Subsystems to code](<../diagrams/05 Subsystems to code.plc>) | [README line 125](../README.md#L125) | [LinkStowApp](../LinkStow/App/LinkStowApp.swift#L5), [MainView](../LinkStow/View/MainView.swift#L43), [LinkEditorView](../LinkStow/View/LinkEditorView.swift#L10) |
| [06 Save-link flow](<../diagrams/06 Save-link flow.plc>) | [README line 126](../README.md#L126) | [LinkMetadataService.verifyLink](../LinkStow/Services/LinkMetadataService.swift#L19), [LinkEditorViewModel.save](../LinkStow/ViewModels/LinkEditorViewModel.swift#L77), [MainController.addLink](../LinkStow/Controllers/MainController.swift#L38) |
| [07 Data model](<../diagrams/07 Data model.plc>) | [README line 127](../README.md#L127) | [LinkModel](../LinkStow/Models/Link.swift#L13), [GroupModel](../LinkStow/Models/Group.swift#L6), [SymbolModel](../LinkStow/Models/Symbol.swift#L62) |
| [08 Main state machine](<../diagrams/08 Main state machine.plc>) | [README line 128](../README.md#L128) | [MainView](../LinkStow/View/MainView.swift#L43), [LinkModel.checkLinkInGroup](../LinkStow/Models/Link.swift#L120) |
| [09 Hidden-link security](<../diagrams/09 Hidden-link security.plc>) | [README line 129](../README.md#L129) | [authenticateUser](../LinkStow/Services/Authentication.swift#L6), [LinkEditorViewModel](../LinkStow/ViewModels/LinkEditorViewModel.swift#L5), [MainView](../LinkStow/View/MainView.swift#L43) |
| [10 Code call paths](<../diagrams/10 Code call paths.plc>) | [README line 130](../README.md#L130) | [LinkEditorViewModel.save](../LinkStow/ViewModels/LinkEditorViewModel.swift#L77), [MainController.addLink](../LinkStow/Controllers/MainController.swift#L38), [MainController.updateLink](../LinkStow/Controllers/MainController.swift#L76), [LinkModel.updateLink](../LinkStow/Models/Link.swift#L61) |

## README section and feature anchors

| README anchor | Lines | Source evidence |
| --- | --- | --- |
| [Overview](../README.md#L5) | 5–8 | [LinkStowApp](../LinkStow/App/LinkStowApp.swift#L5), [MainView](../LinkStow/View/MainView.swift#L43), [LinkModel](../LinkStow/Models/Link.swift#L13) |
| [Feature: Smart link saving](../README.md#L11) | 11–11 | [MainView](../LinkStow/View/MainView.swift#L43), [MainController](../LinkStow/Controllers/MainController.swift#L7), [LinkMetadataService](../LinkStow/Services/LinkMetadataService.swift#L5) |
| [Feature: Groups](../README.md#L12) | 12–12 | [GroupEditorView](../LinkStow/View/GroupEditorView.swift#L22), [MainController](../LinkStow/Controllers/MainController.swift#L7), [LinkModel](../LinkStow/Models/Link.swift#L13), [GroupModel](../LinkStow/Models/Group.swift#L6) |
| [Feature: Library filtering](../README.md#L13) | 13–13 | [MainView](../LinkStow/View/MainView.swift#L43) |
| [Feature: Hidden links](../README.md#L14) | 14–14 | [MainView](../LinkStow/View/MainView.swift#L43), [PreferencesView](../LinkStow/View/PreferencesView.swift#L3), [LinkEditorViewModel](../LinkStow/ViewModels/LinkEditorViewModel.swift#L5), [authenticateUser](../LinkStow/Services/Authentication.swift#L6) |
| [Feature: Reminder fields](../README.md#L15) | 15–15 | [LinkModel](../LinkStow/Models/Link.swift#L13), [LinkEditorViewModel](../LinkStow/ViewModels/LinkEditorViewModel.swift#L5), [LinkEditorView](../LinkStow/View/LinkEditorView.swift#L10), [LinkStowApp](../LinkStow/App/LinkStowApp.swift#L5) |
| [Feature: QR codes](../README.md#L16) | 16–16 | [QRCodeView / ShareSheet](../LinkStow/View/QRCodeView.swift#L7), [QRCodeGenerator](../LinkStow/Services/QRCodeGenerator.swift#L4) |
| [Feature: Custom symbols](../README.md#L17) | 17–17 | [LinkEditorView](../LinkStow/View/LinkEditorView.swift#L10), [GroupEditorView](../LinkStow/View/GroupEditorView.swift#L22), [SymbolModel](../LinkStow/Models/Symbol.swift#L62) |
| [Feature: Appearance settings](../README.md#L18) | 18–18 | [PreferencesView](../LinkStow/View/PreferencesView.swift#L3), [MainView](../LinkStow/View/MainView.swift#L43) |
| [Requirements / build settings](../README.md#L20) | 20–25 | [LinkStow target build settings](../LinkStow.xcodeproj/project.pbxproj#L436) |
| [Getting started and local storage](../README.md#L26) | 26–34 | [LinkStowApp](../LinkStow/App/LinkStowApp.swift#L5), [AppModelContainer](../LinkStow/App/ModelContainerProvider.swift#L3) |
| [Project structure](../README.md#L35) | 35–63 | [LinkStowApp](../LinkStow/App/LinkStowApp.swift#L5), [RootView](../LinkStow/App/RootView.swift#L5), [AppModelContainer](../LinkStow/App/ModelContainerProvider.swift#L3), [MainView](../LinkStow/View/MainView.swift#L43), [MainController](../LinkStow/Controllers/MainController.swift#L7), [LinkEditorView](../LinkStow/View/LinkEditorView.swift#L10), [LinkEditorViewModel](../LinkStow/ViewModels/LinkEditorViewModel.swift#L5), [LinkMetadataService](../LinkStow/Services/LinkMetadataService.swift#L5), [GroupEditorView](../LinkStow/View/GroupEditorView.swift#L22), [LinkModel](../LinkStow/Models/Link.swift#L13), [GroupModel](../LinkStow/Models/Group.swift#L6), [SymbolModel](../LinkStow/Models/Symbol.swift#L62), [PreferencesView](../LinkStow/View/PreferencesView.swift#L3), [UserDefaults extension](../LinkStow/Models/UserDefaults.swift#L3), [authenticateUser](../LinkStow/Services/Authentication.swift#L6), [QRCodeGenerator](../LinkStow/Services/QRCodeGenerator.swift#L4), [QRCodeView / ShareSheet](../LinkStow/View/QRCodeView.swift#L7) |
| [Architecture](../README.md#L64) | 64–80 | [RootView](../LinkStow/App/RootView.swift#L5), [MainController](../LinkStow/Controllers/MainController.swift#L7), [LinkEditorViewModel](../LinkStow/ViewModels/LinkEditorViewModel.swift#L5), [LinkMetadataService](../LinkStow/Services/LinkMetadataService.swift#L5), [MainView](../LinkStow/View/MainView.swift#L43), [AppModelContainer](../LinkStow/App/ModelContainerProvider.swift#L3), [LinkModel](../LinkStow/Models/Link.swift#L13), [GroupModel](../LinkStow/Models/Group.swift#L6) |
| [Data models](../README.md#L81) | 81–97 | [LinkModel](../LinkStow/Models/Link.swift#L13), [GroupModel](../LinkStow/Models/Group.swift#L6), [SymbolModel](../LinkStow/Models/Symbol.swift#L62) |
| [Running tests and trace verification](../README.md#L98) | 98–114 | [MainControllerTests](../LinkStowTests/Controllers/MainControllerTests.swift#L6), [LinkTests](../LinkStowTests/Models/LinkTests.swift#L6), [GroupTests](../LinkStowTests/Models/GroupTests.swift#L6), [LinkGroupRelationshipTests](../LinkStowTests/Models/LinkGroupRelationshipTests.swift#L5), [SymbolTests](../LinkStowTests/Models/SymbolTests.swift#L6), [UserDefaultsTests](../LinkStowTests/Models/UserDefaultsTests.swift#L4), [QRCodeGeneratorTests](../LinkStowTests/Services/QRCodeGeneratorTests.swift#L6), [LinkEditorViewModelTests](../LinkStowTests/ViewModels/LinkEditorViewModelTests.swift#L6), [check_traceability.check](../scripts/check_traceability.py#L20) |

## Verification

Run `python3 scripts/check_traceability.py`. It verifies each stored README anchor against the current file, requires every saved diagram to reach README and app source through the expected native relationships, and checks the existing Swift/call-site trace coverage.

The native graph contains **25 README section/row anchors** and **154 added relationships** for this documentation bridge, including containment, prose, direct source evidence, and configuration/tool accountability. The README developer prerequisites were aligned with the target settings (iOS 26, iPhone, Swift 5 language mode) before recording the hash.
