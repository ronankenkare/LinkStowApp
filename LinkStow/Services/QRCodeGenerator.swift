import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeGenerator {
    private let context = CIContext()

    func generateQRCode(from url: String) -> UIImage? {
        // Create a new filter instance for each generation to ensure thread safety
        // and prevent state pollution between concurrent calls
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(url.utf8)

        if let outputImage = filter.outputImage {
            // Scale QR code for clarity
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)

            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
}
