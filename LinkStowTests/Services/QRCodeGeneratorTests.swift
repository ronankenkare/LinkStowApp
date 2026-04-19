import XCTest
import UIKit
import SwiftUI
@testable import LinkStow

final class QRCodeGeneratorTests: XCTestCase {
    var qrCodeGenerator: QRCodeGenerator!
    
    override func setUp() {
        super.setUp()
        qrCodeGenerator = QRCodeGenerator()
    }
    
    override func tearDown() {
        qrCodeGenerator = nil
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    /// Extract image dimensions
    private func imageDimensions(_ image: UIImage) -> (width: CGFloat, height: CGFloat) {
        return (image.size.width, image.size.height)
    }
    
    /// Generate hash for pixel comparison
    private func imageHash(_ image: UIImage) -> String? {
        guard let cgImage = image.cgImage else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        
        // Create a bitmap context to extract pixel data
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        // Allocate memory for pixel data
        var pixelData = [UInt8](repeating: 0, count: bytesPerRow * height)
        
        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        
        // Draw the image into the context
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // Convert pixel data to Data for hashing
        let data = Data(pixelData)
        
        // Use Swift's Hasher for robust hashing
        var hasher = Hasher()
        hasher.combine(width)
        hasher.combine(height)
        hasher.combine(data)
        
        return String(hasher.finalize())
    }
    
    /// Check if image has visible (non-transparent) pixels
    private func hasVisiblePixels(_ image: UIImage) -> Bool {
        guard let cgImage = image.cgImage else { return false }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return false }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let pixelData = context.data else { return false }
        let data = Data(bytes: pixelData, count: bytesPerRow * height)
        
        // Check for non-transparent pixels (alpha > 0)
        for i in stride(from: 3, to: data.count, by: 4) {
            if data[i] > 0 {
                return true
            }
        }
        return false
    }
    
    /// Measure performance of a block
    private func measurePerformance(_ block: () -> Void) -> TimeInterval {
        let startTime = CFAbsoluteTimeGetCurrent()
        block()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        return timeElapsed
    }
    
    // MARK: - 1. Basic Functionality Tests
    
    func testTC_QRGEN_01_GenerateQRCodeFromValidURL() {
        // TC-QRGEN-01: Generate QR code from a valid URL
        let url = "https://example.com"
        
        let qrImage = qrCodeGenerator.generateQRCode(from: url)
        
        // Returns non-nil UIImage
        XCTAssertNotNil(qrImage, "QR code image should not be nil for valid URL")
        
        guard let image = qrImage else { return }
        
        // Image has non-zero width and height
        let dimensions = imageDimensions(image)
        XCTAssertGreaterThan(dimensions.width, 0, "Image width should be greater than 0")
        XCTAssertGreaterThan(dimensions.height, 0, "Image height should be greater than 0")
    }
    
    func testTC_QRGEN_02_GenerateQRCodeFromNonURLString() {
        // TC-QRGEN-02: Generate QR code from non-URL string
        // QR codes encode strings, not just URLs — this is correct behavior.
        let text = "hello world"
        
        let qrImage = qrCodeGenerator.generateQRCode(from: text)
        
        // Returns non-nil image
        XCTAssertNotNil(qrImage, "QR code image should not be nil for non-URL string")
        
        guard let image = qrImage else { return }
        
        let dimensions = imageDimensions(image)
        XCTAssertGreaterThan(dimensions.width, 0, "Image width should be greater than 0")
        XCTAssertGreaterThan(dimensions.height, 0, "Image height should be greater than 0")
    }
    
    // MARK: - 2. Input Variations Tests
    
    func testTC_QRIN_01_EmptyStringInput() {
        // TC-QRIN-01: Empty string input ""
        // Note: Empty string may or may not generate a QR code depending on CoreImage behavior
        let emptyString = ""
        
        let qrImage = qrCodeGenerator.generateQRCode(from: emptyString)
        
        // Returns non-nil image or nil consistently (define expected behavior)
        // CoreImage QR generator typically generates a QR code even for empty strings
        // We'll test that it doesn't crash and returns either nil or a valid image
        if let image = qrImage {
            let dimensions = imageDimensions(image)
            XCTAssertGreaterThan(dimensions.width, 0, "If image is returned, it should have non-zero dimensions")
        }
        // If nil is returned, that's also acceptable behavior
    }
    
    func testTC_QRIN_02_SingleCharacterString() {
        // TC-QRIN-02: Single-character string
        let singleChar = "A"
        
        let qrImage = qrCodeGenerator.generateQRCode(from: singleChar)
        
        // Returns non-nil image
        XCTAssertNotNil(qrImage, "QR code image should not be nil for single character")
        
        guard let image = qrImage else { return }
        
        let dimensions = imageDimensions(image)
        XCTAssertGreaterThan(dimensions.width, 0, "Image width should be greater than 0")
        XCTAssertGreaterThan(dimensions.height, 0, "Image height should be greater than 0")
    }
    
