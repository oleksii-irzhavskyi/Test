
import SwiftUI

struct RouterView: View {
    @EnvironmentObject var router: AppRouter
    
    var body: some View {
        ZStack {
            switch router.path.last {
            case .menu, .none:
                MenuView()
            case .settings:
                SettingsView()
            case .levels:
                LevelsView()
            case .game(let level):
                GameView(level: level)
            }
        }
        .animation(.easeInOut, value: router.path)
        .transition(.slide)
    }
}
