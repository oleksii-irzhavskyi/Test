
import Foundation
import SwiftUI

enum Route: Hashable {
    case menu
    case settings
    case levels
    case game(level: Int)
}
