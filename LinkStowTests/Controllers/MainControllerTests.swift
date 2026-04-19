import XCTest
import SwiftData
import SwiftUI
@testable import LinkStow

final class MainControllerTests: XCTestCase {
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


    // MARK: - URL Scheme Validation

    func testIsValidURLSchemeAcceptsHTTPS() {
        let url = URL(string: "https://example.com")!
        XCTAssertTrue(controller.isValidURLScheme(url))
    }

    func testIsValidURLSchemeAcceptsHTTP() {
        let url = URL(string: "http://example.com")!
        XCTAssertTrue(controller.isValidURLScheme(url))
    }

    func testIsValidURLSchemeRejectsJavaScript() {
        let url = URL(string: "javascript:alert('xss')")!
        XCTAssertFalse(controller.isValidURLScheme(url))
    }

    func testIsValidURLSchemeRejectsDataURI() {
        let url = URL(string: "data:text/html,<h1>test</h1>")!
        XCTAssertFalse(controller.isValidURLScheme(url))
    }

    func testIsValidURLSchemeRejectsFTP() {
        let url = URL(string: "ftp://files.example.com")!
        XCTAssertFalse(controller.isValidURLScheme(url))
    }

    func testIsValidURLSchemeRejectsCustomScheme() {
        let url = URL(string: "myapp://open")!
        XCTAssertFalse(controller.isValidURLScheme(url))
    }

    func testIsValidURLSchemeIsCaseInsensitive() {
        let url = URL(string: "HTTPS://example.com")!
        XCTAssertTrue(controller.isValidURLScheme(url))
    }


    // MARK: - Link CRUD

    func testCreateLinkReturnsUnsavedModel() throws {
        let link = controller.createLink(url: "https://example.com", title: "Example", caption: "A test", faviconImage: nil)
        XCTAssertEqual(link.url, "https://example.com")
        XCTAssertEqual(link.title, "Example")

        let fetched = try modelContext.fetch(FetchDescriptor<LinkModel>())
        XCTAssertTrue(fetched.isEmpty, "createLink should not insert into the context")
    }

    func testAddLinkInsertsIntoContext() throws {
        let link = controller.createLink(url: "https://example.com", title: "", caption: "", faviconImage: nil)
        controller.addLink(
            linkModel: link,
            title: "Example",
            caption: "Caption",
            symbolType: .icon,
            symbolIcon: "link",
            symbolEmoji: "🔗",
            symbolColor: .blue,
            reminderEnabled: false,
            reminderDate: Date(),
            reminderAllDay: false,
            groups: [],
            isHidden: false
        )

        let fetched = try modelContext.fetch(FetchDescriptor<LinkModel>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.title, "Example")
        XCTAssertEqual(fetched.first?.caption, "Caption")
    }

    func testUpdateLinkPersistsChanges() throws {
        let link = controller.createLink(url: "https://example.com", title: "", caption: "", faviconImage: nil)
        controller.addLink(
            linkModel: link, title: "Original", caption: "", symbolType: .icon,
            symbolIcon: "link", symbolEmoji: "🔗", symbolColor: .blue,
            reminderEnabled: false, reminderDate: Date(), reminderAllDay: false,
            groups: [], isHidden: false
        )

        controller.updateLink(
            linkModel: link, title: "Updated", caption: "New caption", symbolType: .icon,
            symbolIcon: "link", symbolEmoji: "🔗", symbolColor: .blue,
            reminderEnabled: false, reminderDate: Date(), reminderAllDay: false,
            groups: [], isHidden: false
        )

        let fetched = try modelContext.fetch(FetchDescriptor<LinkModel>())
        XCTAssertEqual(fetched.first?.title, "Updated")
        XCTAssertEqual(fetched.first?.caption, "New caption")
    }

    func testDeleteLinkRemovesFromContext() throws {
        let link = controller.createLink(url: "https://example.com", title: "", caption: "", faviconImage: nil)
        controller.addLink(
            linkModel: link, title: "To Delete", caption: "", symbolType: .icon,
            symbolIcon: "link", symbolEmoji: "🔗", symbolColor: .blue,
            reminderEnabled: false, reminderDate: Date(), reminderAllDay: false,
            groups: [], isHidden: false
        )

        controller.deleteLink(link: link)

        let fetched = try modelContext.fetch(FetchDescriptor<LinkModel>())
        XCTAssertTrue(fetched.isEmpty)
    }


