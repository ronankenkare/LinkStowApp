# Configuration and resource traceability

The Plus+C project now includes **65 configuration/resource source anchors and 138 relationships** for build settings, plist/signing inputs, storyboard references, assets, testing workflow and dependency pinning. These relationships explain configuration and resource use; they are not runtime method calls.

## Read the graph

Use the Home trace links in Plus+C to open either endpoint. Exact setting/lookup ranges are registered with paths, line ranges and whole-file hashes. Native `represents` links carry explicit rationales such as SELECTS PLIST INPUT, REFERENCES NAMED ASSET, LOCKS DEPENDENCY and NOT SELECTED AT LAUNCH. Subranges `refine` their containing complete-file anchors where appropriate.

The existing System context, Component architecture and Hidden-link security diagrams have visible notes distinguishing configuration facts from inactive resources and empty signing inputs. The six established diagram categories and existing README/code bridges are preserved.

## Verified configuration

| Input | Evidence and interpretation |
| --- | --- |
| [config:info-plist](<../LinkStow-Info.plist#L1>) | Empty base dictionary selected by INFOPLIST_FILE. Generated runtime keys are supplied by project settings; the empty file does not supply Face ID text. |
| [config:entitlements](<../LinkStow/LinkStow.entitlements#L1>) | Empty signing input selected by CODE_SIGN_ENTITLEMENTS. Declares no additional capability and does not authorize hidden-link access. |
| [build:Debug:face-id-purpose](<../LinkStow.xcodeproj/project.pbxproj#L451>), [build:Release:face-id-purpose](<../LinkStow.xcodeproj/project.pbxproj#L494>) | NSFaceIDUsageDescription supplies purpose text if OS deviceOwnerAuthentication uses Face ID. That policy also supports passcode; the string is not an authorization decision. |
| [build:Debug:generated-launch-screen](<../LinkStow.xcodeproj/project.pbxproj#L454>), [build:Release:generated-launch-screen](<../LinkStow.xcodeproj/project.pbxproj#L497>) | Generated launch metadata is selected. Effective Debug iPhoneOS settings were queried with xcodebuild; Release selection was checked in project source. Neither has UILaunchStoryboardName. |
| [resource:storyboard](<../LinkStow/App/LaunchScreen.storyboard#L1>) | Not selected by those launch settings. It contains a real DefaultAppColor reference, but linkStack_icon is missing. No operational launch-screen claim is made. |
| [config:scheme](<../LinkStow.xcodeproj/xcshareddata/xcschemes/LinkStow.xcscheme#L1>) → [config:test-plan](<../LinkStow.xctestplan#L1>) | Shared scheme selects the test plan and app target. The plan names both unit/UI targets; the UI target has no checked-in sources, and the scheme's legacy UI Testable entry is skipped. These are configuration facts, not test results. |
| [config:package-pin](<../LinkStow.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved#L1>) → [SwiftSoup package declaration](<../LinkStow.xcodeproj/project.pbxproj#L651>) | SwiftSoup is pinned to 2.10.0 at revision `a81b1a5ac933dee8c6cfccf05d5ffcc5eb8c7ec4`; its service import is traced to that dependency. |

Xcode inspection used `xcodebuild -project LinkStow.xcodeproj -scheme LinkStow -configuration Debug -sdk iphoneos -showBuildSettings -json` with temporary derived-data/package directories. Dependency resolution succeeded. The app was not launched, and unit/UI tests were not executed for this trace-only change.

## Asset classifications

| Asset manifest | Status | Linked literal consumers |
| --- | --- | --- |
| [AccentColor](<../LinkStow/Assets.xcassets/AccentColor.colorset/Contents.json#L1>) | configured-empty | Build settings |
| [App Icon](<../LinkStow/Assets.xcassets/App Icon.appiconset/Contents.json#L1>) | active | Build settings |
| [DefaultAppColor](<../LinkStow/Assets.xcassets/DefaultAppColor.colorset/Contents.json#L1>) | active | [MainView.swift line 174](<../LinkStow/View/MainView.swift#L174>), [PreferencesView.swift line 38](<../LinkStow/View/PreferencesView.swift#L38>), [LaunchScreen.storyboard line 45](<../LinkStow/App/LaunchScreen.storyboard#L45>) |
| [GroupBackground](<../LinkStow/Assets.xcassets/GroupColor/GroupBackground.colorset/Contents.json#L1>) | active | [Group.swift line 86](<../LinkStow/Models/Group.swift#L86>), [LinkEditorView.swift line 526](<../LinkStow/View/LinkEditorView.swift#L526>), [MainView.swift line 574](<../LinkStow/View/MainView.swift#L574>) |
| [GroupBackgroundSelected](<../LinkStow/Assets.xcassets/GroupColor/GroupBackgroundSelected.colorset/Contents.json#L1>) | active | [LinkEditorView.swift line 526](<../LinkStow/View/LinkEditorView.swift#L526>), [MainView.swift line 76](<../LinkStow/View/MainView.swift#L76>) |
| [GroupForeground](<../LinkStow/Assets.xcassets/GroupColor/GroupForeground.colorset/Contents.json#L1>) | active | [Group.swift line 85](<../LinkStow/Models/Group.swift#L85>), [LinkEditorView.swift line 525](<../LinkStow/View/LinkEditorView.swift#L525>), [MainView.swift line 573](<../LinkStow/View/MainView.swift#L573>) |
| [CaptionDemoColor](<../LinkStow/Assets.xcassets/LinkDemoColors/CaptionDemoColor.colorset/Contents.json#L1>) | active | [PreferencesView.swift line 81](<../LinkStow/View/PreferencesView.swift#L81>) |
| [TitleDemoColor](<../LinkStow/Assets.xcassets/LinkDemoColors/TitleDemoColor.colorset/Contents.json#L1>) | active | [PreferencesView.swift line 67](<../LinkStow/View/PreferencesView.swift#L67>) |
| [LinkSilver](<../LinkStow/Assets.xcassets/LinkSilver.colorset/Contents.json#L1>) | unreferenced | Catalog inclusion only; no runtime consumer found |
| [LinkStow_BigIcon](<../LinkStow/Assets.xcassets/LinkStow_BigIcon.imageset/Contents.json#L1>) | documentation-only | [README.md line 2](<../README.md#L2>) |
| [AddButton](<../LinkStow/Assets.xcassets/MainButton/AddButton.colorset/Contents.json#L1>) | active | [LinkEditorView.swift line 571](<../LinkStow/View/LinkEditorView.swift#L571>), [MainView.swift line 261](<../LinkStow/View/MainView.swift#L261>) |
| [CancelEditButton](<../LinkStow/Assets.xcassets/MainButton/CancelEditButton.colorset/Contents.json#L1>) | unreferenced | Catalog inclusion only; no runtime consumer found |
| [FilterButton](<../LinkStow/Assets.xcassets/MainButton/FilterButton.colorset/Contents.json#L1>) | dormant | [MainView.swift line 262](<../LinkStow/View/MainView.swift#L262>) |
| [LinkNotFoundButton](<../LinkStow/Assets.xcassets/MainButton/LinkNotFoundButton.colorset/Contents.json#L1>) | active | [MainView.swift line 260](<../LinkStow/View/MainView.swift#L260>) |
| [PasteButton](<../LinkStow/Assets.xcassets/MainButton/PasteButton.colorset/Contents.json#L1>) | active | [MainView.swift line 258](<../LinkStow/View/MainView.swift#L258>) |
| [SearchButton](<../LinkStow/Assets.xcassets/MainButton/SearchButton.colorset/Contents.json#L1>) | active | [MainView.swift line 259](<../LinkStow/View/MainView.swift#L259>) |
| [UpdateButton](<../LinkStow/Assets.xcassets/MainButton/UpdateButton.colorset/Contents.json#L1>) | unreferenced | Catalog inclusion only; no runtime consumer found |
| [linkStow_icon](<../LinkStow/Assets.xcassets/linkStow_icon.imageset/Contents.json#L1>) | active | [MainView.swift line 189](<../LinkStow/View/MainView.swift#L189>), [PreferencesView.swift line 33](<../LinkStow/View/PreferencesView.swift#L33>) |

All eighteen manifests link to their app-catalog inclusion context. Twenty-two literal references connect Swift, storyboard or README ranges to the corresponding manifest. FilterButton remains dormant, the three unreferenced colors are not presented as active features, and README branding is documentation-only. AccentColor is build-selected but has no assigned color values.

Image payloads are described by their JSON manifests. The index records the actual image filenames and SHA-256 values, so changed/missing PNG/JPEG bytes are checked without pretending binary files have source-line ranges. The known missing storyboard image is recorded as a finding, not a dangling native endpoint.

## Configuration source anchors

| Anchor | Status | Range |
| --- | --- | --- |
| [build:complete](<../LinkStow.xcodeproj/project.pbxproj#L1>) | active | 1–680 |
| [build:Debug:plist-input](<../LinkStow.xcodeproj/project.pbxproj#L447>) | active | 447–447 |
| [build:Debug:generated-plist](<../LinkStow.xcodeproj/project.pbxproj#L446>) | active | 446–446 |
| [build:Debug:face-id-purpose](<../LinkStow.xcodeproj/project.pbxproj#L451>) | active | 451–451 |
| [build:Debug:generated-launch-screen](<../LinkStow.xcodeproj/project.pbxproj#L454>) | active | 454–454 |
| [build:Debug:signing-input](<../LinkStow.xcodeproj/project.pbxproj#L440>) | active | 440–440 |
| [build:Debug:app-icon](<../LinkStow.xcodeproj/project.pbxproj#L437>) | active | 437–437 |
| [build:Debug:accent-color](<../LinkStow.xcodeproj/project.pbxproj#L438>) | active | 438–438 |
| [build:Release:plist-input](<../LinkStow.xcodeproj/project.pbxproj#L490>) | active | 490–490 |
| [build:Release:generated-plist](<../LinkStow.xcodeproj/project.pbxproj#L489>) | active | 489–489 |
| [build:Release:face-id-purpose](<../LinkStow.xcodeproj/project.pbxproj#L494>) | active | 494–494 |
| [build:Release:generated-launch-screen](<../LinkStow.xcodeproj/project.pbxproj#L497>) | active | 497–497 |
| [build:Release:signing-input](<../LinkStow.xcodeproj/project.pbxproj#L483>) | active | 483–483 |
| [build:Release:app-icon](<../LinkStow.xcodeproj/project.pbxproj#L480>) | active | 480–480 |
| [build:Release:accent-color](<../LinkStow.xcodeproj/project.pbxproj#L481>) | active | 481–481 |
| [LinkStow synchronized source/resource folder](<../LinkStow.xcodeproj/project.pbxproj#L57>) | active | 57–62 |
| [config:info-plist](<../LinkStow-Info.plist#L1>) | empty-input | 1–5 |
| [config:entitlements](<../LinkStow/LinkStow.entitlements#L1>) | empty-input | 1–5 |
| [resource:storyboard](<../LinkStow/App/LaunchScreen.storyboard#L1>) | not-selected-by-launch-settings | 1–64 |
| [config:scheme](<../LinkStow.xcodeproj/xcshareddata/xcschemes/LinkStow.xcscheme#L1>) | active | 1–107 |
| [config:test-plan](<../LinkStow.xctestplan#L1>) | active | 1–38 |
| [config:package-pin](<../LinkStow.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved#L1>) | active | 1–15 |
| [SwiftSoup package declaration](<../LinkStow.xcodeproj/project.pbxproj#L651>) | active | 651–660 |
| [tool:configuration-checker](<../scripts/check_configuration_traces.py#L1>) | active | 1–112 |

## Reference semantics

| Relationship role | Meaning |
| --- | --- |
| configuration_part | Exact project setting/declaration within this Xcode project file. |
| build_configuration_for | Defines the application target and its configuration; not runtime calls. |
| selected_configuration_input | Empty base plist selected by INFOPLIST_FILE; generated keys come from project settings, not this empty dictionary. |
| selected_signing_input | Empty entitlements file selected by CODE_SIGN_ENTITLEMENTS; declares no extra capabilities. |
| selects_plist_input | This app configuration names LinkStow-Info.plist. |
| generates_runtime_plist | Project settings supply generated values alongside the empty base input; the packaged Info.plist is a build output. |
| selects_signing_input | Selects this empty signing input; it does not provide device-owner authentication. |
| supports_platform_declaration | Provides NSFaceIDUsageDescription text if the OS uses Face ID for the deviceOwnerAuthentication policy. Policy also supports passcode; this string grants no authorization. |
| platform_configuration_evidence | Hidden-link UI uses LocalAuthentication; this setting supplies the Face ID purpose text in this build configuration. |
| associated_platform_purpose | OS Face ID presentation uses this declared purpose; not a direct Swift method call or entitlement grant. |
| selects_app_icon | Device SDK app-icon build setting selects this asset definition. |
| selects_accent_color | Selects AccentColor; its current color entries have no assigned values. |
| not_selected_at_launch | Effective Debug settings and declared Release settings select generated launch-screen metadata and contain no UILaunchStoryboardName. |
| configuration_context | Build/resource evidence for the application boundary. The storyboard is explicitly not selected as the launch screen. |
| resource_in_source_folder | Present in the synchronized app source/resource folder; inclusion does not establish startup selection. |
| catalog_resource_input | Asset definition in the app asset catalog. Status: configured-empty. Inclusion is distinct from runtime use. |
| visual_resource_evidence | This named asset supports visual presentation; inspect string/build-setting consumer traces for the exact use. |
| references_named_asset | Literal resource reference; status: active. This is resource usage, not a function call. |
| source_part | Source range containing the named resource lookup. |
| storyboard_part | Color attribute inside the unselected storyboard. |
| references_documentation_image | Literal resource reference; status: documentation-only. This is resource usage, not a function call. |
| documentation_part | Brand image reference within the README. |
| selects_test_plan | The shared scheme points to LinkStow.xctestplan; this is configuration, not evidence that tests passed. |
| selects_build_target | Build/launch actions select the LinkStow target defined by this project. |
| selects_test_targets | Names LinkStowTests and LinkStowUITests; the UI target has no checked-in test sources. Scheme legacy UI Testable is marked skipped. |
| configured_test_source | Unit-test source belongs to the target named by the test plan; this is not test execution evidence. |
| documented_test_workflow | README test command uses this scheme. |
| locks_dependency | Pins the SwiftSoup package used by the project; the lockfile is not a cache or log. |
| resolved_dependency | Project declares SwiftSoup; the resolved lock records its checked-in version and revision. |
| imports_pinned_package | LinkMetadataService imports SwiftSoup; the resolved package supplies its HTML parser. |
| external_dependency_evidence | Metadata retrieval uses the pinned SwiftSoup library. |
| build_and_test_evidence | Developer workflow configuration for the source components, not an app subsystem. |
| calls_verifier | check_traceability.check delegates configuration/resource checks to check_configuration; developer tooling only. |
| verification_component | Implements the configuration/resource portion of the documented trace-integrity checker. |
| service_dependency | The file-scope SwiftSoup import supplies symbols used by LinkMetadataService; this is an import dependency rather than containment inside the class declaration. |

## Verification and maintenance

The [machine-readable index](configuration-traces.json) records native IDs, exact ranges, statuses, literal resource references, image hashes, test targets, package pin and effective Debug settings. Run `python3 scripts/check_traceability.py`; it delegates these checks to [check_configuration_traces.py](../scripts/check_configuration_traces.py).

The checker detects missing native relationships, new/unclassified asset definitions, changed image payloads, shifted references, changed package pins, newly populated plist/entitlements inputs, and changes requiring review of the inactive storyboard classification. Ordinary XML/JSON/plist syntax is checked too.

When inputs change, review their meaning first, then update/register the evidence and affected traces. A missing storyboard image becoming available, or a launch storyboard being selected, requires updating the recorded finding/status rather than silently preserving the old conclusion.

Low-value workspace-wrapper/editor settings remain intentionally untraced. The missing legacy image remains unresolved. Existing dormant search/reminder behavior remains documented; no runtime application source or configuration was altered by this pass.
