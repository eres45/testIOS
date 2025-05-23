import SwiftUI

extension View {
    func dismissKeyboard() -> some View {
        return self
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
    }
}

struct KeyboardAdaptive: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                    guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                    
                    // Get safe area inset using UIWindowScene approach (iOS 15+)
                    let safeAreaInset: CGFloat
                    if #available(iOS 15.0, *) {
                        let scenes = UIApplication.shared.connectedScenes
                        let windowScene = scenes.first as? UIWindowScene
                        safeAreaInset = windowScene?.windows.first?.safeAreaInsets.bottom ?? 0
                    } else {
                        safeAreaInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
                    }
                    
                    let keyboardHeightWithSafeArea = keyboardFrame.height - safeAreaInset
                    self.keyboardHeight = keyboardHeightWithSafeArea
                }
                
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    self.keyboardHeight = 0
                }
            }
    }
}

extension View {
    func keyboardAdaptive() -> some View {
        return self.modifier(KeyboardAdaptive())
    }
} 