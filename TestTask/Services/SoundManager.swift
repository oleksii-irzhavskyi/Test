
import SwiftUI
import AVFoundation
import UIKit

final class SoundManager: NSObject, AVAudioPlayerDelegate {
    static let shared = SoundManager()
    private var bgPlayer: AVAudioPlayer?
    private var sfxPlayers: [String: AVAudioPlayer] = [:]
    private override init() { super.init() }
    
    @AppStorage("isMusicOn") private var isMusicOn: Bool = true

    func playBackgroundMusic(name: String, ext: String = "wav", volume: Float = 0.6, loops: Int = -1) {
        guard isMusicOn else { return }
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else { return }
        do {
            bgPlayer = try AVAudioPlayer(contentsOf: url)
            bgPlayer?.numberOfLoops = loops
            bgPlayer?.volume = volume
            bgPlayer?.delegate = self
            bgPlayer?.prepareToPlay()
            bgPlayer?.play()
        } catch { print("[SoundManager] bgm error: \(error)") }
    }

    func stopBackgroundMusic() {
        bgPlayer?.stop()
        bgPlayer = nil
    }

    func playSFX(name: String, ext: String = "wav", volume: Float = 1.0) {
        guard isMusicOn else { return }
        let key = "\(name).\(ext)"
        if let p = sfxPlayers[key], p.isPlaying == false {
            p.currentTime = 0
            p.volume = volume
            p.play()
            return
        }
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else { return }
        do {
            let p = try AVAudioPlayer(contentsOf: url)
            p.volume = volume
            p.prepareToPlay()
            p.play()
            sfxPlayers[key] = p
        } catch { print("[SoundManager] sfx error: \(error)") }
    }
}

