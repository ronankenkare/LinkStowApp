import SwiftUI
import SwiftData

@main
struct LinkStowApp: App {
    @State private var notificationError: String?
    
    init() {
        // Request notification permissions

    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(AppModelContainer.shared)
                .alert("Notification Error", isPresented: .constant(notificationError != nil)) {
                    Button("OK") {
                        notificationError = nil
                    }
                } message: {
                    if let error = notificationError {
                        Text(error)
                    }
                }
        }
    }
}


