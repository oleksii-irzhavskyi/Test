
import SwiftUI

class LevelsViewModel: ObservableObject {
    enum Intent { case back, openGame(level: Int) }
    private weak var router: AppRouter?
    
    func bind(router: AppRouter) { self.router = router }
    
    func send(_ intent: Intent) {
        switch intent {
        case .back:
            router?.back()
        case .openGame(let level):
            router?.navigate(to: .game(level: level))
        }
    }
}
