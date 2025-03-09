import SwiftUI

@main
struct TransitionPlannerApp: App {
    @StateObject private var taskManager = TaskManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(taskManager)
        }
    }
} 