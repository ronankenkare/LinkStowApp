# File coverage and unused-code audit

Audited against the saved Plus+C model, tracked repository files, Swift source
references, resource names, and Xcode project settings on 2026-10-28. This is a
static audit; it does not establish compiler dead stripping or runtime reachability.
The audit itself did not delete files. Later housekeeping cleanup is recorded
below; application behavior has not been changed.

## Why files can appear disconnected

The authored model covers **all 25 Swift files: 17 application files and 8 test
files**. All 25 have registered artifacts with saved native trace relationships.
The original completeness result counted registered elements; it did not mean
every repository file had a trace. The checker now also inventories Swift files
independently and fails if a new app or test Swift file is untraced.

The initial audit found **42 tracked non-Swift files** without registered source
artifacts: 26 asset files, 9 configuration/platform-resource files, 4 Finder
metadata files, 2 documentation/instruction files, and the Plus+C project file
itself. Subsequent cleanup removed the four Finder files and four optional
catalog/group metadata files. README sections, target build settings, and the
verification script now have native traces. A subsequent
[configuration/resource pass](configuration-traces.md) also covers the plist,
signing input, storyboard, scheme, test plan, dependency pin and all eighteen
asset definitions. Low-value workspace wrapper/settings metadata remains outside
the authored graph. A missing trace does not establish that a file is unnecessary.

Plus+C's automatic code overlay follows source imports and type references. It
does not infer all string-named asset lookups, build-setting references, storyboard
configuration, or documentation relationships. Such files need different
relationships from function-call links. The built-in Swift analysis also misses
free-function dependencies and cannot determine whether a file is dead.

## Non-Swift files

| Files or group | Current role | Assessment |
| --- | --- | --- |
| `LinkStow.xcodeproj/project.pbxproj` | Target membership, SwiftSoup dependency, resources, signing, generated Info.plist values, icons and deployment settings | Active build configuration; the target-settings anchor now traces to README prerequisites |
| `LinkStow.xcodeproj/project.xcworkspace/contents.xcworkspacedata` | Xcode workspace wrapper | Tooling metadata; not application logic |
| `LinkStow.xcodeproj/project.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings` | Shared Xcode workspace option | Tooling configuration; not application logic |
| `LinkStow.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved` | Pins SwiftSoup 2.10.0 and its revision | Traced to the package declaration and service import; not a log or disposable cache |
| `LinkStow.xcodeproj/xcshareddata/xcschemes/LinkStow.xcscheme` | Build/run/test actions and test-plan selection | Traced to the selected plan and build target |
| `LinkStow.xctestplan` | Lists unit/UI test targets; also referenced as a unit-test resource | Traced to existing unit-test sources; UI target remains a source-less placeholder. No test execution is implied |
| `LinkStow-Info.plist` | Empty dictionary referenced by `INFOPLIST_FILE`; settings generate its actual values | Traced as an empty base input; generated purpose/launch keys are separate project-setting anchors |
| `LinkStow/LinkStow.entitlements` | Empty dictionary referenced by `CODE_SIGN_ENTITLEMENTS` | Traced signing input; grants no additional capability |
| `LinkStow/App/LaunchScreen.storyboard` | Old launch-screen resource | Effective Debug iPhoneOS settings and declared Release settings select generated launch metadata, without UILaunchStoryboardName. Traced as unselected; missing linkStack_icon is an explicit finding. App launch was not executed |
| `README.md`, `AGENTS.md` | Project documentation and repository instructions | Useful nonruntime files. README now has diagram → section → source traces; AGENTS.md is not a runtime call endpoint |
| `project.plc`, `diagrams/*.plc` | The trace graph and its native views | Model data, not application source; diagram elements already participate in the model |
| `docs/*`, `scripts/check_traceability.py` | Authored guides, indexes, validation report and local verification tool | Documentation/tooling added for this task; the checker is traced from README verification instructions |
| `.DS_Store`, `LinkStow/.DS_Store`, `LinkStow/Assets.xcassets/.DS_Store`, `LinkStowTests/.DS_Store` | Finder view metadata | All four removed; `.gitignore` prevents newly generated Finder metadata from being added |

No tracked application log files were found. Git's internal metadata and logs, if
shown by a folder browser, belong to version control rather than LinkStow runtime
behavior. Nothing under `.git` was included in the source coverage counts.

## Assets

