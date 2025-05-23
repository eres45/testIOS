import SwiftUI

struct NoInternetView: View {
    var retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 70))
                .foregroundColor(.gray)
                .padding()
            
            Text("No Internet Connection")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Please check your internet connection and try again.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
            
            Button(action: retryAction) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Retry")
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(NeumorphicStyle.primaryColor)
                .foregroundColor(.white)
                .clipShape(Capsule())
            }
            .padding(.top, 16)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: NeumorphicStyle.borderRadius)
                .fill(NeumorphicStyle.backgroundColor)
                .shadow(color: NeumorphicStyle.shadowColor, radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal)
    }
} 