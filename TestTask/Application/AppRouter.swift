
import Foundation
import SwiftUI

final class AppRouter: ObservableObject {
    @Published var path: [Route] = []
    
    func navigate(to route: Route) {
        path.append(route)
    }
    
    func back() {
        _ = path.popLast()
    }
    
    func resetToMenu() {
        path.removeAll()
    }
}
