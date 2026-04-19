import SwiftData

enum AppModelContainer {
    static var shared: ModelContainer = {
        let schema = Schema([
            LinkModel.self,
            GroupModel.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