    // MARK: - Group CRUD

    func testCreateNewGroupReturnsUnsavedModel() throws {
        let group = controller.createNewGroup()
        XCTAssertEqual(group.name, "")

        let fetched = try modelContext.fetch(FetchDescriptor<GroupModel>())
        XCTAssertTrue(fetched.isEmpty, "createNewGroup should not insert into the context")
    }

    func testAddGroupInsertsIntoContext() throws {
        let group = controller.createNewGroup()
        controller.addGroup(groupModel: group, name: "Test Group", icon: "star", emoji: "⭐", color: .blue, type: .icon)

        let fetched = try modelContext.fetch(FetchDescriptor<GroupModel>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.name, "Test Group")
    }

    func testUpdateGroupPersistsChanges() throws {
        let group = controller.createNewGroup()
        controller.addGroup(groupModel: group, name: "Original", icon: "link", emoji: "🔗", color: .blue, type: .icon)
        controller.updateGroup(groupModel: group, name: "Updated", icon: "star", emoji: "⭐", color: .red, type: .emoji)

        let fetched = try modelContext.fetch(FetchDescriptor<GroupModel>())
        XCTAssertEqual(fetched.first?.name, "Updated")
    }

    func testDeleteGroupRemovesFromContext() throws {
        let group = controller.createNewGroup()
        controller.addGroup(groupModel: group, name: "To Delete", icon: "link", emoji: "🔗", color: .blue, type: .icon)
        controller.deleteGroup(group: group)

        let fetched = try modelContext.fetch(FetchDescriptor<GroupModel>())
        XCTAssertTrue(fetched.isEmpty)
    }

    func testDeleteGroupRemovesFromLinksViaSwiftData() throws {
        let group = controller.createNewGroup()
        controller.addGroup(groupModel: group, name: "Group A", icon: "link", emoji: "🔗", color: .blue, type: .icon)

        let link = controller.createLink(url: "https://example.com", title: "", caption: "", faviconImage: nil)
        controller.addLink(
            linkModel: link, title: "Link A", caption: "", symbolType: .icon,
            symbolIcon: "link", symbolEmoji: "🔗", symbolColor: .blue,
            reminderEnabled: false, reminderDate: Date(), reminderAllDay: false,
            groups: [group], isHidden: false
        )

        XCTAssertEqual(link.groups.count, 1, "Link should have 1 group before deletion")

        controller.deleteGroup(group: group)

        // After deletion SwiftData's .nullify rule removes the group from link.groups
        let fetchedLinks = try modelContext.fetch(FetchDescriptor<LinkModel>())
        XCTAssertEqual(fetchedLinks.first?.groups.count, 0, "SwiftData should remove deleted group from link")
    }

    func testLinkHiddenStateRemovesGroups() throws {
        let group = controller.createNewGroup()
        controller.addGroup(groupModel: group, name: "Group", icon: "link", emoji: "🔗", color: .blue, type: .icon)

        let link = controller.createLink(url: "https://example.com", title: "", caption: "", faviconImage: nil)
        controller.addLink(
            linkModel: link, title: "Link", caption: "", symbolType: .icon,
            symbolIcon: "link", symbolEmoji: "🔗", symbolColor: .blue,
            reminderEnabled: false, reminderDate: Date(), reminderAllDay: false,
            groups: [group], isHidden: false
        )

        XCTAssertEqual(link.groups.count, 1)

        controller.updateLink(
            linkModel: link, title: "Link", caption: "", symbolType: .icon,
            symbolIcon: "link", symbolEmoji: "🔗", symbolColor: .blue,
            reminderEnabled: false, reminderDate: Date(), reminderAllDay: false,
            groups: [], isHidden: true
        )

        XCTAssertTrue(link.isHidden)
        XCTAssertEqual(link.groups.count, 0, "Hidden links should have no groups")
    }
}
