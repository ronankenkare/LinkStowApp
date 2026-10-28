# LinkStow system model and code traceability

Open this repository folder in **Plus+C**. `project.plc` holds shared source artifacts and trace relationships; `diagrams/*.plc` hold the ten native documents and diagrams. Commit them together. The Plus+C Home canvas shows links between views and source files; click a trace to open its endpoints side by side in trace mode. Element traces support narrower navigation than whole-diagram links. See [code-to-code connections](code-connections.md) for exact caller/callee mappings and the built-in file dependency overlay.

All ten diagrams also have **diagram → README section/row → implementation** links. The [README trace guide](readme-traces.md) lists the 25 documentation anchors, direct code evidence, and native trace semantics. README prose is explanatory evidence, not test execution or stakeholder approval.

The [configuration/resource guide](configuration-traces.md) extends this graph to plist and signing inputs, exact build settings, storyboard references, asset definitions, scheme/test-plan selection, and the SwiftSoup pin. These links use explicit configuration/resource rationales and retain dormant, empty, unreferenced, and unselected classifications.

Baseline: source commit `8dfeb63a03b5bc15a3dd8bb44f636a8b2aec56a5`, inspected on 2026-10-28. Stakeholder needs are inferred from the implemented app and require stakeholder review before adoption as an approved baseline. Requirements describe current behavior, including limitations; they do not imply planned features work.

Coverage is complete for the 25 application/test Swift files, not every repository file. See the [file-coverage and unused-code audit](file-coverage.md) for disconnected configuration/resources, Finder metadata, and dormant source. Source-graph completeness does not establish runtime reachability.

## Reading order

| Level | Native Plus+C view | Purpose |
| --- | --- | --- |
| Stakeholders | [01 Stakeholder needs](<../diagrams/01 Stakeholder needs.plc>) | Six inferred needs of the link owner/device owner and recipients. |
| Requirements | [02 System requirements](<../diagrams/02 System requirements.plc>) | Sixteen uniquely keyed as-built system requirements. |
| High-level system | [03 System context](<../diagrams/03 System context.plc>) | The app boundary, external actors, OS services and remote data flows. |
| Subsystems | [04 Component architecture](<../diagrams/04 Component architecture.plc>) | Six logical responsibilities allocated to system requirements. |
| Code | [05 Subsystems to code](<../diagrams/05 Subsystems to code.plc>) | Seventeen source-level components, real dependencies and registered source references. |
| Behavior | [06 Save-link flow](<../diagrams/06 Save-link flow.plc>) | Capture, verification, metadata, manual fallback and save/cancel. |
| Data | [07 Data model](<../diagrams/07 Data model.plc>) | Shared SwiftData classifiers, relationship multiplicities and invariants. |
| UI states | [08 Main state machine](<../diagrams/08 Main state machine.plc>) | Current capture transitions and the explicitly dormant filterLink state. |
| Trust boundaries | [09 Hidden-link security](<../diagrams/09 Hidden-link security.plc>) | Hidden-filter authentication and the limits of UI gating. |
| Source interactions | [10 Code call paths](<../diagrams/10 Code call paths.plc>) | Save-call sequence with exact caller/callee anchors and separate new/existing-link branches. |

The six established diagram categories are preserved. The code and data views reuse the same project elements for LinkModel, GroupModel and SymbolModel. Subsystems are logical responsibilities within one app process; they are not separate deployments.

## Trace semantics

The decomposition reads **stakeholder need → system requirement → LinkStow system → logical subsystem → source component → source file/symbol**. Native derivation arrows point back toward their basis:

- Requirement **refines** need; LinkStow system **satisfies** requirement.
- Subsystem **refines** system and **satisfies** its allocated requirements.
- Source component **realizes** subsystem and **satisfies** its directly implemented requirements.
- Registered source artifact **implements** source component. Component **represents** source artifact records the reverse-engineered evidence direction, intentionally providing a return path to the code.
- Behavior nodes **refine** subsystems and **represent** the implementing source components. Data attributes **refine** their owning model.
- Existing test artifacts **represent** requirements as partial evidence, with a rationale that explicitly does not claim test execution or complete verification.
- Code call-site artifacts **represent** the invoked definitions, with an explicit **CALLS** rationale; each source part **refines** its containing file artifact. These are authored source mappings using the supported generic trace vocabulary, not a compiler-generated call graph.

Every registered artifact carries a repository-relative path, symbol, source range and whole-file SHA-256. The original component anchors extend from the principal declaration to the file end; the added call sites and definitions use precise statement/declaration ranges. A file can include extensions and helper declarations. File hashes cover the entire file.

Example: `NEED-005 ← REQ-012 ← LinkStow ← OpenQRSharing ← QRCodeGenerator ← LinkStow/Services/QRCodeGenerator.swift`. A subsystem allocation also directly connects OpenQRSharing to REQ-012.