Asset catalogs use names and build settings, not ordinary source imports. Their
asset-level `Contents.json` files describe colors/images and image payloads; they
are not logs. Eighteen asset definitions are retained. Four info-only files were
removed from the catalog root and the `GroupColor`, `LinkDemoColors`, and
`MainButton` groups, where the files are
[optional under Apple's format](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_ref-Asset_Catalog_Format/AssetTypes.html).
Files defining colors, images and app icons were preserved.

| Asset | Evidence of use | Assessment |
| --- | --- | --- |
| `AccentColor` | `ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME` | Build-selected but has no assigned color values; classified configured-empty |
| `App Icon` and its PNGs | Device app-icon build setting and app-icon asset inclusion setting | Active app branding |
| `DefaultAppColor` | MainView and PreferencesView | Active UI resource |
| `GroupBackground`, `GroupBackgroundSelected`, `GroupForeground` | Group, LinkEditorView and/or MainView | Active UI resources |
| `CaptionDemoColor`, `TitleDemoColor` | PreferencesView | Active appearance-preview resources |
| `AddButton`, `LinkNotFoundButton`, `PasteButton`, `SearchButton` | Current capture/editor UI | Active UI resources |
| `linkStow_icon` and `PlainLogo_v4.png` | MainView and PreferencesView | Active UI branding |
| `FilterButton` | Color mapping for `.filterLink`, which is not entered by the current UI | Referenced by dormant behavior |
| `LinkStow_BigIcon` and `LinkStow-big-logo.jpeg` | README's image path | Documentation branding; no app-source reference found |
| `LinkSilver` | No reference found in Swift, storyboard or build settings | Unused-resource candidate |
| `CancelEditButton` | No reference found in Swift, storyboard or build settings | Unused-resource candidate |
| `UpdateButton` | No reference found in Swift, storyboard or build settings | Unused-resource candidate |

The three unused-resource candidates are a static finding. Asset catalogs may
still compile/package unreferenced assets; absence of a reference is not evidence
that a particular build excludes their bytes.

All eighteen manifests now have native configuration/resource traces. Twenty-two
literal references connect Swift, storyboard and README ranges to the appropriate
manifest. Binary images are recorded with payload hashes in the configuration
index, rather than being treated as line-oriented source code.

## Unused or dormant source within otherwise active files

| Source | Finding |
| --- | --- |
| [Models/UserDefaults.swift](../LinkStow/Models/UserDefaults.swift#L3) | Typed preference accessors are used by UserDefaultsTests, but production views use `@AppStorage` directly. The helper is unused by the app UI, not an untested or untraced file |
| [LinkEditorView.reminderSection](../LinkStow/View/LinkEditorView.swift#L41) | Section invocation is commented out. Reminder field/model code exists, but the controls are not rendered and notifications are not scheduled |
| [MainButtonState.filterLink](../LinkStow/View/MainView.swift#L28) | Declared and checked, but never assigned as a current main state. Text search and the corresponding button presentation are dormant; group filtering remains operational |
| [LinkStowApp.notificationError](../LinkStow/App/LinkStowApp.swift#L6) | State and alert scaffolding exist, but no operation assigns an error value |
| [LinkModel.linkService](../LinkStow/Models/Link.swift#L16) | Constructs a transient metadata-service instance that is never read; actual metadata requests use MainController.linkService |
| [LinkModel.isLinkHidden / toggleHideLink](../LinkStow/Models/Link.swift#L127) | Exercised by model tests; no production callers found. The UI uses the flag/view-model save path instead |
| [RootView.groups / links](../LinkStow/App/RootView.swift#L8) | Query results are not read by RootView.body; MainView owns its own queries. Unused results do not imply the property wrappers have no runtime work |
| [GroupEditorView.groupsList](../LinkStow/View/GroupEditorView.swift#L24) | Query result is declared but never read in this view |
| [LinkMetadataService import](../LinkStow/Services/LinkMetadataService.swift#L2) | `LinkPresentation` is imported but no LinkPresentation API is used; implementation uses URLSession and SwiftSoup |

No active screen, controller or service Swift file was identified as wholly dead
by this audit. The preference-helper file is the clear production-unused helper;
the rest of these findings are unused members or dormant paths inside active files.

## Coverage checks

Run `python3 scripts/check_traceability.py`. It checks:

- Each app/test Swift file has at least one saved native trace.
- Registered paths, ranges and whole-file hashes remain valid.
- Every requirement has its need/system/subsystem/component/source chain.
- Every indexed call-site-to-definition relationship exists in the saved model.
- Every diagram has its diagram → README → implementation bridge, and registered
  README section anchors match the current file.
- Critical configuration inputs and all asset definitions retain their native
  relationships, source references, payload hashes and reviewed status.

It does **not** assert that every non-Swift file has a trace, every function is
reachable, or every behavior has passing automated tests. The
[code connection guide](code-connections.md) describes the automatic graph's
limits; the [system traceability guide](traceability.md) describes model scope.