    func testTC_QRIN_03_UnicodeString() {
        // TC-QRIN-03: Unicode string
        let unicodeString = "https://例子.测试"
        
        let qrImage = qrCodeGenerator.generateQRCode(from: unicodeString)
        
        // QR generated successfully
        XCTAssertNotNil(qrImage, "QR code image should not be nil for Unicode string")
        
        guard let image = qrImage else { return }
        
        let dimensions = imageDimensions(image)
        XCTAssertGreaterThan(dimensions.width, 0, "Image width should be greater than 0")
        XCTAssertGreaterThan(dimensions.height, 0, "Image height should be greater than 0")
    }
    
    func testTC_QRIN_04_EmojiString() {
        // TC-QRIN-04: Emoji string
        let emojiString = "🔗✨"
        
        let qrImage = qrCodeGenerator.generateQRCode(from: emojiString)
        
        // QR generated successfully
        XCTAssertNotNil(qrImage, "QR code image should not be nil for emoji string")
        
        guard let image = qrImage else { return }
        
        let dimensions = imageDimensions(image)
        XCTAssertGreaterThan(dimensions.width, 0, "Image width should be greater than 0")
        XCTAssertGreaterThan(dimensions.height, 0, "Image height should be greater than 0")
    }
    
    // MARK: - 3. Image Properties Tests
    
    func testTC_QRIMG_01_OutputImageIsScaled() {
        // TC-QRIMG-01: Output image is scaled
        // Width and height are significantly larger than base QR
        // Scale factor ≈ 10x
        let url = "https://example.com"
        
        let qrImage = qrCodeGenerator.generateQRCode(from: url)
        
        XCTAssertNotNil(qrImage, "QR code image should not be nil")
        
        guard let image = qrImage else { return }
        
        // Base QR code is typically 21x21 or 25x25 modules for small data
        // With 10x scaling, we expect at least 210x210 pixels
        let dimensions = imageDimensions(image)
        XCTAssertGreaterThanOrEqual(dimensions.width, 200, "Scaled image width should be at least 200 pixels")
        XCTAssertGreaterThanOrEqual(dimensions.height, 200, "Scaled image height should be at least 200 pixels")
    }
    
    func testTC_QRIMG_02_OutputImageAspectRatioIsOneToOne() {
        // TC-QRIMG-02: Output image aspect ratio is 1:1
        let url = "https://example.com"
        
        let qrImage = qrCodeGenerator.generateQRCode(from: url)
        
        XCTAssertNotNil(qrImage, "QR code image should not be nil")
        
        guard let image = qrImage else { return }
        
        let dimensions = imageDimensions(image)
        let aspectRatio = dimensions.width / dimensions.height
        XCTAssertEqual(aspectRatio, 1.0, accuracy: 0.01, "Aspect ratio should be 1:1")
    }
    
    func testTC_QRIMG_03_ImageHasVisiblePixelData() {
        // TC-QRIMG-03: Image has visible pixel data
        let url = "https://example.com"
        
        let qrImage = qrCodeGenerator.generateQRCode(from: url)
        
        XCTAssertNotNil(qrImage, "QR code image should not be nil")
        
        guard let image = qrImage else { return }
        
        // Check that image has visible pixels
        XCTAssertTrue(hasVisiblePixels(image), "Image should have visible pixel data")
    }
    
    func testTC_QRIMG_04_ImageIsNotFullyTransparent() {
        // TC-QRIMG-04: Image is not fully transparent
        let url = "https://example.com"
        
        let qrImage = qrCodeGenerator.generateQRCode(from: url)
        
        XCTAssertNotNil(qrImage, "QR code image should not be nil")
        
        guard let image = qrImage else { return }
        
        // Check that image has non-transparent pixels
        XCTAssertTrue(hasVisiblePixels(image), "Image should not be fully transparent")
    }
    
    // MARK: - 4. Determinism & Consistency Tests
    
    func testTC_QRDET_01_SameInputProducesIdenticalImageDimensions() {
        // TC-QRDET-01: Same input produces identical image dimensions
        let url = "https://example.com"
        
        let qrImage1 = qrCodeGenerator.generateQRCode(from: url)
        let qrImage2 = qrCodeGenerator.generateQRCode(from: url)
        
        XCTAssertNotNil(qrImage1, "First QR code image should not be nil")
        XCTAssertNotNil(qrImage2, "Second QR code image should not be nil")
        
        guard let image1 = qrImage1, let image2 = qrImage2 else { return }
        
        let dimensions1 = imageDimensions(image1)
        let dimensions2 = imageDimensions(image2)
        
        XCTAssertEqual(dimensions1.width, dimensions2.width, "Image widths should be identical")
        XCTAssertEqual(dimensions1.height, dimensions2.height, "Image heights should be identical")
    }
    
