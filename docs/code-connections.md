# Code-to-code connections

Plus+C supports both automatic file dependency links and authored traces between exact source ranges. This project now records **51 inspected call-site-to-definition connections** in addition to its requirements-to-code traces. No application source was changed.

## Use the connections in Plus+C

1. Open the repository in Plus+C, then open **Home**. Enable **Show how the code files depend on one another** in the Home canvas controls if it is off. This draws the built-in source dependency overlay.
2. Click a code-file connection to open its endpoints. Authored traces use exact source ranges; the code view highlights the call site and its definition. The inspector/rationale identifies the caller and callee.
3. Open [10 Code call paths](<../diagrams/10 Code call paths.plc>) for a sequence of the new/existing-link save branches. Its messages trace to the same exact code ranges.

## What is supported

| Capability | Current Plus+C support |
| --- | --- |
| File-to-file dependencies | Built in. Swift type declarations/references are analyzed from source, alongside path imports in supported languages. |
| Part of one file to part of another | Supported through registered code artifacts carrying symbols, line ranges and source hashes, linked by native traces. Same-file connections work too. |
| Exact Swift function-call graph | The automatic file graph is a heuristic type-reference graph. It does not resolve Swift method dispatch, free functions, overloads, closures, build targets or runtime calls like a compiler/profiler. |
| Dedicated calls/depends-on MCP trace kind | Not exposed by the current MCP trace schema. These authored mappings use native represents with a CALLS rationale and relationship: calls in the local index. The sequence diagram uses ordinary call messages. |
| Automatic graph completeness | The built-in graph keeps the strongest eight outgoing dependencies per file and at most 600 edges, reporting dropped edges. It may include false positives across targets and omit free-function calls such as authenticateUser. |
| Drift | Registered whole-file hashes and native endpoint fingerprints detect evidence changes when re-registered. The local checker also verifies the saved source ranges, call expressions and direct code-to-code edges. |

These limitations were checked against the current local Plus+C implementation and live MCP schema. The authored links below were inspected against LinkStow source and cover key production flows; they are not an exhaustive static call graph or evidence of a successful runtime execution.

## Representative chains

- `MainView.searchButtonPressed → MainController.verifyLink → LinkMetadataService.verifyLink`
- `LinkEditorView Save action → LinkEditorViewModel.save → MainController.addLink/updateLink → LinkModel.updateLink → SymbolModel.updateSymbol`
- `MainView.filterHiddenView / PreferencesView / LinkEditorViewModel.toggleHidden → authenticateUser`
- `QRCodeView.qrImage → QRCodeGenerator.generateQRCode`
- `MainView / QRCodeView → ShareSheet`

## Source connection index

The call-site link opens the precise invoking statement; the definition link opens the target declaration. Type construction without an explicit initializer points to the containing type declaration.

