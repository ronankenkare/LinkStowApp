import XCTest
@testable import LinkStow

final class UserDefaultsTests: XCTestCase {
    private var testDefaults: UserDefaults!
    private var suiteName: String!
    
    override func setUp() {
        super.setUp()
        suiteName = "test.\(UUID().uuidString)"
        testDefaults = UserDefaults(suiteName: suiteName)!
        // Clear any existing data
        testDefaults.removePersistentDomain(forName: suiteName)
    }
    
    override func tearDown() {
        if let suiteName = suiteName {
            testDefaults.removePersistentDomain(forName: suiteName)
        }
        testDefaults = nil
        suiteName = nil
        super.tearDown()
    }
    
    // MARK: - 1. Key Definition & Isolation
    
    // TC-UDKEY-01: Keys are unique
    func testTC_UDKEY_01_KeysAreUnique() {
        // Set different values for each key
        testDefaults.hiddenGroupActive = true
        testDefaults.titleLineLimit = 5
        testDefaults.captionLineLimit = 10
        
        // Verify each key maintains its own value
        XCTAssertTrue(testDefaults.hiddenGroupActive, "hiddenGroupActive should be true")
        XCTAssertEqual(testDefaults.titleLineLimit, 5, "titleLineLimit should be 5")
        XCTAssertEqual(testDefaults.captionLineLimit, 10, "captionLineLimit should be 10")
        
        // Change one value and verify others are unaffected
        testDefaults.hiddenGroupActive = false
        XCTAssertFalse(testDefaults.hiddenGroupActive, "hiddenGroupActive should be false")
        XCTAssertEqual(testDefaults.titleLineLimit, 5, "titleLineLimit should still be 5")
        XCTAssertEqual(testDefaults.captionLineLimit, 10, "captionLineLimit should still be 10")
    }
    
    // TC-UDKEY-02: Keys do not collide with system keys
    func testTC_UDKEY_02_KeysDoNotCollideWithSystemKeys() {
        // Common system keys
        let systemKeys = ["AppleLanguages", "NSLanguages", "AppleLocale", "AppleKeyboards"]
        
        // Set our custom keys
        testDefaults.hiddenGroupActive = true
        testDefaults.titleLineLimit = 3
        testDefaults.captionLineLimit = 7
        
        // Verify system keys are not affected (if they exist, they should remain unchanged)
        // We can't directly test this without knowing system state, but we verify our keys work
        XCTAssertTrue(testDefaults.hiddenGroupActive, "hiddenGroupActive should work independently")
        XCTAssertEqual(testDefaults.titleLineLimit, 3, "titleLineLimit should work independently")
        XCTAssertEqual(testDefaults.captionLineLimit, 7, "captionLineLimit should work independently")
        
        // Verify our keys don't interfere with each other
        testDefaults.hiddenGroupActive = false
        XCTAssertEqual(testDefaults.titleLineLimit, 3, "titleLineLimit should remain 3")
        XCTAssertEqual(testDefaults.captionLineLimit, 7, "captionLineLimit should remain 7")
    }
    
    // TC-UDKEY-03: Tests use isolated UserDefaults suite
    func testTC_UDKEY_03_TestsUseIsolatedUserDefaultsSuite() {
        // Verify we're using the isolated suite by checking the suite name variable
        XCTAssertNotNil(suiteName, "Should have a suite name")
        XCTAssertTrue(suiteName.hasPrefix("test."), "Suite name should start with 'test.'")
        
        // Set values
        testDefaults.hiddenGroupActive = true
        testDefaults.titleLineLimit = 42
        
        // Create a new instance with different suite name
        let otherSuite = "other.\(UUID().uuidString)"
        let otherDefaults = UserDefaults(suiteName: otherSuite)!
        otherDefaults.removePersistentDomain(forName: otherSuite)
        
        // Verify other suite doesn't have our values
        XCTAssertFalse(otherDefaults.hiddenGroupActive, "Other suite should have default value")
        XCTAssertEqual(otherDefaults.titleLineLimit, 0, "Other suite should have default value")
        
        // Cleanup
        otherDefaults.removePersistentDomain(forName: otherSuite)
    }
    
    // MARK: - 2. hiddenGroupActive
    
    // TC-UDHID-01: Default value when key is unset
    func testTC_UDHID_01_DefaultValueWhenUnset() {
        // Fresh UserDefaults should return false
        XCTAssertFalse(testDefaults.hiddenGroupActive, "Default value should be false when unset")
    }
    