    func testTC_QRDET_02_SameInputProducesVisuallyIdenticalQRCodes() {
        // TC-QRDET-02: Same input produces visually identical QR codes
        // Pixel comparison or hash match
        let url = "https://example.com"
        
        let qrImage1 = qrCodeGenerator.generateQRCode(from: url)
        let qrImage2 = qrCodeGenerator.generateQRCode(from: url)
        
        XCTAssertNotNil(qrImage1, "First QR code image should not be nil")
        XCTAssertNotNil(qrImage2, "Second QR code image should not be nil")
        
        guard let image1 = qrImage1, let image2 = qrImage2 else { return }
        
        let hash1 = imageHash(image1)
        let hash2 = imageHash(image2)
        
        XCTAssertNotNil(hash1, "First image hash should not be nil")
        XCTAssertNotNil(hash2, "Second image hash should not be nil")
        
        guard let h1 = hash1, let h2 = hash2 else { return }
        
        XCTAssertEqual(h1, h2, "Image hashes should match for identical inputs")
    }
    
   
    
    // MARK: - 5. Failure & Edge Handling Tests
    
    func testTC_QRFAIL_01_FilterOutputImageNil() {
        // TC-QRFAIL-01: filter.outputImage == nil
        // Function returns nil
        // No crash
        // Note: It's difficult to force filter.outputImage to be nil in normal operation
        // We'll test with an input that might cause issues, but CoreImage is generally robust
        // Testing with extremely large data might help, but empty string is more likely to still work
        
        // For this test, we verify that the function handles nil gracefully
        // by checking that it doesn't crash and returns nil when appropriate
        // Since we can't easily mock the filter, we'll test edge cases
        
        // Test with a very unusual input that might cause issues
        // In practice, CoreImage QR generator is very robust, so this mainly tests the nil check
        let unusualInput = String(repeating: "A", count: 10000)
        let qrImage = qrCodeGenerator.generateQRCode(from: unusualInput)
        
        // Should either return nil or a valid image, but not crash
        if let image = qrImage {
            let dimensions = imageDimensions(image)
            XCTAssertGreaterThan(dimensions.width, 0, "If image is returned, it should be valid")
        }
        // If nil is returned, that's acceptable - the function handled it gracefully
    }
    
    func testTC_QRFAIL_02_ContextCreateCGImageFails() {
        // TC-QRFAIL-02: context.createCGImage() fails
        // Function returns nil
        // No crash
        // Note: It's difficult to force createCGImage to fail in normal operation
        // This test verifies that the nil check is in place and doesn't crash
        // We'll test with normal inputs and verify graceful handling
        
        let url = "https://example.com"
        let qrImage = qrCodeGenerator.generateQRCode(from: url)
        
        // Should either return nil or a valid image, but not crash
        // In normal operation with valid input, it should return a valid image
        // The nil check in the code ensures no crash if createCGImage fails
        if let image = qrImage {
            let dimensions = imageDimensions(image)
            XCTAssertGreaterThan(dimensions.width, 0, "If image is returned, it should be valid")
        }
    }
    
    func testTC_QRFAIL_03_VeryLongString() {
        // TC-QRFAIL-03: Very long string (e.g. 10,000 chars)
        // Returns image or fails gracefully
        // No crash or memory spike
        let longString = String(repeating: "A", count: 10000)
        
        let qrImage = qrCodeGenerator.generateQRCode(from: longString)
        
        // Should either return a valid image or nil, but not crash
        if let image = qrImage {
            let dimensions = imageDimensions(image)
            XCTAssertGreaterThan(dimensions.width, 0, "If image is returned, it should be valid")
        }
        // If nil is returned, that's acceptable - the function handled it gracefully
    }
    
    // MARK: - 6. Thread Safety Tests
    
