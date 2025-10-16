
import SwiftUI

struct LevelsView: View {
    @EnvironmentObject var router: AppRouter
    @AppStorage("maxLevel") private var maxLevel: Int = 1
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    @StateObject private var viewModel = LevelsViewModel()
    
    var body: some View {
        ZStack {
            Image("menuBG")
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                HStack {
                    BackButton {
                        SoundManager.shared.playSFX(name: "click")
                        HapticsManager.shared.impact()
                        viewModel.send(.back)
                    }
                    
                    Spacer()
                    
                    BalanceView()
                }
                
                VStack(spacing: 35) {
                    Text("Choose level")
                        .foregroundStyle(Color.white)
                        .font(.rubik(ofSize: 30))
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(1...9, id: \.self) { level in
                            let isUnlocked = level <= maxLevel
                            Button {
                                SoundManager.shared.playSFX(name: "click")
                                HapticsManager.shared.impact()
                                if isUnlocked { viewModel.send(.openGame(level: level)) }
                            } label: {
                                ZStack {
                                    Image("BTN")
                                        .resizable()
                                        .scaledToFit()
                                        .grayscale(isUnlocked ? 0.0 : 1.0)
                                        .opacity(isUnlocked ? 1.0 : 0.6)
                                    Text("\(level)")
                                        .font(.rubik(ofSize: 28))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 1)
                                }
                            }
                            .disabled(!isUnlocked)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                Spacer()
            }
        }
        .onAppear { viewModel.bind(router: router) }
    }
}


struct LevelsView_Previews: PreviewProvider {
    static var previews: some View {
        LevelsView()
            .environmentObject(AppRouter())
    }
}
