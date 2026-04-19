import XCTest
import SwiftData
import SwiftUI
@testable import LinkStow

final class GroupTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    
    // Constants from MainView.swift
    let DEVICE_CORNER_RADIUS: CGFloat = 38
    let PADDING: CGFloat = 16
    let GROUP_CORNER_RADIUS: CGFloat = 22 // DEVICE_CORNER_RADIUS - PADDING = 38 - 16
    let GROUP_HEIGHT: CGFloat = 44 // GROUP_CORNER_RADIUS * 2 = 22 * 2
    let GROUP_PADDING: CGFloat = 12
    let GROUP_STROKE_WIDTH: CGFloat = 4 // GROUP_PADDING / 3 = 12 / 3
    let GROUP_BUBBLE_SPACING: CGFloat = 8 // GROUP_PADDING - GROUP_STROKE_WIDTH = 12 - 4
    
    override func setUp() {
        super.setUp()
        
        // Create an in-memory ModelContainer for testing
        let schema = Schema([
            LinkModel.self,
            GroupModel.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [config])
            modelContext = ModelContext(modelContainer)
        } catch {
            XCTFail("Failed to create ModelContainer: \(error)")
        }
    }
    
    override func tearDown() {
        modelContext = nil
        modelContainer = nil
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    /// Extract color components for comparison
    private func colorComponents(color: Color) -> (red: Double, green: Double, blue: Double, alpha: Double)? {
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        if uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return (Double(red), Double(green), Double(blue), Double(alpha))
        } else {
            return nil
        }
    }
    
    /// Create a test GroupModel instance with various configurations
    func createTestGroup(
        name: String = "",
        icon: String = "link",
        emoji: String = "🔗",
        color: Color = Color.blue,
        type: SymbolType = .icon
    ) -> GroupModel {
        let group = GroupModel(
            name: name,
            icon: icon,
            emoji: emoji,
            color: color,
            type: type
        )
        modelContext.insert(group)
        try? modelContext.save()
        return group
    }
    
    /// Create a test LinkModel instance for relationship tests
    func createTestLink(
        url: String = "https://example.com",
        title: String = "Test Link",
        caption: String = "Test caption"
    ) -> LinkModel {
        let link = LinkModel(
            url: url,
            title: title,
            caption: caption,
            faviconImage: nil
        )
        modelContext.insert(link)
        try? modelContext.save()
        return link
    }
    
    // MARK: - Section 1: Initialization & Defaults Tests
    
    func testTC_GINIT_01_DefaultInitialization() throws {
        // TC-GINIT-01: Default initialization
        let group = GroupModel()
        modelContext.insert(group)
        try modelContext.save()
        
        // Verify name == ""
        XCTAssertEqual(group.name, "", "Default name should be empty string")
        
        // Verify symbol.type == .icon
        XCTAssertEqual(group.symbol.getSymbolType(), .icon, "Default symbol type should be .icon")
        
        // Verify symbol.icon == "link"
        XCTAssertEqual(group.symbol.icon, "link", "Default icon should be 'link'")
        
        // Verify symbol.emoji == "🔗"
        XCTAssertEqual(group.symbol.emoji, "🔗", "Default emoji should be '🔗'")
        
        // Verify symbol.color == .blue (using colorComponents)
        let defaultColor = group.symbol.getColor()
        let blueColor = Color.blue
        let defaultComponents = colorComponents(color: defaultColor)
        let blueComponents = colorComponents(color: blueColor)
        guard let defaultComps = defaultComponents, let blueComps = blueComponents else {
            XCTFail("Failed to extract color components")
            return
        }
        XCTAssertEqual(defaultComps.red, blueComps.red, accuracy: 0.01, "Default color red component should match blue")
        XCTAssertEqual(defaultComps.green, blueComps.green, accuracy: 0.01, "Default color green component should match blue")
        XCTAssertEqual(defaultComps.blue, blueComps.blue, accuracy: 0.01, "Default color blue component should match blue")
        
        // Verify links.isEmpty == true
        XCTAssertTrue(group.links.isEmpty, "Default links should be empty")
        
        // Verify symbol.faviconData == nil
        XCTAssertNil(group.symbol.faviconData, "Default faviconData should be nil")
    }
    
    func testTC_GINIT_02_CustomInitialization() throws {
        // TC-GINIT-02: Custom initialization
        let customName = "My Custom Group"
        let customIcon = "star.fill"
        let customEmoji = "⭐"
        let customColor = Color.red
        let customType = SymbolType.icon
        
        let group = createTestGroup(
            name: customName,
            icon: customIcon,
            emoji: customEmoji,
            color: customColor,
            type: customType
        )
        
        // Verify all values persist correctly
        XCTAssertEqual(group.name, customName, "Name should be set correctly")
        XCTAssertEqual(group.symbol.icon, customIcon, "Icon should be set correctly")
        XCTAssertEqual(group.symbol.emoji, customEmoji, "Emoji should be set correctly")
        XCTAssertEqual(group.symbol.getSymbolType(), customType, "Symbol type should be set correctly")
        
        // Verify color
        let groupColor = group.symbol.getColor()
        let redColor = customColor
        let groupComponents = colorComponents(color: groupColor)
        let redComponents = colorComponents(color: redColor)
        guard let groupComps = groupComponents, let redComps = redComponents else {
            XCTFail("Failed to extract color components")
            return
        }
        XCTAssertEqual(groupComps.red, redComps.red, accuracy: 0.01, "Color red component should match")
        XCTAssertEqual(groupComps.green, redComps.green, accuracy: 0.01, "Color green component should match")
        XCTAssertEqual(groupComps.blue, redComps.blue, accuracy: 0.01, "Color blue component should match")
        
        // Verify faviconData == nil always
        XCTAssertNil(group.symbol.faviconData, "faviconData should always be nil for groups")
    }
    
    func testTC_GINIT_03_SymbolTypeEmoji() throws {
        // TC-GINIT-03: Symbol type .emoji
        let group = createTestGroup(
            name: "Emoji Group",
            icon: "link",
            emoji: "⭐",
            color: .green,
            type: .emoji
        )
        
        // Verify symbol.type == .emoji
        XCTAssertEqual(group.symbol.getSymbolType(), .emoji, "Symbol type should be .emoji")
        
        // Verify emoji value is set correctly
        XCTAssertEqual(group.symbol.emoji, "⭐", "Emoji should be set correctly")
    }
    
    func testTC_GINIT_04_SymbolTypeFavicon() throws {
        // TC-GINIT-04: Symbol type .favicon
        let group = createTestGroup(
            name: "Favicon Group",
            icon: "link",
            emoji: "🔗",
            color: .blue,
            type: .favicon
        )
        
        // Verify faviconData == nil (groups don't use favicons)
        XCTAssertNil(group.symbol.faviconData, "faviconData should be nil for groups even with .favicon type")
        
        // Verify type is set correctly
        XCTAssertEqual(group.symbol.getSymbolType(), .favicon, "Symbol type should be .favicon")
    }
    
    // MARK: - Section 2: updateGroup() Logic Tests
    
    func testTC_GUPD_01_NameUpdate() throws {
        // TC-GUPD-01: Name update
        let group = createTestGroup(name: "Original Name")
        
        group.updateGroup(
            name: "Updated Name",
            icon: group.symbol.icon,
            emoji: group.symbol.emoji,
            color: group.symbol.getColor(),
            type: group.symbol.getSymbolType()
        )
        
        try modelContext.save()
        
        // Verify name replaced correctly
        XCTAssertEqual(group.name, "Updated Name", "Name should be updated correctly")
    }
    
    func testTC_GUPD_02_SymbolUpdateToIcon() throws {
        // TC-GUPD-02: Symbol update to .icon
        let group = createTestGroup(
            name: "Test Group",
            icon: "link",
            emoji: "🔗",
            color: .blue,
            type: .emoji
        )
        
        // Update symbol to .icon
        group.updateGroup(
            name: group.name,
            icon: "star.fill",
            emoji: "⭐",
            color: .red,
            type: .icon
        )
        
        try modelContext.save()
        
        // Verify old symbol replaced
        XCTAssertEqual(group.symbol.getSymbolType(), .icon, "Symbol type should be .icon")
        XCTAssertEqual(group.symbol.icon, "star.fill", "Icon should be updated")
        
        // Verify color updated
        let updatedColor = group.symbol.getColor()
        let redColor = Color.red
        let updatedComponents = colorComponents(color: updatedColor)
        let redComponents = colorComponents(color: redColor)
        guard let updatedComps = updatedComponents, let redComps = redComponents else {
            XCTFail("Failed to extract color components")
            return
        }
        XCTAssertEqual(updatedComps.red, redComps.red, accuracy: 0.01, "Color should be updated to red")
    }
    
    func testTC_GUPD_03_SymbolUpdateToEmoji() throws {
        // TC-GUPD-03: Symbol update to .emoji
        let group = createTestGroup(
            name: "Test Group",
            icon: "link",
            emoji: "🔗",
            color: .blue,
            type: .icon
        )
        
        // Update symbol to .emoji
        group.updateGroup(
            name: group.name,
            icon: "star.fill",
            emoji: "⭐",
            color: .green,
            type: .emoji
        )
        
        try modelContext.save()
        
        // Verify emoji replaces icon usage
        XCTAssertEqual(group.symbol.getSymbolType(), .emoji, "Symbol type should be .emoji")
        XCTAssertEqual(group.symbol.emoji, "⭐", "Emoji should be updated")
    }
    
    func testTC_GUPD_04_MultipleSymbolUpdates() throws {
        // TC-GUPD-04: Multiple symbol updates
        let group = createTestGroup(
            name: "Test Group",
            icon: "link",
            emoji: "🔗",
            color: .blue,
            type: .icon
        )
        
        // First update to emoji
        group.updateGroup(
            name: group.name,
            icon: "star.fill",
            emoji: "⭐",
            color: .red,
            type: .emoji
        )
        
        // Second update back to icon
        group.updateGroup(
            name: group.name,
            icon: "heart.fill",
            emoji: "❤️",
            color: .pink,
            type: .icon
        )
        
        // Third update to emoji again
        group.updateGroup(
            name: group.name,
            icon: "bookmark.fill",
            emoji: "📚",
            color: .green,
            type: .emoji
        )
        
        try modelContext.save()
        
        // Verify no stale data retained
        XCTAssertEqual(group.symbol.getSymbolType(), .emoji, "Final symbol type should be .emoji")
        XCTAssertEqual(group.symbol.emoji, "📚", "Final emoji should be correct")
        XCTAssertEqual(group.symbol.icon, "bookmark.fill", "Icon should be updated (even though not used)")
        
        // Verify final state is correct
        let finalColor = group.symbol.getColor()
        let greenColor = Color.green
        let finalComponents = colorComponents(color: finalColor)
        let greenComponents = colorComponents(color: greenColor)
        guard let finalComps = finalComponents, let greenComps = greenComponents else {
            XCTFail("Failed to extract color components")
            return
        }
        XCTAssertEqual(finalComps.red, greenComps.red, accuracy: 0.01, "Final color should be green")
    }
    
    func testTC_GUPD_05_LinksArrayUnchanged() throws {
        // TC-GUPD-05: Links array unchanged
        let group = createTestGroup(name: "Test Group")
        let link1 = createTestLink(url: "https://example1.com")
        let link2 = createTestLink(url: "https://example2.com")
        
        // Add groups to links (which adds links to group via inverse relationship)
        link1.updateLink(
            title: link1.title,
            caption: link1.caption,
            symbolType: .icon,
            symbolIcon: "link",
            symbolEmoji: "🔗",
            symbolColor: .blue,
            reminderEnabled: false,
            reminderDate: Date(),
            reminderAllDay: false,
            groups: [group],
            isHidden: false
        )
        
        link2.updateLink(
            title: link2.title,
            caption: link2.caption,
            symbolType: .icon,
            symbolIcon: "link",
            symbolEmoji: "🔗",
            symbolColor: .blue,
            reminderEnabled: false,
            reminderDate: Date(),
            reminderAllDay: false,
            groups: [group],
            isHidden: false
        )
        
        try modelContext.save()
        
        // Verify group has links
        XCTAssertEqual(group.links.count, 2, "Group should have 2 links before update")
        
        // Update group
        group.updateGroup(
            name: "Updated Name",
            icon: "star.fill",
            emoji: "⭐",
            color: .red,
            type: .icon
        )
        
        try modelContext.save()
        
        // Verify links array unchanged
        XCTAssertEqual(group.links.count, 2, "Links array should be unchanged after update")
    }
    
    func testTC_GUPD_06_FaviconDataAlwaysNil() throws {
        // TC-GUPD-06: faviconData always nil
        let group = createTestGroup(name: "Test Group")
        
        // Verify initial state
        XCTAssertNil(group.symbol.faviconData, "faviconData should be nil initially")
        
        // Update group multiple times
        group.updateGroup(
            name: "Updated 1",
            icon: "star.fill",
            emoji: "⭐",
            color: .red,
            type: .icon
        )
        XCTAssertNil(group.symbol.faviconData, "faviconData should be nil after first update")
        
        group.updateGroup(
            name: "Updated 2",
            icon: "heart.fill",
            emoji: "❤️",
            color: .pink,
            type: .emoji
        )
        XCTAssertNil(group.symbol.faviconData, "faviconData should be nil after second update")
        
        group.updateGroup(
            name: "Updated 3",
            icon: "bookmark.fill",
            emoji: "📚",
            color: .green,
            type: .favicon
        )
        XCTAssertNil(group.symbol.faviconData, "faviconData should be nil after third update (even with .favicon type)")
        
        try modelContext.save()
    }
    
    // MARK: - Section 3: Relationship Behavior (SwiftData) Tests
    
    func testTC_GREL_01_AddGroupToLinkModelGroups() throws {
        // TC-GREL-01: Add group to LinkModel.groups
        let group = createTestGroup(name: "Test Group")
        let link = createTestLink()
        
        // Fetch group to ensure we're using a managed object
        let fetchDescriptor = FetchDescriptor<GroupModel>(predicate: #Predicate { $0.name == "Test Group" })
        let fetchedGroups = try modelContext.fetch(fetchDescriptor)
        guard let managedGroup = fetchedGroups.first else {
            XCTFail("Should be able to fetch the group")
            return
        }
        
        // Add group to link via updateLink(groups:)
        link.updateLink(
            title: link.title,
            caption: link.caption,
            symbolType: .icon,
            symbolIcon: "link",
            symbolEmoji: "🔗",
            symbolColor: .blue,
            reminderEnabled: false,
            reminderDate: Date(),
            reminderAllDay: false,
            groups: [managedGroup],
            isHidden: false
        )
        
        try modelContext.save()
        
        // Verify group appears in link.groups
        XCTAssertEqual(link.groups.count, 1, "Link should have 1 group")
        XCTAssertTrue(link.groups.contains(where: { $0 === managedGroup }), "Link should contain the group")
        
        // Verify link appears in group.links (inverse relationship)
        XCTAssertEqual(managedGroup.links.count, 1, "Group should have 1 link")
        XCTAssertTrue(managedGroup.links.contains(where: { $0 === link }), "Group should contain the link")
    }
    
    func testTC_GREL_02_RemoveGroupFromLink() throws {
        // TC-GREL-02: Remove group from link
        let group = createTestGroup(name: "Test Group")
        let link = createTestLink()
        
        // Fetch group to ensure we're using a managed object
        let fetchDescriptor = FetchDescriptor<GroupModel>(predicate: #Predicate { $0.name == "Test Group" })
        let fetchedGroups = try modelContext.fetch(fetchDescriptor)
        guard let managedGroup = fetchedGroups.first else {
            XCTFail("Should be able to fetch the group")
            return
        }
        
        // Create relationship
        link.updateLink(
            title: link.title,
            caption: link.caption,
            symbolType: .icon,
            symbolIcon: "link",
            symbolEmoji: "🔗",
            symbolColor: .blue,
            reminderEnabled: false,
            reminderDate: Date(),
            reminderAllDay: false,
            groups: [managedGroup],
            isHidden: false
        )
        
        try modelContext.save()
        
        // Verify relationship exists
        XCTAssertEqual(link.groups.count, 1, "Link should have 1 group before removal")
        XCTAssertEqual(managedGroup.links.count, 1, "Group should have 1 link before removal")
        
        // Remove group from link
        link.updateLink(
            title: link.title,
            caption: link.caption,
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
        
        try modelContext.save()
        
        // Verify relationship removed on both sides
        XCTAssertEqual(link.groups.count, 0, "Link should have 0 groups after removal")
        XCTAssertEqual(managedGroup.links.count, 0, "Group should have 0 links after removal")
    }
    
    func testTC_GREL_03_MultipleLinksWithSameGroup() throws {
        // TC-GREL-03: Multiple links with same group
        let group = createTestGroup(name: "Shared Group")
        let link1 = createTestLink(url: "https://example1.com")
        let link2 = createTestLink(url: "https://example2.com")
        let link3 = createTestLink(url: "https://example3.com")
        
        // Fetch group to ensure we're using a managed object
        let fetchDescriptor = FetchDescriptor<GroupModel>(predicate: #Predicate { $0.name == "Shared Group" })
        let fetchedGroups = try modelContext.fetch(fetchDescriptor)
        guard let managedGroup = fetchedGroups.first else {
            XCTFail("Should be able to fetch the group")
            return
        }
        
        // Add same group to all links
        for link in [link1, link2, link3] {
            link.updateLink(
                title: link.title,
                caption: link.caption,
                symbolType: .icon,
                symbolIcon: "link",
                symbolEmoji: "🔗",
                symbolColor: .blue,
                reminderEnabled: false,
                reminderDate: Date(),
                reminderAllDay: false,
                groups: [managedGroup],
                isHidden: false
            )
        }
        
        try modelContext.save()
        
        // Verify group.links.count matches
        XCTAssertEqual(managedGroup.links.count, 3, "Group should have 3 links")
        
        // Verify no duplication
        XCTAssertEqual(link1.groups.count, 1, "Link1 should have 1 group")
        XCTAssertEqual(link2.groups.count, 1, "Link2 should have 1 group")
        XCTAssertEqual(link3.groups.count, 1, "Link3 should have 1 group")
        
        // Verify all links reference the same group instance
        XCTAssertTrue(link1.groups.first === managedGroup, "Link1 should reference the same group")
        XCTAssertTrue(link2.groups.first === managedGroup, "Link2 should reference the same group")
        XCTAssertTrue(link3.groups.first === managedGroup, "Link3 should reference the same group")
    }
    
    func testTC_GREL_04_IdentitySemantics() throws {
        // TC-GREL-04: Identity semantics
        // Create two different GroupModel instances with same values
        let group1 = createTestGroup(
            name: "Same Name",
            icon: "star.fill",
            emoji: "⭐",
            color: .blue,
            type: .icon
        )
        
        let group2 = createTestGroup(
            name: "Same Name",
            icon: "star.fill",
            emoji: "⭐",
            color: .blue,
            type: .icon
        )
        
        // Verify they are treated as distinct (different persistentModelID)
        XCTAssertNotEqual(group1.persistentModelID, group2.persistentModelID, "Groups should have different persistentModelIDs")
        
        // Verify they can both exist independently
        let fetchDescriptor = FetchDescriptor<GroupModel>(predicate: #Predicate { $0.name == "Same Name" })
        let fetchedGroups = try modelContext.fetch(fetchDescriptor)
        XCTAssertEqual(fetchedGroups.count, 2, "Should have 2 groups with same name")
        
        // Verify they are different instances
        let fetchedGroup1 = fetchedGroups.first { $0.persistentModelID == group1.persistentModelID }
        let fetchedGroup2 = fetchedGroups.first { $0.persistentModelID == group2.persistentModelID }
        XCTAssertNotNil(fetchedGroup1, "Should be able to fetch group1")
        XCTAssertNotNil(fetchedGroup2, "Should be able to fetch group2")
        XCTAssertFalse(fetchedGroup1 === fetchedGroup2, "Groups should be different instances")
    }
    
    // MARK: - Section 4: getSymbolColor() Tests
    
    func testTC_GCOL_01_ReturnsCorrectColorForIconSymbol() throws {
        // TC-GCOL-01: Returns correct color for icon symbol
        let testColor = Color.red
        let group = createTestGroup(
            name: "Test Group",
            icon: "star.fill",
            emoji: "⭐",
            color: testColor,
            type: .icon
        )
        
        // Verify getSymbolColor() returns correct color
        let symbolColor = group.getSymbolColor()
        let expectedColor = testColor
        let symbolComponents = colorComponents(color: symbolColor)
        let expectedComponents = colorComponents(color: expectedColor)
        guard let symbolComps = symbolComponents, let expectedComps = expectedComponents else {
            XCTFail("Failed to extract color components")
            return
        }
        XCTAssertEqual(symbolComps.red, expectedComps.red, accuracy: 0.01, "Color red component should match")
        XCTAssertEqual(symbolComps.green, expectedComps.green, accuracy: 0.01, "Color green component should match")
        XCTAssertEqual(symbolComps.blue, expectedComps.blue, accuracy: 0.01, "Color blue component should match")
    }
    
    func testTC_GCOL_02_ReturnsCorrectColorForEmojiSymbol() throws {
        // TC-GCOL-02: Returns correct color for emoji symbol
        let testColor = Color.green
        let group = createTestGroup(
            name: "Test Group",
            icon: "star.fill",
            emoji: "⭐",
            color: testColor,
            type: .emoji
        )
        
        // Verify getSymbolColor() returns correct color
        let symbolColor = group.getSymbolColor()
        let expectedColor = testColor
        let symbolComponents = colorComponents(color: symbolColor)
        let expectedComponents = colorComponents(color: expectedColor)
        guard let symbolComps = symbolComponents, let expectedComps = expectedComponents else {
            XCTFail("Failed to extract color components")
            return
        }
        XCTAssertEqual(symbolComps.red, expectedComps.red, accuracy: 0.01, "Color red component should match")
        XCTAssertEqual(symbolComps.green, expectedComps.green, accuracy: 0.01, "Color green component should match")
        XCTAssertEqual(symbolComps.blue, expectedComps.blue, accuracy: 0.01, "Color blue component should match")
    }
    
    func testTC_GCOL_03_DoesNotCrashForUnexpectedSymbolType() throws {
        // TC-GCOL-03: Does not crash for unexpected symbol type
        // Test with all SymbolType cases
        for symbolType in SymbolType.allCases {
            let group = createTestGroup(
                name: "Test Group",
                icon: "link",
                emoji: "🔗",
                color: .blue,
                type: symbolType
            )
            
            // Verify no crashes
            let color = group.getSymbolColor()
            XCTAssertNotNil(color, "getSymbolColor should not return nil for \(symbolType)")
            
            // Verify color components can be extracted
            let components = colorComponents(color: color)
            XCTAssertNotNil(components, "Should be able to extract color components for \(symbolType)")
        }
    }
    
    // MARK: - Section 5-9: groupBubble View Tests (Structural/Indirect)
    
    // Note: Full view rendering tests require ViewInspector or snapshot testing framework.
    // These tests verify the underlying model behavior that drives the view rendering.
    
    func testTC_GVIEW_01_IconRendering() throws {
        // TC-GVIEW-01: Icon rendering (structural test)
        // Verify symbol.type == .icon renders Image(systemName:)
        // Verify size = 16x16 (structural - verify symbol type and icon name)
        let group = createTestGroup(
            name: "Icon Group",
            icon: "star.fill",
            emoji: "⭐",
            color: .blue,
            type: .icon
        )
        
        // Verify symbol type is .icon
        XCTAssertEqual(group.symbol.getSymbolType(), .icon, "Symbol type should be .icon")
        
        // Verify icon name is set correctly
        XCTAssertEqual(group.symbol.icon, "star.fill", "Icon name should be set correctly")
        
        // Note: Full rendering test (Image(systemName:) with size 16x16) requires ViewInspector
        throw XCTSkip("Full view rendering test requires ViewInspector framework")
    }
    
    func testTC_GVIEW_02_EmojiRendering() throws {
        // TC-GVIEW-02: Emoji rendering (structural test)
        // Verify symbol.type == .emoji renders Text
        // Verify font size = 16, bold (structural - verify symbol type and emoji)
        let group = createTestGroup(
            name: "Emoji Group",
            icon: "star.fill",
            emoji: "⭐",
            color: .green,
            type: .emoji
        )
        
        // Verify symbol type is .emoji
        XCTAssertEqual(group.symbol.getSymbolType(), .emoji, "Symbol type should be .emoji")
        
        // Verify emoji is set correctly
        XCTAssertEqual(group.symbol.emoji, "⭐", "Emoji should be set correctly")
        
        // Note: Full rendering test (Text with font size 16, bold) requires ViewInspector
        throw XCTSkip("Full view rendering test requires ViewInspector framework")
    }
    
    func testTC_GVIEW_03_FallbackRendering() throws {
        // TC-GVIEW-03: Fallback rendering (structural test)
        // Verify symbol.type == .favicon renders fallback "link" system image
        // Verify no crash
        let group = createTestGroup(
            name: "Favicon Group",
            icon: "link",
            emoji: "🔗",
            color: .blue,
            type: .favicon
        )
        
        // Verify symbol type is .favicon
        XCTAssertEqual(group.symbol.getSymbolType(), .favicon, "Symbol type should be .favicon")
        
        // Verify faviconData is nil (groups don't use favicons)
        XCTAssertNil(group.symbol.faviconData, "faviconData should be nil")
        
        // Verify no crash - can access symbol properties
        let _ = group.symbol.icon
        let _ = group.symbol.emoji
        let _ = group.getSymbolColor()
        
        // Note: Full rendering test (fallback Image(systemName: "link")) requires ViewInspector
        throw XCTSkip("Full view rendering test requires ViewInspector framework")
    }
    
    func testTC_GVIEW_04_GroupNameAppearsCorrectly() throws {
        // TC-GVIEW-04: Group name appears correctly (structural test)
        let groupName = "My Test Group"
        let group = createTestGroup(name: groupName)
        
        // Verify name is set correctly
        XCTAssertEqual(group.name, groupName, "Group name should be set correctly")
        
        // Note: Full rendering test (Text with group.name) requires ViewInspector
        throw XCTSkip("Full view rendering test requires ViewInspector framework")
    }
    
    func testTC_GVIEW_05_EmptyGroupNameRendersWithoutCrash() throws {
        // TC-GVIEW-05: Empty group name renders without crash (structural test)
        let group = createTestGroup(name: "")
        
        // Verify name is empty
        XCTAssertEqual(group.name, "", "Group name should be empty")
        
        // Verify no crash - can access name
        let _ = group.name
        
        // Note: Full rendering test (Text with empty string) requires ViewInspector
        throw XCTSkip("Full view rendering test requires ViewInspector framework")
    }
    
    func testTC_GVIEW_06_LongGroupNameTruncatesGracefully() throws {
        // TC-GVIEW-06: Long group name truncates gracefully (structural test)
        let longName = String(repeating: "A", count: 100)
        let group = createTestGroup(name: longName)
        
        // Verify long name is stored
        XCTAssertEqual(group.name, longName, "Long group name should be stored")
        XCTAssertEqual(group.name.count, 100, "Group name should have 100 characters")
        
        // Note: Full rendering test (truncation behavior) requires ViewInspector
        throw XCTSkip("Full view rendering test requires ViewInspector framework")
    }
    
    func testTC_GVIEW_07_SelectedStateStyling() throws {
        // TC-GVIEW-07: Selected = true (structural test)
        // Verify foreground color = .white
        // Verify glass tint uses group.getSymbolColor().opacity(0.8)
        let group = createTestGroup(
            name: "Test Group",
            icon: "star.fill",
            emoji: "⭐",
            color: .red,
            type: .icon
        )
        
        // Verify we can get symbol color for selected state
        let symbolColor = group.getSymbolColor()
        XCTAssertNotNil(symbolColor, "Should be able to get symbol color")
        
        // Verify color components can be extracted
        let components = colorComponents(color: symbolColor)
        XCTAssertNotNil(components, "Should be able to extract color components")
        
        // Note: Full rendering test (foreground color and glass tint) requires ViewInspector
        throw XCTSkip("Full view rendering test requires ViewInspector framework")
    }
    
    func testTC_GVIEW_08_UnselectedStateStyling() throws {
        // TC-GVIEW-08: Selected = false (structural test)
        // Verify foreground color = Color("GroupForeground")
        // Verify glass tint uses Color("GroupBackground")
        let group = createTestGroup(name: "Test Group")
        
        // Verify group exists and can be accessed
        XCTAssertNotNil(group, "Group should exist")
        
        // Note: Full rendering test (foreground color and glass tint) requires ViewInspector
        throw XCTSkip("Full view rendering test requires ViewInspector framework")
    }
    
    func testTC_GVIEW_09_HeightEqualsGroupHeight() throws {
        // TC-GVIEW-09: Height equals GROUP_HEIGHT (44)
        // Verify constant is correct
        XCTAssertEqual(GROUP_HEIGHT, 44, "GROUP_HEIGHT should be 44")
        XCTAssertEqual(GROUP_HEIGHT, GROUP_CORNER_RADIUS * 2, "GROUP_HEIGHT should equal GROUP_CORNER_RADIUS * 2")
        XCTAssertEqual(GROUP_CORNER_RADIUS, DEVICE_CORNER_RADIUS - PADDING, "GROUP_CORNER_RADIUS should be calculated correctly")
        
        // Note: Full rendering test (frame height) requires ViewInspector
        throw XCTSkip("Full view rendering test requires ViewInspector framework")
    }
    
    func testTC_GVIEW_10_PaddingEqualsGroupPadding() throws {
        // TC-GVIEW-10: Padding equals GROUP_PADDING (12)
        // Verify constant is correct
        XCTAssertEqual(GROUP_PADDING, 12, "GROUP_PADDING should be 12")
        
        // Note: Full rendering test (padding modifier) requires ViewInspector
        throw XCTSkip("Full view rendering test requires ViewInspector framework")
    }
    
    func testTC_GVIEW_11_CapsuleContentShapeApplied() throws {
        // TC-GVIEW-11: Capsule content shape applied (structural test)
        let group = createTestGroup(name: "Test Group")
        
        // Verify group exists
        XCTAssertNotNil(group, "Group should exist")
        
        // Note: Full rendering test (contentShape(Capsule())) requires ViewInspector
        throw XCTSkip("Full view rendering test requires ViewInspector framework")
    }
    
    func testTC_GVIEW_12_TapInteractionHitsEntireCapsuleArea() throws {
        // TC-GVIEW-12: Tap interaction hits entire capsule area (structural test)
        let group = createTestGroup(name: "Test Group")
        
        // Verify group exists
        XCTAssertNotNil(group, "Group should exist")
        
        // Note: Full interaction test requires ViewInspector or UI testing
        throw XCTSkip("Full interaction test requires ViewInspector or UI testing framework")
    }
    
    // MARK: - Section 9: Edge & Defensive Tests
    
    func testTC_GEDGE_01_InvalidSFSymbolName() throws {
        // TC-GEDGE-01: Invalid SF Symbol name
        // Test with invalid symbol name
        let invalidIcon = "invalid.symbol.name.that.does.not.exist"
        let group = createTestGroup(
            name: "Test Group",
            icon: invalidIcon,
            emoji: "🔗",
            color: .blue,
            type: .icon
        )
        
        // Verify does not crash
        XCTAssertNotNil(group, "Group should be created even with invalid icon name")
        XCTAssertEqual(group.symbol.icon, invalidIcon, "Invalid icon name should be stored")
        
        // Verify symbol type is still .icon
        XCTAssertEqual(group.symbol.getSymbolType(), .icon, "Symbol type should still be .icon")
        
        // Verify no crash - can access properties
        let _ = group.symbol.icon
        let _ = group.getSymbolColor()
        
        // Note: Full rendering test (empty or fallback image) requires ViewInspector
        throw XCTSkip("Full view rendering test requires ViewInspector framework")
    }
    
    func testTC_GEDGE_02_PerformanceManyGroupBubbles() throws {
        // TC-GEDGE-02: Performance - many group bubbles
        // Render many group bubbles
        // Verify no stutter (measure performance)
        
        // Create many groups
        var groups: [GroupModel] = []
        for i in 0..<100 {
            let group = createTestGroup(
                name: "Group \(i)",
                icon: "star.fill",
                emoji: "⭐",
                color: .blue,
                type: i % 2 == 0 ? .icon : .emoji
            )
            groups.append(group)
        }
        
        try modelContext.save()
        
        // Verify all groups were created
        let fetchDescriptor = FetchDescriptor<GroupModel>()
        let fetchedGroups = try modelContext.fetch(fetchDescriptor)
        XCTAssertGreaterThanOrEqual(fetchedGroups.count, 100, "Should have at least 100 groups")
        
        // Measure time to access all groups
        let startTime = CFAbsoluteTimeGetCurrent()
        for group in fetchedGroups {
            let _ = group.name
            let _ = group.symbol.getSymbolType()
            let _ = group.getSymbolColor()
        }
        let elapsedTime = CFAbsoluteTimeGetCurrent() - startTime
        
        // Verify performance is reasonable (should be very fast for property access)
        XCTAssertLessThan(elapsedTime, 1.0, "Accessing 100 groups should take less than 1 second")
        
        // Note: Full rendering performance test requires ViewInspector or snapshot testing
        throw XCTSkip("Full rendering performance test requires ViewInspector or snapshot testing framework")
    }
    
    func testTC_GEDGE_03_FrequentUpdatesDontRecreateViews() throws {
        // TC-GEDGE-03: Frequent updates don't recreate views
        // Update group frequently
        // Verify views don't recreate unnecessarily
        
        let group = createTestGroup(name: "Test Group")
        
        // Update group many times
        for i in 0..<50 {
            group.updateGroup(
                name: "Updated \(i)",
                icon: i % 2 == 0 ? "star.fill" : "heart.fill",
                emoji: i % 2 == 0 ? "⭐" : "❤️",
                color: i % 3 == 0 ? .blue : (i % 3 == 1 ? .red : .green),
                type: i % 2 == 0 ? .icon : .emoji
            )
        }
        
        try modelContext.save()
        
        // Verify final state is correct
        XCTAssertEqual(group.name, "Updated 49", "Final name should be correct")
        XCTAssertEqual(group.symbol.getSymbolType(), .emoji, "Final symbol type should be .emoji")
        
        // Verify group identity is preserved
        let groupID = group.persistentModelID
        let fetchDescriptor = FetchDescriptor<GroupModel>(predicate: #Predicate { $0.persistentModelID == groupID })
        let fetchedGroups = try modelContext.fetch(fetchDescriptor)
        XCTAssertEqual(fetchedGroups.count, 1, "Should still have one group with same ID")
        
        // Note: Full view recreation test requires ViewInspector
        throw XCTSkip("Full view recreation test requires ViewInspector framework")
    }
}