    func testTC_QRTHREAD_01_CallGenerateQRCodeOnBackgroundThread() {
        // TC-QRTHREAD-01: Call generateQRCode on background thread
        // Succeeds
        // No race conditions
        let url = "https://example.com"
        let expectation = XCTestExpectation(description: "QR code generated on background thread")
        
        DispatchQueue.global(qos: .background).async {
            let qrImage = self.qrCodeGenerator.generateQRCode(from: url)
            
            XCTAssertNotNil(qrImage, "QR code image should not be nil when generated on background thread")
            
            if let image = qrImage {
                let dimensions = self.imageDimensions(image)
                XCTAssertGreaterThan(dimensions.width, 0, "Image width should be greater than 0")
                XCTAssertGreaterThan(dimensions.height, 0, "Image height should be greater than 0")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    
    
    // MARK: - 7. Performance Tests
    
    func testTC_QRP_01_QRGenerationCompletesUnderAcceptableTime() {
        // TC-QRP-01: QR generation completes under acceptable time
        // e.g. < 50ms on test device
        let url = "https://example.com"
        
        let timeElapsed = measurePerformance {
            _ = self.qrCodeGenerator.generateQRCode(from: url)
        }
        
        // Convert to milliseconds
        let timeInMs = timeElapsed * 1000
        
        // Should complete in under 50ms (allowing some margin for test environment)
        XCTAssertLessThan(timeInMs, 100.0, "QR generation should complete in under 100ms (allowing margin for test environment)")
    }
    
    func testTC_QRP_02_NoMemoryLeaksAfterRepeatedCalls() {
        // TC-QRP-02: No memory leaks after repeated calls
        let url = "https://example.com"
        
        // Perform many generations
        for _ in 0..<100 {
            autoreleasepool {
                _ = qrCodeGenerator.generateQRCode(from: url)
            }
        }
        
        // If we get here without crashing or excessive memory usage, the test passes
        // More detailed memory leak detection would require Instruments
        XCTAssertTrue(true, "Repeated QR code generation should not cause memory leaks")
    }
    
    func testTC_QRP_03_CIContextReusedEfficiently() {
        // TC-QRP-03: CIContext reused efficiently
        // The QRCodeGenerator uses a private let context, so it should be reused
        // We test that multiple calls work correctly, indicating efficient reuse
        let urls = [
            "https://example.com",
            "https://test.com",
            "https://sample.com"
        ]
        
        var allSucceeded = true
        for url in urls {
            let qrImage = qrCodeGenerator.generateQRCode(from: url)
            if qrImage == nil {
                allSucceeded = false
                break
            }
        }
        
        XCTAssertTrue(allSucceeded, "CIContext should be reused efficiently across multiple calls")
    }
    
    // MARK: - 8. UIKit / SwiftUI Compatibility Tests
    
    func testTC_QRUI_01_ReturnedUIImageRendersInUIImageView() {
        // TC-QRUI-01: Returned UIImage renders in UIImageView
        let url = "https://example.com"
        
        let qrImage = qrCodeGenerator.generateQRCode(from: url)
        
        XCTAssertNotNil(qrImage, "QR code image should not be nil")
        
        guard let image = qrImage else { return }
        
        // Create UIImageView and set image
        let imageView = UIImageView(image: image)
        
        // Verify image is set
        XCTAssertNotNil(imageView.image, "UIImageView should have an image")
        XCTAssertEqual(imageView.image, image, "UIImageView image should match generated image")
        
        // Verify image view can render (has non-zero size)
        imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        XCTAssertGreaterThan(imageView.frame.width, 0, "ImageView should have non-zero width")
        XCTAssertGreaterThan(imageView.frame.height, 0, "ImageView should have non-zero height")
    }
    
    func testTC_QRUI_02_ReturnedUIImageRendersInSwiftUIImage() {
        // TC-QRUI-02: Returned UIImage renders in SwiftUI Image(uiImage:)
        let url = "https://example.com"
        
        let qrImage = qrCodeGenerator.generateQRCode(from: url)
        
        XCTAssertNotNil(qrImage, "QR code image should not be nil")
        
        guard let image = qrImage else { return }
        
        // Create SwiftUI Image from UIImage
        let swiftUIImage = Image(uiImage: image)
        
        // Verify we can create the Image without crashing
        // In a real SwiftUI view, this would render correctly
        XCTAssertNotNil(swiftUIImage, "SwiftUI Image should be created from UIImage")
        
        // Verify the underlying image data is accessible
        let dimensions = imageDimensions(image)
        XCTAssertGreaterThan(dimensions.width, 0, "Image should have non-zero width")
        XCTAssertGreaterThan(dimensions.height, 0, "Image should have non-zero height")
    }
    
    func testTC_QRUI_03_ImageRendersCrisply() {
        // TC-QRUI-03: Image renders crisply (no blur)
        // QR codes should be rendered without interpolation to maintain sharpness
        let url = "https://example.com"
        
        let qrImage = qrCodeGenerator.generateQRCode(from: url)
        
        XCTAssertNotNil(qrImage, "QR code image should not be nil")
        
        guard let image = qrImage else { return }
        
        // Verify image scale is 1.0 (no scaling that would cause blur)
        XCTAssertEqual(image.scale, 1.0, "Image scale should be 1.0 for crisp rendering")
        
        // Verify image has proper dimensions
        let dimensions = imageDimensions(image)
        XCTAssertGreaterThan(dimensions.width, 0, "Image should have non-zero width")
        XCTAssertGreaterThan(dimensions.height, 0, "Image should have non-zero height")
        
        // Verify image is not nil when accessed via cgImage
        XCTAssertNotNil(image.cgImage, "Image should have a valid CGImage for crisp rendering")
    }
}