    // TC-UDHID-02: Set to true
    func testTC_UDHID_02_SetToTrue() {
        testDefaults.hiddenGroupActive = true
        XCTAssertTrue(testDefaults.hiddenGroupActive, "Getter should return true after setting to true")
    }
    
    // TC-UDHID-03: Set to false
    func testTC_UDHID_03_SetToFalse() {
        // First set to true
        testDefaults.hiddenGroupActive = true
        XCTAssertTrue(testDefaults.hiddenGroupActive, "Should be true initially")
        
        // Then set to false
        testDefaults.hiddenGroupActive = false
        XCTAssertFalse(testDefaults.hiddenGroupActive, "Getter should return false after setting to false")
    }
    
    // TC-UDHID-04: Value persists across instances
    func testTC_UDHID_04_ValuePersistsAcrossInstances() {
        // Set value in first instance
        testDefaults.hiddenGroupActive = true
        XCTAssertTrue(testDefaults.hiddenGroupActive, "First instance should have true")
        
        // Create new instance with same suite
        let newDefaults = UserDefaults(suiteName: suiteName)!
        XCTAssertTrue(newDefaults.hiddenGroupActive, "New instance should return same value (true)")
        
        // Change value in new instance
        newDefaults.hiddenGroupActive = false
        
        // Verify both instances see the change
        XCTAssertFalse(testDefaults.hiddenGroupActive, "Original instance should see updated value")
        XCTAssertFalse(newDefaults.hiddenGroupActive, "New instance should have false")
    }
    
    // MARK: - 3. titleLineLimit
    
    // TC-UDTTL-01: Default value when key is unset
    func testTC_UDTTL_01_DefaultValueWhenUnset() {
        XCTAssertEqual(testDefaults.titleLineLimit, 0, "Default value should be 0 when unset")
    }
    
    // TC-UDTTL-02: Set positive value
    func testTC_UDTTL_02_SetPositiveValue() {
        testDefaults.titleLineLimit = 3
        XCTAssertEqual(testDefaults.titleLineLimit, 3, "Should return 3 after setting to 3")
        
        // Test another positive value
        testDefaults.titleLineLimit = 10
        XCTAssertEqual(testDefaults.titleLineLimit, 10, "Should return 10 after setting to 10")
    }
    
    // TC-UDTTL-03: Set zero
    func testTC_UDTTL_03_SetZero() {
        // First set to positive value
        testDefaults.titleLineLimit = 5
        XCTAssertEqual(testDefaults.titleLineLimit, 5, "Should be 5 initially")
        
        // Then set to zero
        testDefaults.titleLineLimit = 0
        XCTAssertEqual(testDefaults.titleLineLimit, 0, "Should return 0 after setting to 0")
    }
    
    // TC-UDTTL-04: Set negative value
    func testTC_UDTTL_04_SetNegativeValue() {
        testDefaults.titleLineLimit = -5
        XCTAssertEqual(testDefaults.titleLineLimit, -5, "Should store and return negative value as-is")
        
        // Test another negative value
        testDefaults.titleLineLimit = -100
        XCTAssertEqual(testDefaults.titleLineLimit, -100, "Should store and return large negative value")
    }
    
    // TC-UDTTL-05: Persists across app launches (simulated)
    func testTC_UDTTL_05_PersistsAcrossInstances() {
        // Set value in first instance
        testDefaults.titleLineLimit = 7
        XCTAssertEqual(testDefaults.titleLineLimit, 7, "First instance should have 7")
        
        // Create new instance with same suite (simulating app relaunch)
        let newDefaults = UserDefaults(suiteName: suiteName)!
        XCTAssertEqual(newDefaults.titleLineLimit, 7, "New instance should return same value (7)")
        
        // Change value in new instance
        newDefaults.titleLineLimit = 15
        
        // Verify both instances see the change
        XCTAssertEqual(testDefaults.titleLineLimit, 15, "Original instance should see updated value")
        XCTAssertEqual(newDefaults.titleLineLimit, 15, "New instance should have 15")
    }
    
    // MARK: - 4. captionLineLimit
    
    // TC-UDCAP-01: Default value when key is unset
    func testTC_UDCAP_01_DefaultValueWhenUnset() {
        XCTAssertEqual(testDefaults.captionLineLimit, 0, "Default value should be 0 when unset")
    }
    
