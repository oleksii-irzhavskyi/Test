import SwiftUI
import SpriteKit
final class GameViewModel: ObservableObject {
    enum Result { case win, lose }

    @Published var result: Result?
    @Published var isPausedUI = false
    @Published var lastScore = 0
    @Published var currentScore = 0

    private let bestKey = "bestScore"
    private let maxLevelKey = "maxLevel"

    var bestScore: Int {
        get { UserDefaults.standard.integer(forKey: bestKey) }
        set { UserDefaults.standard.set(newValue, forKey: bestKey) }
    }

    var maxLevel: Int {
        get { max(1, UserDefaults.standard.integer(forKey: maxLevelKey)) }
        set { UserDefaults.standard.set(max(newValue, 1), forKey: maxLevelKey) }
    }

    func handleGameEnd(level: Int, score: Int, didWin: Bool) {
        lastScore = score
        currentScore = score
        if bestScore < score { bestScore = score }
        if didWin, level == maxLevel { maxLevel += 1 }
    }

    func updateCurrentScore(_ score: Int) {
        currentScore = score
    }

    func setResult(_ r: Result?, scene: SKScene) {
        result = r
        scene.isPaused = (r != nil)
    }

    func pause(scene: SKScene) {
        guard result == nil else { return }
        isPausedUI = true
        scene.isPaused = true
    }

    func resume(scene: SKScene) {
        isPausedUI = false
        scene.isPaused = false
    }

    func restart(scene: GameScene) {
        scene.resetGame()
        scene.isPaused = false
        result = nil
        isPausedUI = false
        currentScore = 0
    }

    func goHome(router: AppRouter) {
        result = nil
        isPausedUI = false
        router.back()
    }
}
