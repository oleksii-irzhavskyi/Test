
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var router: AppRouter
    @AppStorage("isMusicOn") private var isMusicOn: Bool = true
    @AppStorage("isHapticsOn") private var isHapticsOn: Bool = true
    var body: some View {
        ZStack {
            Image("menuBG")
                .resizable()
                .ignoresSafeArea()
            VStack {
                HStack {
                    BackButton {
                        SoundManager.shared.playSFX(name: "click")
                        HapticsManager.shared.impact()
                        router.back()
                    }
                    Spacer()
                }
                Spacer()
            }
            
            RoundedRectangle(cornerRadius: 20)
                .frame(height: 300)
                .foregroundColor(Color(hex: "7A025A").opacity(0.8))
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "FF6CD8"), lineWidth: 2)
                }
                .overlay {
                    VStack(spacing: 20) {
                        Text("Settings")
                            .foregroundStyle(Color.white)
                            .font(.rubik(ofSize: 22))
                        
                        Spacer()
                        
                        HStack {
                            Text("Music")
                                .foregroundStyle(Color.white)
                                .font(.rubik(ofSize: 22))
                            Spacer()
                            Button {
                                SoundManager.shared.playSFX(name: "click")
                                HapticsManager.shared.impact()
                                isMusicOn.toggle()
                                if isMusicOn {
                                    SoundManager.shared.playBackgroundMusic(name: "background")
                                } else {
                                    SoundManager.shared.stopBackgroundMusic()
                                }
                            } label: {
                                Image(isMusicOn ? "onBTN" : "offBTN")
                                    .resizable()
                                    .frame(width: 50, height: 30)
                            }
                        }
                        
                        HStack {
                            Text("Haptics")
                                .foregroundStyle(Color.white)
                                .font(.rubik(ofSize: 22))
                            Spacer()
                            Button {
                                SoundManager.shared.playSFX(name: "click")
                                HapticsManager.shared.impact()
                                isHapticsOn.toggle()
                                if isHapticsOn { HapticsManager.shared.impact(.medium) }
                            } label: {
                                Image(isHapticsOn ? "onBTN" : "offBTN")
                                    .resizable()
                                    .frame(width: 50, height: 30)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 20)
                }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppRouter())
}