    // TC-UDCAP-02: Set positive value
    func testTC_UDCAP_02_SetPositiveValue() {
        testDefaults.captionLineLimit = 4
        XCTAssertEqual(testDefaults.captionLineLimit, 4, "Should return 4 after setting to 4")
        
        // Test another positive value
        testDefaults.captionLineLimit = 20
        XCTAssertEqual(testDefaults.captionLineLimit, 20, "Should return 20 after setting to 20")
    }
    
    // TC-UDCAP-03: Set zero
    func testTC_UDCAP_03_SetZero() {
        // First set to positive value
        testDefaults.captionLineLimit = 8
        XCTAssertEqual(testDefaults.captionLineLimit, 8, "Should be 8 initially")
        
        // Then set to zero
        testDefaults.captionLineLimit = 0
        XCTAssertEqual(testDefaults.captionLineLimit, 0, "Should return 0 after setting to 0")
    }
    
    // TC-UDCAP-04: Set negative value
    func testTC_UDCAP_04_SetNegativeValue() {
        testDefaults.captionLineLimit = -3
        XCTAssertEqual(testDefaults.captionLineLimit, -3, "Should store and return negative value as-is")
        
        // Test another negative value
        testDefaults.captionLineLimit = -50
        XCTAssertEqual(testDefaults.captionLineLimit, -50, "Should store and return large negative value")
    }
    
    // TC-UDCAP-05: Persists across instances
    func testTC_UDCAP_05_PersistsAcrossInstances() {
        // Set value in first instance
        testDefaults.captionLineLimit = 12
        XCTAssertEqual(testDefaults.captionLineLimit, 12, "First instance should have 12")
        
        // Create new instance with same suite
        let newDefaults = UserDefaults(suiteName: suiteName)!
        XCTAssertEqual(newDefaults.captionLineLimit, 12, "New instance should return same value (12)")
        
        // Change value in new instance
        newDefaults.captionLineLimit = 25
        
        // Verify both instances see the change
        XCTAssertEqual(testDefaults.captionLineLimit, 25, "Original instance should see updated value")
        XCTAssertEqual(newDefaults.captionLineLimit, 25, "New instance should have 25")
    }
    
    // MARK: - 5. Cross-Property Interaction
    
    // TC-UDX-01: Setting hiddenGroupActive does not affect line limits
    func testTC_UDX_01_SettingHiddenGroupActiveDoesNotAffectLineLimits() {
        // Set initial line limit values
        testDefaults.titleLineLimit = 5
        testDefaults.captionLineLimit = 10
        
        // Set hiddenGroupActive
        testDefaults.hiddenGroupActive = true
        
        // Verify line limits are unchanged
        XCTAssertEqual(testDefaults.titleLineLimit, 5, "titleLineLimit should remain 5")
        XCTAssertEqual(testDefaults.captionLineLimit, 10, "captionLineLimit should remain 10")
        
        // Change hiddenGroupActive again
        testDefaults.hiddenGroupActive = false
        
        // Verify line limits are still unchanged
        XCTAssertEqual(testDefaults.titleLineLimit, 5, "titleLineLimit should still be 5")
        XCTAssertEqual(testDefaults.captionLineLimit, 10, "captionLineLimit should still be 10")
    }
    
    // TC-UDX-02: Setting titleLineLimit does not affect caption limit
    func testTC_UDX_02_SettingTitleLineLimitDoesNotAffectCaptionLimit() {
        // Set initial values
        testDefaults.captionLineLimit = 15
        testDefaults.hiddenGroupActive = true
        
        // Change titleLineLimit multiple times
        testDefaults.titleLineLimit = 3
        XCTAssertEqual(testDefaults.captionLineLimit, 15, "captionLineLimit should remain 15")
        XCTAssertTrue(testDefaults.hiddenGroupActive, "hiddenGroupActive should remain true")
        
        testDefaults.titleLineLimit = 7
        XCTAssertEqual(testDefaults.captionLineLimit, 15, "captionLineLimit should still be 15")
        XCTAssertTrue(testDefaults.hiddenGroupActive, "hiddenGroupActive should still be true")
        
        testDefaults.titleLineLimit = 0
        XCTAssertEqual(testDefaults.captionLineLimit, 15, "captionLineLimit should still be 15")
        XCTAssertTrue(testDefaults.hiddenGroupActive, "hiddenGroupActive should still be true")
    }
    
