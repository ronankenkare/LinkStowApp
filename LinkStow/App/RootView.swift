// RootView.swift
import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) var modelContext
    
    @Query(sort: \GroupModel.name) var groups: [GroupModel]
    @Query(sort: \LinkModel.title) var links: [LinkModel]
    
    var body: some View {
        
        let mainController: MainController = MainController(modelContext: modelContext)
        
        // MARK: - Navigation Stack -
        NavigationStack {
            VStack(spacing: 0) {
                MainView(mainController: mainController, modelContext: modelContext)
            }
        }
    }
}
