
import SwiftUI
import AVFoundation
import UIKit

final class HapticsManager {
    static let shared = HapticsManager()
    @AppStorage("isHapticsOn") private var isHapticsOn: Bool = true
    
    private init() {}
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard isHapticsOn else { return }
        let gen = UIImpactFeedbackGenerator(style: style)
        gen.prepare()
        gen.impactOccurred()
    }
    
    func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    func warning() { UINotificationFeedbackGenerator().notificationOccurred(.warning) }
    func error()   { UINotificationFeedbackGenerator().notificationOccurred(.error) }
}
