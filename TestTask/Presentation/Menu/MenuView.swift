
import SwiftUI

struct MenuView: View {
    @EnvironmentObject var router: AppRouter
    @StateObject private var viewModel = MenuViewModel()
    
    var body: some View {
        ZStack {
            Image("menuBG")
                .resizable()
                .ignoresSafeArea()
            
            Image("rooster")
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 20)
                .overlay {
                    VStack {
                        Spacer()
                        
                        Button {
                            SoundManager.shared.playSFX(name: "click")
                            HapticsManager.shared.impact()
                            viewModel.send(.openLevels)
                        } label: {
                            Image("playBTN")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    .padding(.horizontal, 50)
                }
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button {
                        SoundManager.shared.playSFX(name: "click")
                        HapticsManager.shared.impact()
                        viewModel.send(.openSettings)
                    } label: {
                        Image("BTN")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .overlay {
                                Image(systemName: "gearshape.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(19)
                                    .foregroundStyle(Color(hex: "7A025A"))
                                    .overlay(
                                        Image(systemName: "gearshape.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .padding(20)
                                            .foregroundStyle(Color.white)
                                    )
                            }
                    }
                }
                
                Spacer()
            }
        }
        .onAppear { viewModel.bind(router: router) }
    }
}

#Preview {
    RouterView()
        .environmentObject(AppRouter())
}