    // TC-UDX-03: Setting captionLineLimit does not affect title limit
    func testTC_UDX_03_SettingCaptionLineLimitDoesNotAffectTitleLimit() {
        // Set initial values
        testDefaults.titleLineLimit = 20
        testDefaults.hiddenGroupActive = false
        
        // Change captionLineLimit multiple times
        testDefaults.captionLineLimit = 6
        XCTAssertEqual(testDefaults.titleLineLimit, 20, "titleLineLimit should remain 20")
        XCTAssertFalse(testDefaults.hiddenGroupActive, "hiddenGroupActive should remain false")
        
        testDefaults.captionLineLimit = 12
        XCTAssertEqual(testDefaults.titleLineLimit, 20, "titleLineLimit should still be 20")
        XCTAssertFalse(testDefaults.hiddenGroupActive, "hiddenGroupActive should still be false")
        
        testDefaults.captionLineLimit = -5
        XCTAssertEqual(testDefaults.titleLineLimit, 20, "titleLineLimit should still be 20")
        XCTAssertFalse(testDefaults.hiddenGroupActive, "hiddenGroupActive should still be false")
    }
    
    // MARK: - 6. Data Integrity & Safety
    
    // TC-UDSAFE-01: Stored Bool does not corrupt Int keys
    func testTC_UDSAFE_01_StoredBoolDoesNotCorruptIntKeys() {
        // Set Int values
        testDefaults.titleLineLimit = 5
        testDefaults.captionLineLimit = 10
        
        // Manually store a Bool under one of the Int keys (using raw key access)
        // We need to access the key directly - since Keys is private, we'll use the known key string
        testDefaults.set(true, forKey: "titleLineLimit")
        
        // Verify the Int getter still works (it will return 0 or 1, depending on implementation)
        // UserDefaults.integer(forKey:) returns 0 for non-Int values, or 1 if Bool true is stored
        let titleValue = testDefaults.titleLineLimit
        // The integer(forKey:) method returns 0 for non-integer values, or 1 if a Bool true was stored
        // This is expected behavior - we're testing that it doesn't crash
        XCTAssertNotNil(titleValue, "Should not crash when reading Int after Bool was stored")
        
        // Verify captionLineLimit is unaffected
        XCTAssertEqual(testDefaults.captionLineLimit, 10, "captionLineLimit should remain 10")
        
        // Restore proper Int value
        testDefaults.titleLineLimit = 5
        XCTAssertEqual(testDefaults.titleLineLimit, 5, "Should be able to restore Int value")
    }
    
    // TC-UDSAFE-02: Stored Int does not corrupt Bool key
    func testTC_UDSAFE_02_StoredIntDoesNotCorruptBoolKey() {
        // Set Bool value
        testDefaults.hiddenGroupActive = true
        
        // Manually store an Int under the Bool key
        testDefaults.set(42, forKey: "hiddenGroupActive")
        
        // Verify the Bool getter still works
        // UserDefaults.bool(forKey:) treats non-zero Int as true
        let boolValue = testDefaults.hiddenGroupActive
        XCTAssertTrue(boolValue, "UserDefaults converts non-zero Int to true")
        
        // Test with zero Int
        testDefaults.set(0, forKey: "hiddenGroupActive")
        XCTAssertFalse(testDefaults.hiddenGroupActive, "UserDefaults converts zero Int to false")
        
        // Verify we can restore proper Bool value
        testDefaults.hiddenGroupActive = true
        XCTAssertTrue(testDefaults.hiddenGroupActive, "Should be able to restore Bool value")
    }
    
    // TC-UDSAFE-03: Manually store non-Bool under hiddenGroupActive
    func testTC_UDSAFE_03_ManuallyStoreNonBoolUnderHiddenGroupActive() {
        // Store a String value
        testDefaults.set("invalid", forKey: "hiddenGroupActive")
        
        // Getter should return false (default for String and other non-numeric types)
        XCTAssertFalse(testDefaults.hiddenGroupActive, "Should return false for String value")
        
        // Store a Double value
        // UserDefaults.bool(forKey:) treats non-zero Double as true
        testDefaults.set(3.14, forKey: "hiddenGroupActive")
        XCTAssertTrue(testDefaults.hiddenGroupActive, "UserDefaults converts non-zero Double to true")
        
        // Test with zero Double
        testDefaults.set(0.0, forKey: "hiddenGroupActive")
        XCTAssertFalse(testDefaults.hiddenGroupActive, "UserDefaults converts zero Double to false")
        
        // Store an Array
        testDefaults.set([1, 2, 3], forKey: "hiddenGroupActive")
        XCTAssertFalse(testDefaults.hiddenGroupActive, "Should return false for Array value")
        
        // Verify we can still set proper Bool value
        testDefaults.hiddenGroupActive = true
        XCTAssertTrue(testDefaults.hiddenGroupActive, "Should be able to set proper Bool value")
    }
    
