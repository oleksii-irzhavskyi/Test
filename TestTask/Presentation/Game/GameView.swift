import SwiftUI
import SpriteKit
import UIKit

struct GameView: View {
    let level: Int
    @EnvironmentObject private var router: AppRouter
    @StateObject private var vm = GameViewModel()
    @State private var scene: GameScene = {
        if let s = GameScene(fileNamed: "GameScene") {
            s.scaleMode = .fill
            s.isUserInteractionEnabled = true
            return s
        } else {
            let fallback = GameScene(size: UIScreen.main.bounds.size)
            fallback.scaleMode = .fill
            fallback.isUserInteractionEnabled = true
            return fallback
        }
    }()

    var body: some View {
        ZStack {
            SpriteView(
                scene: scene,
                options: []
            )
            .ignoresSafeArea()
            .onAppear {
                scene.applyLevel(level)
                scene.onGameEnd = { ended, finalScore in
                    scene.isPaused = true
                    let didWin = (ended == .won)
                    vm.handleGameEnd(level: level, score: finalScore, didWin: didWin)
                    switch ended {
                    case .won:
                        vm.result = .win
                        SoundManager.shared.playSFX(name: "win")
                    case .lost:
                        vm.result = .lose
                        SoundManager.shared.playSFX(name: "lose")
                        HapticsManager.shared.impact()
                    }
                }
                scene.onScoreUpdate = { score in
                    vm.updateCurrentScore(score)
                }
            }
            VStack {
                ZStack {
                    HStack {
                        Text("Score: \(vm.currentScore)")
                            .foregroundStyle(Color.white)
                            .font(.rubik(ofSize: 14))
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 1)
                            .padding(.leading, 16)
                        
                        Spacer()
                        
                        Button {
                            SoundManager.shared.playSFX(name: "click")
                            HapticsManager.shared.impact()
                            vm.pause(scene: scene)
                        } label: {
                            Image("pauseBTN")
                                .resizable()
                                .frame(width: 80, height: 80)
                        }
                    }
                    
                    BalanceView()
                }
                
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        SoundManager.shared.playSFX(name: "click")
                        HapticsManager.shared.impact()
                        scene.jump() }) {
                        Text("JUMP")
                            .font(.rubik(ofSize: 16))
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.9), lineWidth: 2))
                            .cornerRadius(12)
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, 20)
                }
            }
            
            if let res = vm.result {
                Color.black.opacity(0.8).ignoresSafeArea()
                
                VStack(spacing: 16) {
                    if res == .win {
                        Text("You win")
                            .foregroundStyle(Color.white)
                            .font(.rubik(ofSize: 45))
                        
                        RoundedRectangle(cornerRadius: 40)
                            .foregroundStyle(Color(hex: "43B805"))
                            .frame(width: 300, height: 44)
                            .overlay {
                                RoundedRectangle(cornerRadius: 40)
                                    .stroke(Color(hex: "006B1E"), lineWidth: 5)
                            }
                            .overlay {
                                HStack {
                                    Text("Score")
                                        .foregroundStyle(Color.white)
                                        .font(.rubik(ofSize: 24))
                                    
                                    Spacer()
                                    
                                    Text("\(vm.lastScore)")
                                        .foregroundStyle(Color.white)
                                        .font(.rubik(ofSize: 24))
                                }
                                .padding(.horizontal)
                            }
                        
                        RoundedRectangle(cornerRadius: 40)
                            .foregroundStyle(Color(hex: "43B805"))
                            .frame(width: 300, height: 44)
                            .overlay {
                                RoundedRectangle(cornerRadius: 40)
                                    .stroke(Color(hex: "006B1E"), lineWidth: 5)
                            }
                            .overlay {
                                HStack {
                                    Text("Best")
                                        .foregroundStyle(Color.white)
                                        .font(.rubik(ofSize: 24))
                                    
                                    Spacer()
                                    
                                    Text("\(vm.bestScore)")
                                        .foregroundStyle(Color.white)
                                        .font(.rubik(ofSize: 24))
                                }
                                .padding(.horizontal)
                            }
                        
                        HStack {
                            Button {
                                SoundManager.shared.playSFX(name: "click")
                                HapticsManager.shared.impact()
                                vm.goHome(router: router)
                            } label: {
                                Text("home")
                                    .foregroundStyle(Color.white)
                                    .font(.rubik(ofSize: 24))
                            }

                            Spacer()

                            Button {
                                SoundManager.shared.playSFX(name: "click")
                                HapticsManager.shared.impact()
                                vm.restart(scene: scene)
                            } label: {
                                Text("restart")
                                    .foregroundStyle(Color.white)
                                    .font(.rubik(ofSize: 24))
                            }
                        }
                        .frame(width: 300)
                        
                    } else {
                        Text("You lose")
                            .foregroundStyle(Color.white)
                            .font(.rubik(ofSize: 45))
                        
                        RoundedRectangle(cornerRadius: 40)
                            .foregroundStyle(Color(hex: "43B805"))
                            .frame(width: 300, height: 44)
                            .overlay {
                                RoundedRectangle(cornerRadius: 40)
                                    .stroke(Color(hex: "006B1E"), lineWidth: 5)
                            }
                            .overlay {
                                HStack {
                                    Text("Score")
                                        .foregroundStyle(Color.white)
                                        .font(.rubik(ofSize: 24))
                                    
                                    Spacer()
                                    
                                    Text("\(vm.lastScore)")
                                        .foregroundStyle(Color.white)
                                        .font(.rubik(ofSize: 24))
                                }
                                .padding(.horizontal)
                            }
                        
                        RoundedRectangle(cornerRadius: 40)
                            .foregroundStyle(Color(hex: "43B805"))
                            .frame(width: 300, height: 44)
                            .overlay {
                                RoundedRectangle(cornerRadius: 40)
                                    .stroke(Color(hex: "006B1E"), lineWidth: 5)
                            }
                            .overlay {
                                HStack {
                                    Text("Best")
                                        .foregroundStyle(Color.white)
                                        .font(.rubik(ofSize: 24))
                                    
                                    Spacer()
                                    
                                    Text("\(vm.bestScore)")
                                        .foregroundStyle(Color.white)
                                        .font(.rubik(ofSize: 24))
                                }
                                .padding(.horizontal)
                            }
                        
                        HStack {
                            Button {
                                SoundManager.shared.playSFX(name: "click")
                                HapticsManager.shared.impact()
                                vm.goHome(router: router)
                            } label: {
                                Text("home")
                                    .foregroundStyle(Color.white)
                                    .font(.rubik(ofSize: 24))
                            }
                            
                            Spacer()
                            
                            Button {
                                SoundManager.shared.playSFX(name: "click")
                                HapticsManager.shared.impact()
                                vm.restart(scene: scene)
                            } label: {
                                Text("restart")
                                    .foregroundStyle(Color.white)
                                    .font(.rubik(ofSize: 24))
                            }
                        }
                        .frame(width: 300)
                    }
                }
            }
            else if vm.isPausedUI {
                Color.black.opacity(0.8).ignoresSafeArea()
                VStack(spacing: 16) {
                    Text("Paused")
                        .foregroundStyle(Color.white)
                        .font(.rubik(ofSize: 45))

                    HStack {
                        Button {
                            SoundManager.shared.playSFX(name: "click")
                            HapticsManager.shared.impact()
                            vm.goHome(router: router)
                        } label: {
                            Text("home")
                                .foregroundStyle(Color.white)
                                .font(.rubik(ofSize: 24))
                        }

                        Spacer()

                        Button {
                            SoundManager.shared.playSFX(name: "click")
                            HapticsManager.shared.impact()
                            vm.restart(scene: scene)
                        } label: {
                            Text("restart")
                                .foregroundStyle(Color.white)
                                .font(.rubik(ofSize: 24))
                        }
                    }
                    .frame(width: 300)

                    Button {
                        SoundManager.shared.playSFX(name: "click")
                        HapticsManager.shared.impact()
                        vm.resume(scene: scene)
                    } label: {
                        Image("playBTN")
                            .resizable()
                            .frame(width: 160, height: 80)
                    }
                    .padding(.top, 8)
                }
            }
        }
    }
}

#Preview {
    GameView(level: 1)
        .environmentObject(AppRouter())
}