## Requirement allocation and code evidence

| Requirement | Need | Allocated subsystems | Source evidence |
| --- | --- | --- | --- |
| REQ-001 — Verify entered or pasted URLs | NEED-001 | CaptureEditing | [MainView](../LinkStow/View/MainView.swift#L43), [MainController](../LinkStow/Controllers/MainController.swift#L7), [LinkMetadataService](../LinkStow/Services/LinkMetadataService.swift#L5) |
| REQ-002 — Retrieve best-effort metadata | NEED-001 | CaptureEditing | [MainView](../LinkStow/View/MainView.swift#L43), [LinkMetadataService](../LinkStow/Services/LinkMetadataService.swift#L5) |
| REQ-003 — Allow manual capture after verification failure | NEED-001 | CaptureEditing | [MainView](../LinkStow/View/MainView.swift#L43), [MainController](../LinkStow/Controllers/MainController.swift#L7), [LinkEditorView](../LinkStow/View/LinkEditorView.swift#L10) |
| REQ-004 — Store the library locally | NEED-006 | LocalPersistence | [LinkStowApp](../LinkStow/App/LinkStowApp.swift#L5), [AppModelContainer](../LinkStow/App/ModelContainerProvider.swift#L3), [MainController](../LinkStow/Controllers/MainController.swift#L7) |
| REQ-005 — Maintain reusable groups | NEED-002 | LibraryInteraction, LocalPersistence | [GroupEditorView](../LinkStow/View/GroupEditorView.swift#L22), [MainController](../LinkStow/Controllers/MainController.swift#L7), [LinkModel](../LinkStow/Models/Link.swift#L13), [GroupModel](../LinkStow/Models/Group.swift#L6) |
| REQ-006 — Select and sort library records | NEED-002 | LibraryInteraction | [MainView](../LinkStow/View/MainView.swift#L43) |
| REQ-007 — Guard selected hidden-link UI transitions | NEED-003 | HiddenLinkGuards | [MainView](../LinkStow/View/MainView.swift#L43), [PreferencesView](../LinkStow/View/PreferencesView.swift#L3), [LinkEditorViewModel](../LinkStow/ViewModels/LinkEditorViewModel.swift#L5), [authenticateUser](../LinkStow/Services/Authentication.swift#L6) |
| REQ-008 — Clear groups when saving a hidden link | NEED-003 | LocalPersistence, HiddenLinkGuards | [LinkModel](../LinkStow/Models/Link.swift#L13), [LinkEditorViewModel](../LinkStow/ViewModels/LinkEditorViewModel.swift#L5) |
| REQ-009 — Customize visual symbols | NEED-004 | SymbolsPreferences | [LinkEditorView](../LinkStow/View/LinkEditorView.swift#L10), [GroupEditorView](../LinkStow/View/GroupEditorView.swift#L22), [SymbolModel](../LinkStow/Models/Symbol.swift#L62) |
| REQ-010 — Persist appearance preferences | NEED-004 | SymbolsPreferences | [PreferencesView](../LinkStow/View/PreferencesView.swift#L3), [MainView](../LinkStow/View/MainView.swift#L43) |
| REQ-011 — Open only standard web schemes | NEED-005 | OpenQRSharing | [MainController](../LinkStow/Controllers/MainController.swift#L7) |
| REQ-012 — Generate and export QR images | NEED-005 | OpenQRSharing | [QRCodeView / ShareSheet](../LinkStow/View/QRCodeView.swift#L7), [QRCodeGenerator](../LinkStow/Services/QRCodeGenerator.swift#L4) |
| REQ-013 — Share saved URLs | NEED-005 | OpenQRSharing | [MainView](../LinkStow/View/MainView.swift#L43), [QRCodeView / ShareSheet](../LinkStow/View/QRCodeView.swift#L7) |
| REQ-014 — Store reminder intent only | NEED-006 | LocalPersistence | [LinkModel](../LinkStow/Models/Link.swift#L13), [LinkEditorViewModel](../LinkStow/ViewModels/LinkEditorViewModel.swift#L5) |
| REQ-015 — Isolate and reset editor state | NEED-006 | CaptureEditing | [LinkEditorView](../LinkStow/View/LinkEditorView.swift#L10), [LinkEditorViewModel](../LinkStow/ViewModels/LinkEditorViewModel.swift#L5), [MainController](../LinkStow/Controllers/MainController.swift#L7) |
| REQ-016 — Represent implemented main-button states | NEED-002 | LibraryInteraction | [MainView](../LinkStow/View/MainView.swift#L43) |

## Verification evidence and limits

Eight existing XCTest files are registered in Plus+C with hashes and requirement traces. They were inspected, not executed for this documentation-only change. These are partial evidence references: model/controller tests do not establish UI behavior, OS authentication success, notification delivery or network reliability.

| Existing test source | Requirements with partial evidence |
| --- | --- |
| [MainControllerTests](../LinkStowTests/Controllers/MainControllerTests.swift#L6) | REQ-003, REQ-004, REQ-005, REQ-008, REQ-011 |
| [LinkTests](../LinkStowTests/Models/LinkTests.swift#L6) | REQ-004, REQ-005, REQ-008, REQ-009, REQ-014 |
| [GroupTests](../LinkStowTests/Models/GroupTests.swift#L6) | REQ-004, REQ-005, REQ-009 |
| [LinkGroupRelationshipTests](../LinkStowTests/Models/LinkGroupRelationshipTests.swift#L5) | REQ-005 |
| [SymbolTests](../LinkStowTests/Models/SymbolTests.swift#L6) | REQ-004, REQ-009 |
| [UserDefaultsTests](../LinkStowTests/Models/UserDefaultsTests.swift#L4) | REQ-010 |
| [QRCodeGeneratorTests](../LinkStowTests/Services/QRCodeGeneratorTests.swift#L6) | REQ-012 |
| [LinkEditorViewModelTests](../LinkStowTests/ViewModels/LinkEditorViewModelTests.swift#L6) | REQ-007, REQ-008, REQ-014, REQ-015 |

Metadata fetching, main-screen transitions, share-sheet presentation and successful OS authentication lack dedicated automated coverage in this repository. UserDefaultsTests covers the typed preference helper; it does not exercise the production AppStorage screens. Authentication tests exercise the unhide path and concurrent-request guard, not a successful LAContext prompt.

## Known implementation gaps

| ID | Current behavior | Source |
| --- | --- | --- |
| GAP-001 | Text filtering is gated on mainState == .filterLink, but no transition sets that state. Group and hidden selection and title sorting are implemented. | [MainView](../LinkStow/View/MainView.swift#L43) |
| GAP-002 | The editor passes reminderTimeToggleOn as reminderAllDay, while initialization negates reminderAllDay. Stored reminder intent can therefore round-trip incorrectly. | [LinkEditorViewModel](../LinkStow/ViewModels/LinkEditorViewModel.swift#L5) |
| GAP-003 | Reminder data and editor-control definitions exist, but reminderSection is commented out of the main editor form. Notification permission/scheduling/delivery do not exist. The notification-error state and init comment are dormant scaffolding. | [LinkEditorView](../LinkStow/View/LinkEditorView.swift#L41), [LinkStowApp](../LinkStow/App/LinkStowApp.swift#L5), [LinkModel](../LinkStow/Models/Link.swift#L13) |
| GAP-004 | Hidden protection is UI gating with deviceOwnerAuthentication (biometrics or passcode), not an application-level encrypted vault. Hidden records are queried before authentication. Controller/model methods have no auth guard or lifecycle relock. Disabling the preference does not itself clear the selected hidden filter. | [authenticateUser](../LinkStow/Services/Authentication.swift#L6), [MainView](../LinkStow/View/MainView.swift#L43), [PreferencesView](../LinkStow/View/PreferencesView.swift#L3) |
| GAP-005 | updateLink clears groups on hidden records, but direct writes and toggleHideLink bypass the invariant. Save errors are suppressed with try?; additions rely on autosave; container failure terminates startup. | [LinkModel](../LinkStow/Models/Link.swift#L13), [MainController](../LinkStow/Controllers/MainController.swift#L7), [AppModelContainer](../LinkStow/App/ModelContainerProvider.swift#L3) |
| GAP-006 | Metadata operations have no request-generation or cancellation guard in the view. A late result can overwrite changed capture input. The found-link preview force-unwraps UIImage decoding even though icon fetching may accept small non-image blobs. | [MainView](../LinkStow/View/MainView.swift#L43), [LinkMetadataService](../LinkStow/Services/LinkMetadataService.swift#L5) |

## Keeping the model current

1. Update the relevant native diagrams and requirement statements when behavior changes. Preserve IDs by editing existing elements, and reuse elements across views.
2. Inspect impacted code and tests. Re-register changed artifacts with their new whole-file hashes and navigation ranges. Review affected traces before acknowledging them; updating a hash is not evidence that the diagrams are still correct.
3. Save the active draft before switching views. Validate each changed diagram, then run Plus+C check_trace_drift and trace_coverage in both directions.
4. Run `python3 scripts/check_traceability.py` and `git diff --check` before committing. The local checker reads saved files, detects source drift and broken references, requires a complete need/requirement/system/subsystem/component/code chain for every requirement, and verifies the explicit source-to-source edges in [code-connections.json](code-connections.json). It does not contact MCP or require a token.

The recorded [native validation report](plus-c-validation.json) is a baseline snapshot. Intentional warnings are the isolated UserDefaults helper and the continuously running state machine with a declared, unreachable filterLink state. These warnings remain visible instead of adding fictional transitions or dependencies. No HTML or JavaScript documentation is introduced; native Plus+C files are the diagram source.
