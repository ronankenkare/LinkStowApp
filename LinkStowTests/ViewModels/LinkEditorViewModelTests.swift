import XCTest
import SwiftData
import SwiftUI
@testable import LinkStow

final class LinkEditorViewModelTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var controller: MainController!

    override func setUp() {
        super.setUp()
        let schema = Schema([LinkModel.self, GroupModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [config])
            modelContext = ModelContext(modelContainer)
            controller = MainController(modelContext: modelContext)
        } catch {
            XCTFail("Failed to create ModelContainer: \(error)")
        }
    }

    override func tearDown() {
        controller = nil
        modelContext = nil
        modelContainer = nil
        super.tearDown()
    }

    private func makeLink(url: String = "https://example.com", title: String = "Test", caption: String = "") -> LinkModel {
        LinkModel(url: url, title: title, caption: caption, faviconImage: nil)
    }


    // MARK: - Initialization

    func testInitializeForNewLink() {
        let vm = LinkEditorViewModel()
        let link = makeLink(title: "My Link", caption: "My Caption")
        vm.initialize(from: link, isNew: true)

        XCTAssertEqual(vm.linkUrl, "https://example.com")
        XCTAssertEqual(vm.linkTitle, "My Link")
        XCTAssertEqual(vm.linkCaption, "My Caption")
        XCTAssertFalse(vm.isHidden)
        XCTAssertTrue(vm.selectedGroups.isEmpty)
        XCTAssertFalse(vm.reminderDateToggleOn)
    }

    func testInitializeForExistingLinkPreservesSymbol() {
        let vm = LinkEditorViewModel()
        let link = makeLink()
        modelContext.insert(link)
        link.updateLink(
            title: "Existing", caption: "Caption",
            symbolType: .emoji, symbolIcon: "link", symbolEmoji: "🚀", symbolColor: .red,
            reminderEnabled: false, reminderDate: Date(), reminderAllDay: false,
            groups: [], isHidden: false
        )

        vm.initialize(from: link, isNew: false)

        XCTAssertEqual(vm.symbolSelection, .emoji)
        XCTAssertEqual(vm.selectedEmoji, "🚀")
        XCTAssertFalse(vm.isHidden)
    }

    func testInitializeForHiddenLinkClearsGroups() {
        let vm = LinkEditorViewModel()
        let group = GroupModel(name: "G", icon: "link", emoji: "🔗", color: .blue, type: .icon)
        modelContext.insert(group)
        let link = makeLink()
        modelContext.insert(link)
        link.updateLink(
            title: "Hidden Link", caption: "",
            symbolType: .icon, symbolIcon: "link", symbolEmoji: "🔗", symbolColor: .blue,
            reminderEnabled: false, reminderDate: Date(), reminderAllDay: false,
            groups: [], isHidden: true
        )

        vm.initialize(from: link, isNew: false)

        XCTAssertTrue(vm.isHidden)
        XCTAssertTrue(vm.selectedGroups.isEmpty)
    }

    func testInitializeForExistingLinkWithReminderEnabled() {
        let vm = LinkEditorViewModel()
        let link = makeLink()
        modelContext.insert(link)
        let reminderDate = Date().addingTimeInterval(86400)
        link.updateLink(
            title: "Reminder Link", caption: "",
            symbolType: .icon, symbolIcon: "link", symbolEmoji: "🔗", symbolColor: .blue,
            reminderEnabled: true, reminderDate: reminderDate, reminderAllDay: false,
            groups: [], isHidden: false
        )

        vm.initialize(from: link, isNew: false)

        XCTAssertTrue(vm.reminderDateToggleOn)
        XCTAssertTrue(vm.reminderTimeToggleOn)
    }


    // MARK: - Reset

    func testResetClearsAllState() {
        let vm = LinkEditorViewModel()
        vm.linkTitle = "Something"
        vm.linkCaption = "Caption"
        vm.selectedGroups = [GroupModel(name: "G", icon: "link", emoji: "🔗", color: .blue, type: .icon)]
        vm.isHidden = true
        vm.reminderDateToggleOn = true

        vm.reset()

        XCTAssertEqual(vm.linkTitle, "")
        XCTAssertEqual(vm.linkCaption, "")
        XCTAssertTrue(vm.selectedGroups.isEmpty)
        XCTAssertFalse(vm.isHidden)
        XCTAssertFalse(vm.reminderDateToggleOn)
        XCTAssertFalse(vm.isAuthenticating)
    }


    // MARK: - Save

    func testSaveNewLinkInsertsIntoContext() throws {
        let vm = LinkEditorViewModel()
        let link = makeLink()
        vm.initialize(from: link, isNew: true)
        vm.linkTitle = "Saved Link"
        vm.linkCaption = "Saved Caption"

        vm.save(link: link, isNew: true, mainController: controller)

        let fetched = try modelContext.fetch(FetchDescriptor<LinkModel>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.title, "Saved Link")
        XCTAssertEqual(fetched.first?.caption, "Saved Caption")
    }

    func testSaveExistingLinkUpdatesContext() throws {
        let link = makeLink()
        controller.addLink(
            linkModel: link, title: "Original", caption: "", symbolType: .icon,
            symbolIcon: "link", symbolEmoji: "🔗", symbolColor: .blue,
            reminderEnabled: false, reminderDate: Date(), reminderAllDay: false,
            groups: [], isHidden: false
        )

        let vm = LinkEditorViewModel()
        vm.initialize(from: link, isNew: false)
        vm.linkTitle = "Updated"

        vm.save(link: link, isNew: false, mainController: controller)

        let fetched = try modelContext.fetch(FetchDescriptor<LinkModel>())
        XCTAssertEqual(fetched.first?.title, "Updated")
    }

    func testSaveResetsViewModelState() {
        let vm = LinkEditorViewModel()
        let link = makeLink()
        vm.initialize(from: link, isNew: true)
        vm.linkTitle = "Title"

        vm.save(link: link, isNew: true, mainController: controller)

        XCTAssertEqual(vm.linkTitle, "")
    }


    // MARK: - Show Link Title Clear Button

    func testShowLinkTitleClearButtonReturnsTrueForNonEmptyTitle() {
        let vm = LinkEditorViewModel()
        vm.linkTitle = "Hello"
        XCTAssertTrue(vm.showLinkTitleClearButton)
    }

    func testShowLinkTitleClearButtonReturnsFalseForEmptyTitle() {
        let vm = LinkEditorViewModel()
        vm.linkTitle = ""
        XCTAssertFalse(vm.showLinkTitleClearButton)
    }

    func testShowLinkTitleClearButtonReturnsFalseForWhitespaceOnly() {
        let vm = LinkEditorViewModel()
        vm.linkTitle = "   "
        XCTAssertFalse(vm.showLinkTitleClearButton)
    }


    // MARK: - Auth Guard

    func testToggleHiddenToFalseDoesNotRequireAuth() async {
        let vm = LinkEditorViewModel()
        vm.isHidden = true

        await vm.toggleHidden()

        XCTAssertFalse(vm.isHidden, "Toggling off hidden should not require authentication")
        XCTAssertFalse(vm.isAuthenticating)
    }

    func testToggleHiddenGuardsAgainstConcurrentRequests() async {
        let vm = LinkEditorViewModel()
        vm.isHidden = false
        vm.isAuthenticating = true

        // Simulate double-tap while already authenticating
        await vm.toggleHidden()

        // Should not change state while isAuthenticating is true
        XCTAssertFalse(vm.isHidden, "Second tap should be ignored while authentication is in progress")
    }


    // MARK: - Notes Height

    func testUpdateNotesEditorHeightForEmptyCaption() {
        let vm = LinkEditorViewModel()
        vm.linkCaption = ""
        vm.updateNotesEditorHeight()
        XCTAssertEqual(vm.notesEditorHeight, NOTES_EDITOR_SINGLE_LINE_HEIGHT)
    }

    func testUpdateNotesEditorHeightCapsAtMaxLines() {
        let vm = LinkEditorViewModel()
        vm.linkCaption = String(repeating: "a\n", count: 20)
        vm.updateNotesEditorHeight()
        let maxHeight = CGFloat(NOTES_EDITOR_MAX_LINES) * NOTES_EDITOR_SINGLE_LINE_HEIGHT
        XCTAssertEqual(vm.notesEditorHeight, maxHeight)
    }
}
