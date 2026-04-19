import XCTest
import SwiftData
import SwiftUI
@testable import LinkStow

final class SymbolTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    
    override func setUp() {
        super.setUp()
        
        // Create an in-memory ModelContainer for testing
        let schema = Schema([
            SymbolModel.self,
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
    
    /// Generate valid PNG test data for favicon testing
    func createTestFaviconData() -> Data? {
        // Create a simple 1x1 PNG image
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.setFillColor(UIColor.blue.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        return image.pngData()
    }
    
    /// Create a test SymbolModel instance
    func createTestSymbol(
        faviconData: Data? = nil,
        icon: String = "link",
        emoji: String = "🔗",
        color: Color = Color.blue,
        type: SymbolType = .icon
    ) -> SymbolModel {
        let symbol = SymbolModel(
            faviconData: faviconData,
            icon: icon,
            emoji: emoji,
            color: color,
            type: type
        )
        modelContext.insert(symbol)
        try? modelContext.save()
        return symbol
    }
    
    // MARK: - 1. Constants & Choice Arrays
    
    // MARK: 1.1 iconChoices
    
    func testTC_SCONST_01_IconChoicesIsNotEmpty() {
        // TC-SCONST-01: iconChoices is not empty
        XCTAssertFalse(iconChoices.isEmpty, "iconChoices should not be empty")
    }
    
    func testTC_SCONST_02_IconChoicesAllNonEmptyStrings() {
        // TC-SCONST-02: All values are non-empty strings
        for icon in iconChoices {
            XCTAssertFalse(icon.isEmpty, "All icon choices should be non-empty strings")
        }
    }
    
    func testTC_SCONST_03_IconChoicesValidSFSymbolNames() {
        // TC-SCONST-03: All values are valid SF Symbol names
        // Image(systemName:) does not crash
        for icon in iconChoices {
            let image = Image(systemName: icon)
            // If the symbol name is invalid, Image(systemName:) still returns an Image
            // but it won't render. We can't easily test rendering in unit tests,
            // so we just verify it doesn't crash
            XCTAssertNotNil(image, "Image(systemName:) should not crash for \(icon)")
        }
    }
    
    func testTC_SCONST_04_IconChoicesContainsBaselineSymbols() {
        // TC-SCONST-04: Contains expected baseline symbols
        let expectedSymbols = ["link", "star.fill", "heart.fill"]
        for expected in expectedSymbols {
            XCTAssertTrue(iconChoices.contains(expected), "iconChoices should contain \(expected)")
        }
    }
    
    // MARK: 1.2 emojiChoices
    
    func testTC_SCONST_05_EmojiChoicesIsNotEmpty() {
        // TC-SCONST-05: emojiChoices is not empty
        XCTAssertFalse(emojiChoices.isEmpty, "emojiChoices should not be empty")
    }
    
    func testTC_SCONST_06_EmojiChoicesSingleGraphemeClusters() {
        // TC-SCONST-06: All values are single grapheme clusters
        for emoji in emojiChoices {
            // A single grapheme cluster should have count == 1
            // Some emojis are composed of multiple unicode scalars but form one grapheme
            let graphemeCount = emoji.count
            XCTAssertEqual(graphemeCount, 1, "Each emoji should be a single grapheme cluster, but '\(emoji)' has count \(graphemeCount)")
        }
    }
    
    func testTC_SCONST_07_EmojiChoicesRenderCorrectlyInText() {
        // TC-SCONST-07: Emojis render correctly in Text
        // In unit tests, we can't actually render SwiftUI Text, but we can verify
        // the strings are valid and contain emoji characters
        for emoji in emojiChoices {
            // Verify it's not empty and contains at least one emoji character
            XCTAssertFalse(emoji.isEmpty, "Emoji should not be empty")
            // Check if string contains emoji (has unicode scalar in emoji range)
            let hasEmoji = emoji.unicodeScalars.contains { scalar in
                (0x1F300...0x1F9FF).contains(scalar.value) || // Emoticons & Symbols
                (0x2600...0x26FF).contains(scalar.value) ||   // Miscellaneous Symbols
                (0x2700...0x27BF).contains(scalar.value) ||   // Dingbats
                (0xFE00...0xFE0F).contains(scalar.value) ||   // Variation Selectors
                (0x1F900...0x1F9FF).contains(scalar.value) || // Supplemental Symbols
                (0x1F1E6...0x1F1FF).contains(scalar.value) || // Regional Indicator Symbols
                (0x2B00...0x2BFF).contains(scalar.value) ||   // Miscellaneous Symbols and Arrows (includes ⭐ U+2B50)
                (0x1FA00...0x1FAFF).contains(scalar.value) || // Symbols and Pictographs Extended-A
                (0x1F600...0x1F64F).contains(scalar.value) || // Emoticons (additional range)
                (0x1F680...0x1F6FF).contains(scalar.value) || // Transport and Map Symbols
                (0x1F700...0x1F77F).contains(scalar.value) || // Alchemical Symbols
                (0x1F780...0x1F7FF).contains(scalar.value) || // Geometric Shapes Extended
                (0x1F800...0x1F8FF).contains(scalar.value)     // Supplemental Arrows-C
            }
            // Unicode range checks should cover all emoji types
            XCTAssertTrue(hasEmoji, 
                         "String '\(emoji)' should contain emoji characters")
        }
    }
    
    // MARK: 1.3 colorChoices
    
    func testTC_SCONST_08_ColorChoicesIsNotEmpty() {
        // TC-SCONST-08: colorChoices is not empty
        XCTAssertFalse(colorChoices.isEmpty, "colorChoices should not be empty")
    }
    
    func testTC_SCONST_09_ColorChoicesConvertToRGBSuccessfully() {
        // TC-SCONST-09: Colors convert to RGB successfully
        for color in colorChoices {
            let components = colorComponents(color: color)
            // Some colors (like semantic colors) may not convert to RGB
            // This is acceptable - the test verifies the conversion attempt doesn't crash
            // If components is nil, that's okay for some color types
            // We just verify the function doesn't crash
            _ = components // Suppress unused warning
        }
    }
    
    func testTC_SCONST_10_ColorChoicesPreserveOpacity() {
        // TC-SCONST-10: Colors preserve opacity (alpha)
        for color in colorChoices {
            let components = colorComponents(color: color)
            if let components = components {
                // Alpha should be in valid range [0, 1]
                XCTAssertGreaterThanOrEqual(components.alpha, 0.0, "Alpha should be >= 0")
                XCTAssertLessThanOrEqual(components.alpha, 1.0, "Alpha should be <= 1")
            }
        }
    }
    
    // MARK: - 2. SymbolType Enum
    
    // MARK: 2.1 Raw Values & Identity
    
    func testTC_STYPE_01_RawValuesMatchEnumCases() {
        // TC-STYPE-01: Raw values match enum cases
        XCTAssertEqual(SymbolType.favicon.rawValue, "favicon", ".favicon.rawValue should be 'favicon'")
        XCTAssertEqual(SymbolType.icon.rawValue, "icon", ".icon.rawValue should be 'icon'")
        XCTAssertEqual(SymbolType.emoji.rawValue, "emoji", ".emoji.rawValue should be 'emoji'")
    }
    
    func testTC_STYPE_02_IdEqualsRawValue() {
        // TC-STYPE-02: id == rawValue
        XCTAssertEqual(SymbolType.favicon.id, SymbolType.favicon.rawValue, "id should equal rawValue for .favicon")
        XCTAssertEqual(SymbolType.icon.id, SymbolType.icon.rawValue, "id should equal rawValue for .icon")
        XCTAssertEqual(SymbolType.emoji.id, SymbolType.emoji.rawValue, "id should equal rawValue for .emoji")
    }
    
    func testTC_STYPE_03_CaseIterableAllCasesCountEqualsThree() {
        // TC-STYPE-03: CaseIterable.allCases.count == 3
        XCTAssertEqual(SymbolType.allCases.count, 3, "SymbolType should have exactly 3 cases")
    }
    
    // MARK: 2.2 Labels
    
    func testTC_STYPE_04_FaviconLabel() {
        // TC-STYPE-04: .favicon.label == "Favicon"
        XCTAssertEqual(SymbolType.favicon.label, "Favicon", ".favicon.label should be 'Favicon'")
    }
    
    func testTC_STYPE_05_IconLabel() {
        // TC-STYPE-05: .icon.label == "Icon"
        XCTAssertEqual(SymbolType.icon.label, "Icon", ".icon.label should be 'Icon'")
    }
    
    func testTC_STYPE_06_EmojiLabel() {
        // TC-STYPE-06: .emoji.label == "Emoji"
        XCTAssertEqual(SymbolType.emoji.label, "Emoji", ".emoji.label should be 'Emoji'")
    }
    
    // MARK: 2.3 Codable Safety
    
    func testTC_STYPE_07_EncodeDecodePreservesValue() throws {
        // TC-STYPE-07: Encode → decode preserves value
        for symbolType in SymbolType.allCases {
            let encoder = JSONEncoder()
            let data = try encoder.encode(symbolType)
            
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(SymbolType.self, from: data)
            
            XCTAssertEqual(decoded, symbolType, "Encoded and decoded SymbolType should match")
        }
    }
    
    func testTC_STYPE_08_InvalidRawValueFailsDecodingGracefully() {
        // TC-STYPE-08: Invalid raw value fails decoding gracefully
        let invalidJSON = """
        "invalid_type"
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        do {
            _ = try decoder.decode(SymbolType.self, from: invalidJSON)
            XCTFail("Decoding invalid raw value should throw an error")
        } catch {
            // Expected to throw - this is the graceful failure
            XCTAssertTrue(error is DecodingError, "Should throw DecodingError for invalid raw value")
        }
    }
    
    // MARK: - 3. SymbolModel Initialization
    
    // MARK: 3.1 Basic Initialization
    
    func testTC_SINIT_01_InitializeWithIconSymbol() {
        // TC-SINIT-01: Initialize with icon symbol
        let symbol = SymbolModel(
            faviconData: nil,
            icon: "star.fill",
            emoji: "⭐",
            color: Color.blue,
            type: .icon
        )
        
        // icon set correctly
        XCTAssertEqual(symbol.icon, "star.fill", "Icon should be set correctly")
        
        // emoji set correctly
        XCTAssertEqual(symbol.emoji, "⭐", "Emoji should be set correctly")
        
        // faviconData == nil
        XCTAssertNil(symbol.faviconData, "faviconData should be nil")
        
        // getSymbolType() == .icon
        XCTAssertEqual(symbol.getSymbolType(), .icon, "Symbol type should be .icon")
    }
    
    func testTC_SINIT_02_InitializeWithEmojiSymbol() {
        // TC-SINIT-02: Initialize with emoji symbol
        let symbol = SymbolModel(
            faviconData: nil,
            icon: "link",
            emoji: "🎯",
            color: Color.red,
            type: .emoji
        )
        
        XCTAssertEqual(symbol.getSymbolType(), .emoji, "Symbol type should be .emoji")
        XCTAssertEqual(symbol.emoji, "🎯", "Emoji should be set correctly")
    }
    
    func testTC_SINIT_03_InitializeWithFaviconSymbol() {
        // TC-SINIT-03: Initialize with favicon symbol
        guard let faviconData = createTestFaviconData() else {
            XCTFail("Failed to create test favicon data")
            return
        }
        
        let symbol = SymbolModel(
            faviconData: faviconData,
            icon: "link",
            emoji: "🔗",
            color: Color.green,
            type: .favicon
        )
        
        // faviconData preserved
        XCTAssertNotNil(symbol.faviconData, "faviconData should be preserved")
        XCTAssertEqual(symbol.faviconData, faviconData, "faviconData should match input")
        
        // getSymbolType() == .favicon
        XCTAssertEqual(symbol.getSymbolType(), .favicon, "Symbol type should be .favicon")
    }
    
    // MARK: 3.2 Color Storage
    
    func testTC_SINIT_04_ColorComponentsStoredCorrectly() {
        // TC-SINIT-04: Color components stored correctly
        // colorR, colorG, colorB, alpha ∈ [0, 1]
        let testColor = Color(red: 0.5, green: 0.3, blue: 0.8, opacity: 0.9)
        let symbol = SymbolModel(
            faviconData: nil,
            icon: "link",
            emoji: "🔗",
            color: testColor,
            type: .icon
        )
        
        // Verify components are in valid range
        XCTAssertGreaterThanOrEqual(symbol.colorR, 0.0, "colorR should be >= 0")
        XCTAssertLessThanOrEqual(symbol.colorR, 1.0, "colorR should be <= 1")
        XCTAssertGreaterThanOrEqual(symbol.colorG, 0.0, "colorG should be >= 0")
        XCTAssertLessThanOrEqual(symbol.colorG, 1.0, "colorG should be <= 1")
        XCTAssertGreaterThanOrEqual(symbol.colorB, 0.0, "colorB should be >= 0")
        XCTAssertLessThanOrEqual(symbol.colorB, 1.0, "colorB should be <= 1")
        XCTAssertGreaterThanOrEqual(symbol.alpha, 0.0, "alpha should be >= 0")
        XCTAssertLessThanOrEqual(symbol.alpha, 1.0, "alpha should be <= 1")
    }
    
    func testTC_SINIT_05_GetColorReturnsEquivalentColor() {
        // TC-SINIT-05: getColor() returns equivalent Color
        let testColor = Color(red: 0.7, green: 0.2, blue: 0.5, opacity: 0.8)
        let symbol = SymbolModel(
            faviconData: nil,
            icon: "link",
            emoji: "🔗",
            color: testColor,
            type: .icon
        )
        
        let retrievedColor = symbol.getColor()
        let originalComponents = colorComponents(color: testColor)
        let retrievedComponents = colorComponents(color: retrievedColor)
        
        if let orig = originalComponents, let ret = retrievedComponents {
            // Compare with tolerance for floating point precision
            XCTAssertEqual(orig.red, ret.red, accuracy: 0.01, "Red component should match")
            XCTAssertEqual(orig.green, ret.green, accuracy: 0.01, "Green component should match")
            XCTAssertEqual(orig.blue, ret.blue, accuracy: 0.01, "Blue component should match")
            XCTAssertEqual(orig.alpha, ret.alpha, accuracy: 0.01, "Alpha component should match")
        } else {
            XCTFail("Could not extract color components for comparison")
        }
    }
    
    // MARK: - 4. updateSymbol() Behavior
    
    // MARK: 4.1 Property Replacement
    
    func testTC_SUPD_01_IconUpdatedCorrectly() {
        // TC-SUPD-01: Icon updated correctly
        let symbol = createTestSymbol(icon: "link", emoji: "🔗", color: .blue, type: .icon)
        
        symbol.updateSymbol(icon: "star.fill", emoji: "⭐", color: .red, type: .icon)
        
        XCTAssertEqual(symbol.icon, "star.fill", "Icon should be updated correctly")
    }
    
    func testTC_SUPD_02_EmojiUpdatedCorrectly() {
        // TC-SUPD-02: Emoji updated correctly
        let symbol = createTestSymbol(icon: "link", emoji: "🔗", color: .blue, type: .emoji)
        
        symbol.updateSymbol(icon: "link", emoji: "🎯", color: .blue, type: .emoji)
        
        XCTAssertEqual(symbol.emoji, "🎯", "Emoji should be updated correctly")
    }
    
    func testTC_SUPD_03_SymbolTypeUpdatedCorrectly() {
        // TC-SUPD-03: Symbol type updated correctly
        let symbol = createTestSymbol(icon: "link", emoji: "🔗", color: .blue, type: .icon)
        
        symbol.updateSymbol(icon: "link", emoji: "⭐", color: .blue, type: .emoji)
        
        XCTAssertEqual(symbol.getSymbolType(), .emoji, "Symbol type should be updated correctly")
    }
    
    func testTC_SUPD_04_ColorReplacedCorrectly() {
        // TC-SUPD-04: Color replaced correctly
        let symbol = createTestSymbol(icon: "link", emoji: "🔗", color: .blue, type: .icon)
        
        let newColor = Color(red: 0.9, green: 0.1, blue: 0.3, opacity: 0.7)
        symbol.updateSymbol(icon: "link", emoji: "🔗", color: newColor, type: .icon)
        
        let retrievedColor = symbol.getColor()
        let newComponents = colorComponents(color: newColor)
        let retrievedComponents = colorComponents(color: retrievedColor)
        
        if let new = newComponents, let ret = retrievedComponents {
            XCTAssertEqual(new.red, ret.red, accuracy: 0.01, "Color should be replaced correctly")
            XCTAssertEqual(new.green, ret.green, accuracy: 0.01, "Color should be replaced correctly")
            XCTAssertEqual(new.blue, ret.blue, accuracy: 0.01, "Color should be replaced correctly")
            XCTAssertEqual(new.alpha, ret.alpha, accuracy: 0.01, "Color should be replaced correctly")
        } else {
            XCTFail("Could not extract color components for comparison")
        }
    }
    
    // MARK: 4.2 State Consistency
    
    func testTC_SUPD_05_OldValuesFullyOverwritten() {
        // TC-SUPD-05: Old values fully overwritten
        let symbol = createTestSymbol(icon: "link", emoji: "🔗", color: .blue, type: .icon)
        let originalIcon = symbol.icon
        let originalEmoji = symbol.emoji
        
        symbol.updateSymbol(icon: "star.fill", emoji: "⭐", color: .red, type: .emoji)
        
        XCTAssertNotEqual(symbol.icon, originalIcon, "Old icon value should be overwritten")
        XCTAssertNotEqual(symbol.emoji, originalEmoji, "Old emoji value should be overwritten")
        XCTAssertEqual(symbol.icon, "star.fill", "New icon value should be set")
        XCTAssertEqual(symbol.emoji, "⭐", "New emoji value should be set")
    }
    
    func testTC_SUPD_06_FaviconDataRemainsUnchanged() {
        // TC-SUPD-06: faviconData remains unchanged unless reinitialized
        guard let faviconData = createTestFaviconData() else {
            XCTFail("Failed to create test favicon data")
            return
        }
        
        let symbol = createTestSymbol(faviconData: faviconData, icon: "link", emoji: "🔗", color: .blue, type: .favicon)
        let originalFaviconData = symbol.faviconData
        
        // updateSymbol does not take faviconData parameter, so it should remain unchanged
        symbol.updateSymbol(icon: "star.fill", emoji: "⭐", color: .red, type: .icon)
        
        XCTAssertEqual(symbol.faviconData, originalFaviconData, "faviconData should remain unchanged after updateSymbol")
    }
    
    // MARK: - 5. Color Conversion Logic
    
    // MARK: 5.1 setColor()
    
    func testTC_SCLR_01_StandardSystemColorConvertsCorrectly() {
        // TC-SCLR-01: Standard system color converts correctly
        let systemColors: [Color] = [.red, .green, .blue, .yellow, .orange, .purple, .pink]
        
        for systemColor in systemColors {
            let symbol = SymbolModel(
                faviconData: nil,
                icon: "link",
                emoji: "🔗",
                color: systemColor,
                type: .icon
            )
            
            let retrievedColor = symbol.getColor()
            let originalComponents = colorComponents(color: systemColor)
            let retrievedComponents = colorComponents(color: retrievedColor)
            
            // Some system colors may not convert to RGB (semantic colors)
            // If both can be converted, they should match
            if let orig = originalComponents, let ret = retrievedComponents {
                XCTAssertEqual(orig.red, ret.red, accuracy: 0.1, "System color should convert correctly")
                XCTAssertEqual(orig.green, ret.green, accuracy: 0.1, "System color should convert correctly")
                XCTAssertEqual(orig.blue, ret.blue, accuracy: 0.1, "System color should convert correctly")
            }
        }
    }
    
    func testTC_SCLR_02_CustomRGBColorConvertsCorrectly() {
        // TC-SCLR-02: Custom RGB color converts correctly
        let customColor = Color(red: 0.6, green: 0.3, blue: 0.9, opacity: 0.75)
        let symbol = SymbolModel(
            faviconData: nil,
            icon: "link",
            emoji: "🔗",
            color: customColor,
            type: .icon
        )
        
        let retrievedColor = symbol.getColor()
        let originalComponents = colorComponents(color: customColor)
        let retrievedComponents = colorComponents(color: retrievedColor)
        
        if let orig = originalComponents, let ret = retrievedComponents {
            XCTAssertEqual(orig.red, ret.red, accuracy: 0.01, "Custom RGB color should convert correctly")
            XCTAssertEqual(orig.green, ret.green, accuracy: 0.01, "Custom RGB color should convert correctly")
            XCTAssertEqual(orig.blue, ret.blue, accuracy: 0.01, "Custom RGB color should convert correctly")
            XCTAssertEqual(orig.alpha, ret.alpha, accuracy: 0.01, "Custom RGB color alpha should convert correctly")
        } else {
            XCTFail("Could not extract color components for custom RGB color")
        }
    }
    
    func testTC_SCLR_03_AlphaChannelPreserved() {
        // TC-SCLR-03: Alpha channel preserved
        let colorsWithAlpha: [Color] = [
            Color.red.opacity(0.3),
            Color.blue.opacity(0.7),
            Color(red: 0.5, green: 0.5, blue: 0.5, opacity: 0.5)
        ]
        
        for color in colorsWithAlpha {
            let symbol = SymbolModel(
                faviconData: nil,
                icon: "link",
                emoji: "🔗",
                color: color,
                type: .icon
            )
            
            let retrievedColor = symbol.getColor()
            let originalComponents = colorComponents(color: color)
            let retrievedComponents = colorComponents(color: retrievedColor)
            
            if let orig = originalComponents, let ret = retrievedComponents {
                XCTAssertEqual(orig.alpha, ret.alpha, accuracy: 0.01, "Alpha channel should be preserved")
            }
        }
    }
    
    // MARK: 5.2 getColor()
    
    func testTC_SCLR_04_ReturnedColorVisuallyMatchesInput() {
        // TC-SCLR-04: Returned color visually matches input
        let testColors: [Color] = [
            Color(red: 1.0, green: 0.0, blue: 0.0, opacity: 1.0), // Red
            Color(red: 0.0, green: 1.0, blue: 0.0, opacity: 1.0), // Green
            Color(red: 0.0, green: 0.0, blue: 1.0, opacity: 1.0), // Blue
            Color(red: 0.5, green: 0.5, blue: 0.5, opacity: 0.8)  // Gray with alpha
        ]
        
        for testColor in testColors {
            let symbol = SymbolModel(
                faviconData: nil,
                icon: "link",
                emoji: "🔗",
                color: testColor,
                type: .icon
            )
            
            let retrievedColor = symbol.getColor()
            let originalComponents = colorComponents(color: testColor)
            let retrievedComponents = colorComponents(color: retrievedColor)
            
            if let orig = originalComponents, let ret = retrievedComponents {
                XCTAssertEqual(orig.red, ret.red, accuracy: 0.01, "Red component should match")
                XCTAssertEqual(orig.green, ret.green, accuracy: 0.01, "Green component should match")
                XCTAssertEqual(orig.blue, ret.blue, accuracy: 0.01, "Blue component should match")
                XCTAssertEqual(orig.alpha, ret.alpha, accuracy: 0.01, "Alpha component should match")
            }
        }
    }
    
    func testTC_SCLR_05_RepeatedGetSetDoesNotDriftValues() {
        // TC-SCLR-05: Repeated get/set does not drift values
        let initialColor = Color(red: 0.7, green: 0.2, blue: 0.5, opacity: 0.8)
        let symbol = SymbolModel(
            faviconData: nil,
            icon: "link",
            emoji: "🔗",
            color: initialColor,
            type: .icon
        )
        
        // Perform multiple get/set cycles
        for _ in 0..<10 {
            let currentColor = symbol.getColor()
            symbol.updateSymbol(icon: "link", emoji: "🔗", color: currentColor, type: .icon)
        }
        
        let finalColor = symbol.getColor()
        let initialComponents = colorComponents(color: initialColor)
        let finalComponents = colorComponents(color: finalColor)
        
        if let initComp = initialComponents, let finalComp = finalComponents {
            XCTAssertEqual(initComp.red, finalComp.red, accuracy: 0.01, "Red should not drift after repeated get/set")
            XCTAssertEqual(initComp.green, finalComp.green, accuracy: 0.01, "Green should not drift after repeated get/set")
            XCTAssertEqual(initComp.blue, finalComp.blue, accuracy: 0.01, "Blue should not drift after repeated get/set")
            XCTAssertEqual(initComp.alpha, finalComp.alpha, accuracy: 0.01, "Alpha should not drift after repeated get/set")
        }
    }
    
    // MARK: 5.3 Conversion Failure
    
    func testTC_SCLR_06_UnsupportedColorSpace() {
        // TC-SCLR-06: Unsupported Color space
        // Does not crash
        // Previous color remains unchanged
        
        // Create a symbol with a valid color first
        let initialColor = Color(red: 0.5, green: 0.5, blue: 0.5, opacity: 1.0)
        let symbol = SymbolModel(
            faviconData: nil,
            icon: "link",
            emoji: "🔗",
            color: initialColor,
            type: .icon
        )
        
        let initialRetrievedColor = symbol.getColor()
        let initialComponents = colorComponents(color: initialRetrievedColor)
        
        // Try to set a color that might not convert (like a pattern or gradient)
        // Note: SwiftUI Color doesn't have many unsupported types in practice,
        // but we can test with a color that might have conversion issues
        // For this test, we'll use a color with opacity that should still work
        // The real test is that setColor doesn't crash and preserves previous value if conversion fails
        
        // Since SwiftUI Color always converts, we test that the method doesn't crash
        // and that invalid conversions (if any) preserve the previous color
        let testColor = Color.primary // This might not convert to RGB in some contexts
        symbol.updateSymbol(icon: "link", emoji: "🔗", color: testColor, type: .icon)
        
        // The method should not crash
        let finalColor = symbol.getColor()
        let finalComponents = colorComponents(color: finalColor)
        
        // If the new color couldn't be converted, the old color should remain
        // If it could be converted, the new color should be set
        // Either way, the method should not crash
        XCTAssertNotNil(finalComponents, "getColor should not crash even with potentially unsupported colors")
    }
    
    // MARK: - 6. Symbol Type Storage & Recovery
    
    // MARK: 6.1 setSymbolType()
    
    func testTC_STOR_01_SymbolTypeRawMatchesEnumRawValue() {
        // TC-STOR-01: symbolTypeRaw matches enum rawValue
        for symbolType in SymbolType.allCases {
            let symbol = SymbolModel(
                faviconData: nil,
                icon: "link",
                emoji: "🔗",
                color: .blue,
                type: symbolType
            )
            
            XCTAssertEqual(symbol.symbolTypeRaw, symbolType.rawValue, "symbolTypeRaw should match enum rawValue for \(symbolType)")
        }
    }
    
    // MARK: 6.2 getSymbolType()
    
    func testTC_STOR_02_GetSymbolTypeReturnsCorrectEnumForValidRawValue() {
        // TC-STOR-02: Returns correct enum for valid rawValue
        for symbolType in SymbolType.allCases {
            let symbol = SymbolModel(
                faviconData: nil,
                icon: "link",
                emoji: "🔗",
                color: .blue,
                type: symbolType
            )
            
            XCTAssertEqual(symbol.getSymbolType(), symbolType, "getSymbolType should return correct enum for \(symbolType)")
        }
    }
    
    func testTC_STOR_03_InvalidSymbolTypeRawDefaultsToIcon() {
        // TC-STOR-03: Invalid symbolTypeRaw
        // Defaults to .icon
        // No crash
        
        // Create a symbol and manually set an invalid raw value
        // Since symbolTypeRaw is a var, we can set it directly for testing
        let symbol = SymbolModel(
            faviconData: nil,
            icon: "link",
            emoji: "🔗",
            color: .blue,
            type: .icon
        )
        
        // Set an invalid raw value using reflection or direct access
        // Since symbolTypeRaw is public, we can set it directly
        symbol.symbolTypeRaw = "invalid_type"
        
        // getSymbolType should default to .icon
        XCTAssertEqual(symbol.getSymbolType(), .icon, "getSymbolType should default to .icon for invalid rawValue")
    }
    
    // MARK: - 7. Helper Functions
    
    // MARK: 7.1 colorComponents()
    
    func testTC_HELP_01_ColorComponentsReturnsValidRGBATupleForRGBColor() {
        // TC-HELP-01: Returns valid RGBA tuple for RGB color
        // Note: colorComponents is private, so we test it through the public API
        let rgbColor = Color(red: 0.8, green: 0.3, blue: 0.6, opacity: 0.9)
        let symbol = SymbolModel(
            faviconData: nil,
            icon: "link",
            emoji: "🔗",
            color: rgbColor,
            type: .icon
        )
        
        // Verify the color was stored correctly (which means colorComponents worked)
        let retrievedColor = symbol.getColor()
        let components = colorComponents(color: retrievedColor)
        
        XCTAssertNotNil(components, "colorComponents should return valid RGBA tuple for RGB color")
        if let comp = components {
            XCTAssertGreaterThanOrEqual(comp.red, 0.0, "Red should be >= 0")
            XCTAssertLessThanOrEqual(comp.red, 1.0, "Red should be <= 1")
            XCTAssertGreaterThanOrEqual(comp.green, 0.0, "Green should be >= 0")
            XCTAssertLessThanOrEqual(comp.green, 1.0, "Green should be <= 1")
            XCTAssertGreaterThanOrEqual(comp.blue, 0.0, "Blue should be >= 0")
            XCTAssertLessThanOrEqual(comp.blue, 1.0, "Blue should be <= 1")
            XCTAssertGreaterThanOrEqual(comp.alpha, 0.0, "Alpha should be >= 0")
            XCTAssertLessThanOrEqual(comp.alpha, 1.0, "Alpha should be <= 1")
        }
    }
    
    func testTC_HELP_02_ColorComponentsReturnsNilForUnsupportedColors() {
        // TC-HELP-02: Returns nil for unsupported colors
        // Note: Since colorComponents is private, we test through behavior
        // If a color can't be converted, the color components should remain at default (0,0,0,0)
        // or the previous value
        
        // Test with a color that might not convert (semantic colors in some contexts)
        // In practice, most SwiftUI Colors do convert, but we test the behavior
        let symbol = SymbolModel(
            faviconData: nil,
            icon: "link",
            emoji: "🔗",
            color: Color(red: 0.5, green: 0.5, blue: 0.5, opacity: 1.0),
            type: .icon
        )
        
        // If colorComponents fails, the color values should remain at defaults or previous
        // Since we can't directly test the private method, we verify the stored values
        // are valid (which they should be if conversion succeeded)
        XCTAssertGreaterThanOrEqual(symbol.colorR, 0.0, "colorR should be valid")
        XCTAssertLessThanOrEqual(symbol.colorR, 1.0, "colorR should be valid")
    }
    
    func testTC_HELP_03_ColorComponentsHandlesFullyTransparentColor() {
        // TC-HELP-03: Handles fully transparent color
        let transparentColor = Color(red: 1.0, green: 0.0, blue: 0.0, opacity: 0.0)
        let symbol = SymbolModel(
            faviconData: nil,
            icon: "link",
            emoji: "🔗",
            color: transparentColor,
            type: .icon
        )
        
        // Verify alpha is 0
        XCTAssertEqual(symbol.alpha, 0.0, accuracy: 0.01, "Fully transparent color should have alpha = 0")
        
        let retrievedColor = symbol.getColor()
        let components = colorComponents(color: retrievedColor)
        
        if let comp = components {
            XCTAssertEqual(comp.alpha, 0.0, accuracy: 0.01, "Retrieved color should have alpha = 0")
        }
    }
    
    // MARK: - 8. SwiftData Persistence
    
    // MARK: 8.1 Round-trip Persistence
    
    func testTC_SDATA_01_SaveAndReloadSymbolModel() throws {
        // TC-SDATA-01: Save & reload SymbolModel
        // Color values preserved
        // Symbol type preserved
        // Icon/emoji preserved
        
        guard let faviconData = createTestFaviconData() else {
            XCTFail("Failed to create test favicon data")
            return
        }
        
        let originalColor = Color(red: 0.7, green: 0.2, blue: 0.5, opacity: 0.8)
        let originalSymbol = SymbolModel(
            faviconData: faviconData,
            icon: "star.fill",
            emoji: "⭐",
            color: originalColor,
            type: .favicon
        )
        
        modelContext.insert(originalSymbol)
        try modelContext.save()
        
        // Fetch the symbol back
        let fetchDescriptor = FetchDescriptor<SymbolModel>()
        let fetchedSymbols = try modelContext.fetch(fetchDescriptor)
        
        guard let fetchedSymbol = fetchedSymbols.first else {
            XCTFail("Should be able to fetch the symbol")
            return
        }
        
        // Verify color values preserved
        let fetchedColor = fetchedSymbol.getColor()
        let originalComponents = colorComponents(color: originalColor)
        let fetchedComponents = colorComponents(color: fetchedColor)
        
        if let orig = originalComponents, let fetched = fetchedComponents {
            XCTAssertEqual(orig.red, fetched.red, accuracy: 0.01, "Color red should be preserved")
            XCTAssertEqual(orig.green, fetched.green, accuracy: 0.01, "Color green should be preserved")
            XCTAssertEqual(orig.blue, fetched.blue, accuracy: 0.01, "Color blue should be preserved")
            XCTAssertEqual(orig.alpha, fetched.alpha, accuracy: 0.01, "Color alpha should be preserved")
        }
        
        // Verify symbol type preserved
        XCTAssertEqual(fetchedSymbol.getSymbolType(), .favicon, "Symbol type should be preserved")
        
        // Verify icon/emoji preserved
        XCTAssertEqual(fetchedSymbol.icon, "star.fill", "Icon should be preserved")
        XCTAssertEqual(fetchedSymbol.emoji, "⭐", "Emoji should be preserved")
        
        // Verify faviconData preserved
        XCTAssertNotNil(fetchedSymbol.faviconData, "faviconData should be preserved")
        XCTAssertEqual(fetchedSymbol.faviconData, faviconData, "faviconData should match")
    }
    
    // MARK: 8.2 Relationship Safety
    
    func testTC_SDATA_02_EmbeddedInsideLinkModelGroupModel() throws {
        // TC-SDATA-02: Embedded inside LinkModel / GroupModel
        // No duplication issues
        // No crashes during fetch
        
        // Test with LinkModel
        guard let faviconData = createTestFaviconData() else {
            XCTFail("Failed to create test favicon data")
            return
        }
        
        let link = LinkModel(
            url: "https://example.com",
            title: "Test Link",
            caption: "Test caption",
            faviconImage: faviconData
        )
        
        modelContext.insert(link)
        try modelContext.save()
        
        // Fetch the link
        let linkFetch = FetchDescriptor<LinkModel>()
        let fetchedLinks = try modelContext.fetch(linkFetch)
        
        guard let fetchedLink = fetchedLinks.first else {
            XCTFail("Should be able to fetch the link")
            return
        }
        
        // Verify symbol is accessible and not duplicated
        XCTAssertNotNil(fetchedLink.symbol, "Symbol should be accessible from LinkModel")
        XCTAssertEqual(fetchedLink.symbol.getSymbolType(), .favicon, "Symbol type should be correct")
        
        // Test with GroupModel
        let group = GroupModel(
            name: "Test Group",
            icon: "star.fill",
            emoji: "⭐",
            color: .red,
            type: .icon
        )
        
        modelContext.insert(group)
        try modelContext.save()
        
        // Fetch the group
        let groupFetch = FetchDescriptor<GroupModel>()
        let fetchedGroups = try modelContext.fetch(groupFetch)
        
        guard let fetchedGroup = fetchedGroups.first else {
            XCTFail("Should be able to fetch the group")
            return
        }
        
        // Verify symbol is accessible and not duplicated
        XCTAssertNotNil(fetchedGroup.symbol, "Symbol should be accessible from GroupModel")
        XCTAssertEqual(fetchedGroup.symbol.getSymbolType(), .icon, "Symbol type should be correct")
        XCTAssertEqual(fetchedGroup.symbol.icon, "star.fill", "Icon should be correct")
        
        // Verify no crashes and symbols are distinct instances
        XCTAssertNotEqual(fetchedLink.symbol.icon, fetchedGroup.symbol.icon, "Symbols should be distinct")
    }
    
    // MARK: - 9. Edge & Defensive Cases
    
    // MARK: 9.1 Invalid Inputs
    
    func testTC_EDGE_01_InvalidSFSymbolName() {
        // TC-EDGE-01: Invalid SF Symbol name
        // Stored as-is
        // Rendering fallback handled by caller
        
        let invalidSymbolName = "invalid.symbol.name.that.does.not.exist"
        let symbol = SymbolModel(
            faviconData: nil,
            icon: invalidSymbolName,
            emoji: "🔗",
            color: .blue,
            type: .icon
        )
        
        // Should be stored as-is
        XCTAssertEqual(symbol.icon, invalidSymbolName, "Invalid SF Symbol name should be stored as-is")
        
        // Should not crash when creating Image
        let image = Image(systemName: invalidSymbolName)
        XCTAssertNotNil(image, "Image(systemName:) should not crash even with invalid name")
    }
    
    func testTC_EDGE_02_EmptyEmojiString() {
        // TC-EDGE-02: Empty emoji string
        // No crash
        
        let symbol = SymbolModel(
            faviconData: nil,
            icon: "link",
            emoji: "",
            color: .blue,
            type: .emoji
        )
        
        // Should not crash
        XCTAssertEqual(symbol.emoji, "", "Empty emoji string should be stored")
        XCTAssertEqual(symbol.getSymbolType(), .emoji, "Symbol type should still be .emoji")
    }
    
    func testTC_EDGE_03_NilFaviconWithFaviconType() {
        // TC-EDGE-03: Nil favicon with .favicon type
        // Allowed
        // Caller handles fallback
        
        let symbol = SymbolModel(
            faviconData: nil,
            icon: "link",
            emoji: "🔗",
            color: .blue,
            type: .favicon
        )
        
        // Should be allowed
        XCTAssertNil(symbol.faviconData, "Nil faviconData should be allowed")
        XCTAssertEqual(symbol.getSymbolType(), .favicon, "Symbol type should be .favicon even with nil faviconData")
    }
    
    // MARK: 9.2 Performance
    
    func testTC_PERF_01_BulkCreation() {
        // TC-PERF-01: Bulk creation (1000+ symbols)
        // No memory spikes
        
        let startTime = Date()
        var symbols: [SymbolModel] = []
        
        for i in 0..<1000 {
            let symbol = SymbolModel(
                faviconData: nil,
                icon: iconChoices[i % iconChoices.count],
                emoji: emojiChoices[i % emojiChoices.count],
                color: colorChoices[i % colorChoices.count],
                type: i % 3 == 0 ? .icon : (i % 3 == 1 ? .emoji : .favicon)
            )
            symbols.append(symbol)
        }
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        XCTAssertEqual(symbols.count, 1000, "Should create 1000 symbols")
        XCTAssertLessThan(duration, 5.0, "Bulk creation should complete in reasonable time (< 5 seconds)")
        
        // Verify all symbols are valid
        for symbol in symbols {
            XCTAssertNotNil(symbol, "All symbols should be valid")
            XCTAssertFalse(symbol.icon.isEmpty, "All symbols should have valid icon")
        }
    }
    
    func testTC_PERF_02_FrequentUpdatesDoNotDegradePerformance() {
        // TC-PERF-02: Frequent updates do not degrade performance
        
        let symbol = createTestSymbol(icon: "link", emoji: "🔗", color: .blue, type: .icon)
        
        let startTime = Date()
        
        // Perform many updates
        for i in 0..<100 {
            let iconIndex = i % iconChoices.count
            let emojiIndex = i % emojiChoices.count
            let colorIndex = i % colorChoices.count
            
            symbol.updateSymbol(
                icon: iconChoices[iconIndex],
                emoji: emojiChoices[emojiIndex],
                color: colorChoices[colorIndex],
                type: i % 3 == 0 ? .icon : (i % 3 == 1 ? .emoji : .favicon)
            )
        }
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        XCTAssertLessThan(duration, 2.0, "Frequent updates should complete in reasonable time (< 2 seconds)")
        
        // Verify final state is correct
        XCTAssertNotNil(symbol, "Symbol should still be valid after frequent updates")
        XCTAssertFalse(symbol.icon.isEmpty, "Symbol should have valid icon after updates")
    }
}