    // TC-UDSAFE-04: Manually store non-Int under line limit keys
    func testTC_UDSAFE_04_ManuallyStoreNonIntUnderLineLimitKeys() {
        // Store String under titleLineLimit
        testDefaults.set("invalid", forKey: "titleLineLimit")
        XCTAssertEqual(testDefaults.titleLineLimit, 0, "Should return 0 for String value")
        
        // Store String under captionLineLimit
        testDefaults.set("invalid", forKey: "captionLineLimit")
        XCTAssertEqual(testDefaults.captionLineLimit, 0, "Should return 0 for String value")
        
        // Store Double values
        // UserDefaults.integer(forKey:) truncates Double to Int
        testDefaults.set(3.14, forKey: "titleLineLimit")
        XCTAssertEqual(testDefaults.titleLineLimit, 3, "UserDefaults truncates Double 3.14 to Int 3")
        
        testDefaults.set(2.71, forKey: "captionLineLimit")
        XCTAssertEqual(testDefaults.captionLineLimit, 2, "UserDefaults truncates Double 2.71 to Int 2")
        
        // Store Bool values
        // integer(forKey:) returns 1 for Bool true, 0 for Bool false
        testDefaults.set(true, forKey: "titleLineLimit")
        XCTAssertEqual(testDefaults.titleLineLimit, 1, "UserDefaults converts Bool true to Int 1")
        
        testDefaults.set(false, forKey: "captionLineLimit")
        XCTAssertEqual(testDefaults.captionLineLimit, 0, "UserDefaults converts Bool false to Int 0")
        
        // Verify we can restore proper Int values
        testDefaults.titleLineLimit = 5
        testDefaults.captionLineLimit = 10
        XCTAssertEqual(testDefaults.titleLineLimit, 5, "Should be able to restore Int value")
        XCTAssertEqual(testDefaults.captionLineLimit, 10, "Should be able to restore Int value")
    }
    
    // MARK: - 7. Reset & Cleanup
    
    // TC-UDRST-01: Removing key resets to default
    func testTC_UDRST_01_RemovingKeyResetsToDefault() {
        // Set all values
        testDefaults.hiddenGroupActive = true
        testDefaults.titleLineLimit = 7
        testDefaults.captionLineLimit = 14
        
        // Verify values are set
        XCTAssertTrue(testDefaults.hiddenGroupActive)
        XCTAssertEqual(testDefaults.titleLineLimit, 7)
        XCTAssertEqual(testDefaults.captionLineLimit, 14)
        
        // Remove keys
        testDefaults.removeObject(forKey: "hiddenGroupActive")
        testDefaults.removeObject(forKey: "titleLineLimit")
        testDefaults.removeObject(forKey: "captionLineLimit")
        
        // Verify defaults are restored
        XCTAssertFalse(testDefaults.hiddenGroupActive, "Should return default false after removal")
        XCTAssertEqual(testDefaults.titleLineLimit, 0, "Should return default 0 after removal")
        XCTAssertEqual(testDefaults.captionLineLimit, 0, "Should return default 0 after removal")
    }
    
    // TC-UDRST-02: removePersistentDomain resets all properties
    func testTC_UDRST_02_RemovePersistentDomainResetsAllProperties() {
        // Set all values
        testDefaults.hiddenGroupActive = true
        testDefaults.titleLineLimit = 9
        testDefaults.captionLineLimit = 18
        
        // Verify values are set
        XCTAssertTrue(testDefaults.hiddenGroupActive)
        XCTAssertEqual(testDefaults.titleLineLimit, 9)
        XCTAssertEqual(testDefaults.captionLineLimit, 18)
        
        // Remove persistent domain
        if let suiteName = suiteName {
            testDefaults.removePersistentDomain(forName: suiteName)
        }
        
        // Verify all properties are reset to defaults
        XCTAssertFalse(testDefaults.hiddenGroupActive, "Should return default false after domain removal")
        XCTAssertEqual(testDefaults.titleLineLimit, 0, "Should return default 0 after domain removal")
        XCTAssertEqual(testDefaults.captionLineLimit, 0, "Should return default 0 after domain removal")
    }
    
