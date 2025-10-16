
import SwiftUI

struct BackButton: View {
    var action: () -> Void
    var body: some View {
        Button(action: action){
            Image("backBTN")
                .resizable()
                .frame(width: 80, height: 80)
        }
    }
}

#Preview {
    BackButton(action: {})
}
