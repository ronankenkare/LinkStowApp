import SwiftUI
import UIKit

let QR_CODE_WIDTH: CGFloat = 300 - PADDING*2
let QR_CODE_HEIGHT: CGFloat = QR_CODE_WIDTH

struct QRCodeView: View {
    @Environment(\.dismiss) private var dismiss
    let urlString: String
    private let qrCodeGenerator = QRCodeGenerator()
    @State private var showShareSheet = false
    
    private var qrImage: UIImage? {
        qrCodeGenerator.generateQRCode(from: urlString)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: PADDING) {
                if let qrImage = qrImage {
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: QR_CODE_WIDTH, height: QR_CODE_HEIGHT)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: MAIN_BUTTON_CORNER_RADIUS)
                                .fill(Color.white)
                        )
                } else {
                    Text("Failed to generate QR code")
                        .foregroundColor(.red)
                }
                
                HStack(spacing: PADDING) {
                    Button(action: {
                        copyQRCode()
                    }) {
                        Label("Copy", systemImage: "doc.on.doc")
                            .font(.headline).bold()
                            .frame(maxWidth: .infinity)
                            .padding(PADDING)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: MAIN_BUTTON_CORNER_RADIUS))
                    }
                    .disabled(qrImage == nil)
                    
                    Button(action: {
                        showShareSheet = true
                    }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .font(.headline).bold()
                            .frame(maxWidth: .infinity)
                            .padding(PADDING)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: MAIN_BUTTON_CORNER_RADIUS))
                    }
                    .disabled(qrImage == nil)
                }
                .frame(width: 300)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "checkmark") { 
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let qrImage = qrImage {
                    ShareSheet(activityItems: [qrImage])
                }
            }
        }
    }
    
    private func copyQRCode() {
        guard let qrImage = qrImage else { return }
        UIPasteboard.general.image = qrImage
    }
}

// MARK: - Share Sheet -
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        // For iPad support
        if let popover = controller.popoverPresentationController,
           let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            popover.sourceView = window
            popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}