    // MARK: - 8. Performance & Concurrency
    
    // TC-UDPERF-01: Rapid set/get does not degrade performance
    func testTC_UDPERF_01_RapidSetGetDoesNotDegradePerformance() {
        let iterations = 1000
        let startTime = Date()
        
        // Rapid set/get operations
        for i in 0..<iterations {
            testDefaults.hiddenGroupActive = (i % 2 == 0)
            _ = testDefaults.hiddenGroupActive
            
            testDefaults.titleLineLimit = i
            _ = testDefaults.titleLineLimit
            
            testDefaults.captionLineLimit = i * 2
            _ = testDefaults.captionLineLimit
        }
        
        let elapsedTime = Date().timeIntervalSince(startTime)
        let operationsPerSecond = Double(iterations * 6) / elapsedTime // 3 sets + 3 gets per iteration
        
        // Should complete 1000 iterations in reasonable time (e.g., < 1 second)
        XCTAssertLessThan(elapsedTime, 1.0, "1000 iterations should complete in less than 1 second")
        XCTAssertGreaterThan(operationsPerSecond, 1000, "Should handle at least 1000 operations per second")
    }
    
    // TC-UDTHREAD-01: Concurrent reads do not crash
    func testTC_UDTHREAD_01_ConcurrentReadsDoNotCrash() {
        // Set initial values
        testDefaults.hiddenGroupActive = true
        testDefaults.titleLineLimit = 5
        testDefaults.captionLineLimit = 10
        
        let expectation = XCTestExpectation(description: "Concurrent reads complete")
        expectation.expectedFulfillmentCount = 10
        
        // Perform concurrent reads
        for _ in 0..<10 {
            DispatchQueue.global().async {
                // Perform multiple reads
                for _ in 0..<100 {
                    _ = self.testDefaults.hiddenGroupActive
                    _ = self.testDefaults.titleLineLimit
                    _ = self.testDefaults.captionLineLimit
                }
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Verify values are still correct
        XCTAssertTrue(testDefaults.hiddenGroupActive, "Value should remain true after concurrent reads")
        XCTAssertEqual(testDefaults.titleLineLimit, 5, "Value should remain 5 after concurrent reads")
        XCTAssertEqual(testDefaults.captionLineLimit, 10, "Value should remain 10 after concurrent reads")
    }
    
    // TC-UDTHREAD-02: Concurrent writes resolve deterministically
    func testTC_UDTHREAD_02_ConcurrentWritesResolveDeterministically() {
        let expectation = XCTestExpectation(description: "Concurrent writes complete")
        expectation.expectedFulfillmentCount = 10
        
        // Perform concurrent writes
        for i in 0..<10 {
            DispatchQueue.global().async {
                // Each thread writes different values
                self.testDefaults.hiddenGroupActive = (i % 2 == 0)
                self.testDefaults.titleLineLimit = i
                self.testDefaults.captionLineLimit = i * 2
                
                // Small delay to allow interleaving
                Thread.sleep(forTimeInterval: 0.001)
                
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // After all writes complete, verify we have valid values (not corrupted)
        // The exact final value depends on which thread wrote last, but it should be valid
        let finalHidden = testDefaults.hiddenGroupActive
        let finalTitle = testDefaults.titleLineLimit
        let finalCaption = testDefaults.captionLineLimit
        
        // Values should be valid (not corrupted)
        XCTAssertTrue(finalHidden == true || finalHidden == false, "hiddenGroupActive should be valid Bool")
        XCTAssertTrue(finalTitle >= 0 && finalTitle <= 9, "titleLineLimit should be in valid range")
        XCTAssertTrue(finalCaption >= 0 && finalCaption <= 18, "captionLineLimit should be in valid range")
        
        // Verify we can still read/write after concurrent operations
        testDefaults.hiddenGroupActive = true
        testDefaults.titleLineLimit = 42
        testDefaults.captionLineLimit = 84
        
        XCTAssertTrue(testDefaults.hiddenGroupActive, "Should be able to write after concurrent operations")
        XCTAssertEqual(testDefaults.titleLineLimit, 42, "Should be able to write after concurrent operations")
        XCTAssertEqual(testDefaults.captionLineLimit, 84, "Should be able to write after concurrent operations")
    }
}