| ID | Flow | Caller / call site | Callee / definition |
| --- | --- | --- | --- |
| CODE-001 | capture | [MainView.searchButtonPressed](../LinkStow/View/MainView.swift#L334) | [MainController.verifyLink](../LinkStow/Controllers/MainController.swift#L120) |
| CODE-002 | capture | [MainView.searchButtonPressed](../LinkStow/View/MainView.swift#L336) | [MainController.fetchWebsiteTitle](../LinkStow/Controllers/MainController.swift#L125) |
| CODE-003 | capture | [MainView.searchButtonPressed](../LinkStow/View/MainView.swift#L337) | [MainController.fetchWebsiteDescription](../LinkStow/Controllers/MainController.swift#L130) |
| CODE-004 | capture | [MainView.searchButtonPressed](../LinkStow/View/MainView.swift#L338) | [MainController.fetchWebsiteIcon](../LinkStow/Controllers/MainController.swift#L135) |
| CODE-005 | capture | [MainView.pasteButtonPressed](../LinkStow/View/MainView.swift#L299) | [MainController.verifyLink](../LinkStow/Controllers/MainController.swift#L120) |
| CODE-006 | capture | [MainView.pasteButtonPressed](../LinkStow/View/MainView.swift#L302) | [MainController.fetchWebsiteTitle](../LinkStow/Controllers/MainController.swift#L125) |
| CODE-007 | capture | [MainView.pasteButtonPressed](../LinkStow/View/MainView.swift#L303) | [MainController.fetchWebsiteDescription](../LinkStow/Controllers/MainController.swift#L130) |
| CODE-008 | capture | [MainView.pasteButtonPressed](../LinkStow/View/MainView.swift#L304) | [MainController.fetchWebsiteIcon](../LinkStow/Controllers/MainController.swift#L135) |
| CODE-009 | metadata | [MainController.verifyLink](../LinkStow/Controllers/MainController.swift#L121) | [LinkMetadataService.verifyLink](../LinkStow/Services/LinkMetadataService.swift#L19) |
| CODE-010 | metadata | [MainController.fetchWebsiteTitle](../LinkStow/Controllers/MainController.swift#L126) | [LinkMetadataService.fetchWebsiteTitle](../LinkStow/Services/LinkMetadataService.swift#L69) |
| CODE-011 | metadata | [MainController.fetchWebsiteDescription](../LinkStow/Controllers/MainController.swift#L131) | [LinkMetadataService.fetchWebsiteDescription](../LinkStow/Services/LinkMetadataService.swift#L94) |
| CODE-012 | metadata | [MainController.fetchWebsiteIcon](../LinkStow/Controllers/MainController.swift#L136) | [LinkMetadataService.fetchWebsiteIcon](../LinkStow/Services/LinkMetadataService.swift#L122) |
| CODE-013 | capture | [MainView.addButtonPressed](../LinkStow/View/MainView.swift#L322) | [MainController.createLink](../LinkStow/Controllers/MainController.swift#L21) |
| CODE-014 | capture | [MainController.createLink](../LinkStow/Controllers/MainController.swift#L27) | [LinkModel.init](../LinkStow/Models/Link.swift#L41) |
| CODE-015 | editor | [LinkEditorView.body](../LinkStow/View/LinkEditorView.swift#L60) | [LinkEditorViewModel.save](../LinkStow/ViewModels/LinkEditorViewModel.swift#L77) |
| CODE-016 | editor | [LinkEditorView.body](../LinkStow/View/LinkEditorView.swift#L67) | [LinkEditorViewModel.initialize](../LinkStow/ViewModels/LinkEditorViewModel.swift#L43) |
| CODE-017 | editor | [LinkEditorView.body](../LinkStow/View/LinkEditorView.swift#L52) | [LinkEditorViewModel.reset](../LinkStow/ViewModels/LinkEditorViewModel.swift#L114) |
| CODE-018 | persistence | [LinkEditorViewModel.save](../LinkStow/ViewModels/LinkEditorViewModel.swift#L79) | [MainController.addLink](../LinkStow/Controllers/MainController.swift#L38) |
| CODE-019 | persistence | [MainController.addLink](../LinkStow/Controllers/MainController.swift#L56) | [LinkModel.updateLink](../LinkStow/Models/Link.swift#L61) |
| CODE-020 | persistence | [LinkEditorViewModel.save](../LinkStow/ViewModels/LinkEditorViewModel.swift#L94) | [MainController.updateLink](../LinkStow/Controllers/MainController.swift#L76) |
| CODE-021 | persistence | [MainController.updateLink](../LinkStow/Controllers/MainController.swift#L94) | [LinkModel.updateLink](../LinkStow/Models/Link.swift#L61) |
| CODE-022 | editor | [LinkEditorViewModel.save](../LinkStow/ViewModels/LinkEditorViewModel.swift#L109) | [LinkEditorViewModel.reset](../LinkStow/ViewModels/LinkEditorViewModel.swift#L114) |
| CODE-023 | persistence | [LinkModel.updateLink](../LinkStow/Models/Link.swift#L82) | [SymbolModel.updateSymbol](../LinkStow/Models/Symbol.swift#L89) |
| CODE-024 | authentication | [LinkEditorViewModel.toggleHidden](../LinkStow/ViewModels/LinkEditorViewModel.swift#L150) | [authenticateUser](../LinkStow/Services/Authentication.swift#L6) |
| CODE-025 | authentication | [MainView.filterHiddenView](../LinkStow/View/MainView.swift#L498) | [authenticateUser](../LinkStow/Services/Authentication.swift#L6) |
| CODE-026 | authentication | [PreferencesView.hiddenGroupSection](../LinkStow/View/PreferencesView.swift#L116) | [authenticateUser](../LinkStow/Services/Authentication.swift#L6) |
| CODE-027 | persistence | [MainView.handleDeleteConfirmation](../LinkStow/View/MainView.swift#L817) | [MainController.deleteLink](../LinkStow/Controllers/MainController.swift#L114) |
| CODE-028 | groups | [GroupEditorView.body](../LinkStow/View/GroupEditorView.swift#L82) | [MainController.addGroup](../LinkStow/Controllers/MainController.swift#L165) |
| CODE-029 | groups | [MainController.addGroup](../LinkStow/Controllers/MainController.swift#L173) | [GroupModel.updateGroup](../LinkStow/Models/Group.swift#L37) |
| CODE-030 | groups | [GroupEditorView.body](../LinkStow/View/GroupEditorView.swift#L73) | [MainController.updateGroup](../LinkStow/Controllers/MainController.swift#L178) |
| CODE-031 | groups | [MainController.updateGroup](../LinkStow/Controllers/MainController.swift#L186) | [GroupModel.updateGroup](../LinkStow/Models/Group.swift#L37) |
| CODE-032 | groups | [GroupEditorView.handleDeleteConfirmation](../LinkStow/View/GroupEditorView.swift#L120) | [MainController.deleteGroup](../LinkStow/Controllers/MainController.swift#L197) |
| CODE-033 | groups | [GroupModel.updateGroup](../LinkStow/Models/Group.swift#L45) | [SymbolModel.init](../LinkStow/Models/Symbol.swift#L73) |
| CODE-034 | export | [QRCodeView.qrImage](../LinkStow/View/QRCodeView.swift#L14) | [QRCodeGenerator.generateQRCode](../LinkStow/Services/QRCodeGenerator.swift#L7) |
| CODE-035 | export | [QRCodeView.body](../LinkStow/View/QRCodeView.swift#L77) | [ShareSheet (type declaration)](../LinkStow/View/QRCodeView.swift#L90) |
| CODE-036 | library | [MainView.linkListArea](../LinkStow/View/MainView.swift#L660) | [MainController.openLink](../LinkStow/Controllers/MainController.swift#L140) |
| CODE-037 | library | [MainView.linkListArea](../LinkStow/View/MainView.swift#L720) | [LinkEditorView (type declaration)](../LinkStow/View/LinkEditorView.swift#L10) |
| CODE-038 | library | [MainView.linkListArea](../LinkStow/View/MainView.swift#L730) | [QRCodeView (type declaration)](../LinkStow/View/QRCodeView.swift#L7) |
| CODE-039 | library | [MainView.linkListArea](../LinkStow/View/MainView.swift#L734) | [ShareSheet (type declaration)](../LinkStow/View/QRCodeView.swift#L90) |
| CODE-040 | library | [MainView.linkListArea](../LinkStow/View/MainView.swift#L663) | [LinkModel.viewSymbol](../LinkStow/Models/Link.swift#L137) |
| CODE-041 | library | [MainView.filteredLinks](../LinkStow/View/MainView.swift#L761) | [LinkModel.checkLinkInGroup](../LinkStow/Models/Link.swift#L120) |
| CODE-042 | groups | [LinkEditorView.body](../LinkStow/View/LinkEditorView.swift#L73) | [GroupEditorView (type declaration)](../LinkStow/View/GroupEditorView.swift#L22) |
| CODE-043 | composition | [RootView.body](../LinkStow/App/RootView.swift#L13) | [MainController.init](../LinkStow/Controllers/MainController.swift#L12) |
| CODE-044 | composition | [RootView.body](../LinkStow/App/RootView.swift#L18) | [MainView.init](../LinkStow/View/MainView.swift#L90) |
| CODE-045 | composition | [LinkStowApp.body](../LinkStow/App/LinkStowApp.swift#L15) | [RootView (type declaration)](../LinkStow/App/RootView.swift#L5) |
| CODE-046 | capture | [MainView.controlArea](../LinkStow/View/MainView.swift#L176) | [LinkEditorView (type declaration)](../LinkStow/View/LinkEditorView.swift#L10) |
| CODE-047 | appearance | [SymbolModel.updateSymbol](../LinkStow/Models/Symbol.swift#L97) | [SymbolModel.setColor](../LinkStow/Models/Symbol.swift#L105) |
| CODE-048 | appearance | [SymbolModel.updateSymbol](../LinkStow/Models/Symbol.swift#L98) | [SymbolModel.setSymbolType](../LinkStow/Models/Symbol.swift#L124) |
| CODE-049 | appearance | [SymbolModel.setColor](../LinkStow/Models/Symbol.swift#L106) | [SymbolModel.colorComponents](../LinkStow/Models/Symbol.swift#L138) |
| CODE-050 | export | [MainController.openLink](../LinkStow/Controllers/MainController.swift#L141) | [MainController.isValidURLScheme](../LinkStow/Controllers/MainController.swift#L145) |
| CODE-051 | export | [QRCodeView.body](../LinkStow/View/QRCodeView.swift#L38) | [QRCodeView.copyQRCode](../LinkStow/View/QRCodeView.swift#L83) |

The machine-readable [connection index](code-connections.json) stores native artifact IDs, exact ranges, expressions and hashes. Run `python3 scripts/check_traceability.py` after changes. The checker rejects a missing direct source-to-source trace even if both files still trace to the same subsystem.
