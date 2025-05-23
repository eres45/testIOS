import SwiftUI

struct StateDisplayView<T>: View {
    let state: ViewState<T>
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
            
            Spacer()
            
            HStack(spacing: 6) {
                switch state {
                case .idle:
                    Image(systemName: "circle")
                        .foregroundColor(.gray)
                    Text("Idle")
                        .foregroundColor(.gray)
                case .loading:
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundColor(.blue)
                        .rotationEffect(.degrees(state.isLoading ? 360 : 0))
                        .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: state.isLoading)
                    Text("Loading")
                        .foregroundColor(.blue)
                case .success:
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Success")
                        .foregroundColor(.green)
                case .error:
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text("Error")
                        .foregroundColor(.red)
                }
            }
            .font(.caption)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.15))
            )
        }
        .padding(.horizontal)
        .onAppear {
            if case .loading = state {
                // Trigger animation
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                    // Animation will be applied via the rotationEffect modifier
                }
            }
        }
    }
} 