import SwiftUI
import SwiftData
import LocalAuthentication


func authenticateUser(activation: Bool) async throws -> Bool {
    let context = LAContext()
    var error: NSError?
    var reason: String = ""

    if activation {
        reason = "Please authenticate to activate hidden group."
    } else {
        reason = "Please authenticate to access hidden group."
    }

    if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
        let result = try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
        return result
    }
    return false
}