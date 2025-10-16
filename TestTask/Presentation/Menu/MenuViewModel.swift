
import SwiftUI

class MenuViewModel: ObservableObject {
    enum Intent { case openLevels, openSettings }
    private weak var router: AppRouter?
    
    func bind(router: AppRouter) { self.router = router }
    
    func send(_ intent: Intent) {
        switch intent {
        case .openLevels:
            router?.navigate(to: .levels)
        case .openSettings:
            router?.navigate(to: .settings)
        }
    }
}
