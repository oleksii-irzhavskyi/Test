
import SwiftUI

struct BalanceView: View {
    @AppStorage("balance") private var balance: Int = 0
    
    var body: some View {
        ZStack {
            HStack(spacing: -18) {
                RoundedRectangle(cornerRadius: 30)
                    .foregroundStyle(Color(hex: "FF8E03"))
                    .frame(width: 100, height: 30)
                    .overlay {
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color(hex: "FF2B00"), lineWidth: 3)
                    }
                    .overlay {
                        
                        Text("\(balance)")
                            .font(.rubik(ofSize: 16))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.4), radius: 2, x: 1, y: 1)
                    }
                
                Image("coin")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
            }
        }
    }
}

#Preview {
    BalanceView()
}
