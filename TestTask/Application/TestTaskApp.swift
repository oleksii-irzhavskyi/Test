
import SwiftUI

@main
struct TestTaskApp: App {
    @StateObject private var router = AppRouter()
    
    var body: some Scene {
        WindowGroup {
            RouterView()
                .environmentObject(router)
                .onAppear {
                    SoundManager.shared.playBackgroundMusic(name: "background")
                }
        }
    }
}
