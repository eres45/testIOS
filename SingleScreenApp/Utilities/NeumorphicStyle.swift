import SwiftUI

struct NeumorphicStyle {
    // Dynamic colors that adapt to dark mode
    static var backgroundColor: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? 
                UIColor.systemBackground : UIColor.systemGray6
        })
    }
    
    static var shadowColor: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? 
                UIColor.black.withAlphaComponent(0.3) : UIColor.black.withAlphaComponent(0.2)
        })
    }
    
    static var highlightColor: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? 
                UIColor.systemGray.withAlphaComponent(0.5) : UIColor.white.withAlphaComponent(0.8)
        })
    }
    
    static var primaryColor = Color.blue
    static var secondaryColor = Color.orange
    static var errorColor = Color.red
    static var textColor = Color.primary
    static let borderRadius: CGFloat = 16
    
    @ViewBuilder
    static func background(_ isPressed: Bool = false) -> some View {
        ZStack {
            if UITraitCollection.current.userInterfaceStyle == .dark {
                darkModeBackground(isPressed)
            } else {
                lightModeBackground(isPressed)
            }
        }
    }
    
    @ViewBuilder
    static func darkModeBackground(_ isPressed: Bool = false) -> some View {
        RoundedRectangle(cornerRadius: borderRadius)
            .fill(Color(UIColor.systemGray6))
            .shadow(color: shadowColor, radius: isPressed ? 1 : 5, x: isPressed ? -1 : -3, y: isPressed ? -1 : -3)
            .shadow(color: Color.black.opacity(0.4), radius: isPressed ? 1 : 5, x: isPressed ? 1 : 3, y: isPressed ? 1 : 3)
    }
    
    @ViewBuilder
    static func lightModeBackground(_ isPressed: Bool = false) -> some View {
        RoundedRectangle(cornerRadius: borderRadius)
            .fill(backgroundColor)
            .shadow(color: shadowColor, radius: isPressed ? 2 : 8, x: isPressed ? -2 : -8, y: isPressed ? -2 : -8)
            .shadow(color: highlightColor, radius: isPressed ? 2 : 8, x: isPressed ? 2 : 8, y: isPressed ? 2 : 8)
            .overlay(
                RoundedRectangle(cornerRadius: borderRadius)
                    .stroke(isPressed ? highlightColor.opacity(0.2) : shadowColor.opacity(0.1), lineWidth: 2)
            )
    }
    
    static func pressedBackground() -> some View {
        background(true)
    }
    
    @ViewBuilder
    static func textFieldBackground() -> some View {
        if UITraitCollection.current.userInterfaceStyle == .dark {
            darkModeTextFieldBackground()
        } else {
            lightModeTextFieldBackground()
        }
    }
    
    @ViewBuilder
    static func darkModeTextFieldBackground() -> some View {
        RoundedRectangle(cornerRadius: borderRadius - 4)
            .fill(Color(UIColor.systemGray5))
            .shadow(color: shadowColor.opacity(0.4), radius: 2, x: 2, y: 2)
            .shadow(color: Color.black.opacity(0.2), radius: 2, x: -2, y: -2)
            .overlay(
                RoundedRectangle(cornerRadius: borderRadius - 4)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .padding(1)
    }
    
    @ViewBuilder
    static func lightModeTextFieldBackground() -> some View {
        RoundedRectangle(cornerRadius: borderRadius - 4)
            .fill(backgroundColor)
            .shadow(color: shadowColor.opacity(0.5), radius: 3, x: 3, y: 3)
            .shadow(color: highlightColor, radius: 3, x: -3, y: -3)
            .overlay(
                RoundedRectangle(cornerRadius: borderRadius - 4)
                    .stroke(shadowColor.opacity(0.2), lineWidth: 1)
            )
            .padding(1)
    }
}

struct NeumorphicTextField: View {
    var placeholder: String
    @Binding var text: String
    var isValid: Bool = true
    var validationMessage: String?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(colorScheme == .dark ? .gray : .gray.opacity(0.7))
                        .padding(.leading, 10)
                }
                
                TextField("", text: $text)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 12)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
            }
            .background(NeumorphicStyle.textFieldBackground())
            
            if !isValid && text.count > 0, let message = validationMessage {
                Text(message)
                    .font(.caption)
                    .foregroundColor(NeumorphicStyle.errorColor)
                    .padding(.leading, 10)
                    .transition(.opacity)
            }
        }
    }
}

struct NeumorphicSecureField: View {
    var placeholder: String
    @Binding var text: String
    var isValid: Bool = true
    var validationMessage: String?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(colorScheme == .dark ? .gray : .gray.opacity(0.7))
                        .padding(.leading, 10)
                }
                
                SecureField("", text: $text)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 12)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
            }
            .background(NeumorphicStyle.textFieldBackground())
            
            if !isValid && text.count > 0, let message = validationMessage {
                Text(message)
                    .font(.caption)
                    .foregroundColor(NeumorphicStyle.errorColor)
                    .padding(.leading, 10)
                    .transition(.opacity)
            }
        }
    }
}

struct NeumorphicButton: View {
    var text: String
    var isDisabled: Bool = false
    var action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            if !isDisabled {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                action()
            }
        }) {
            Text(text)
                .fontWeight(.semibold)
                .foregroundColor(getTextColor())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Group {
                        if isPressed && !isDisabled {
                            NeumorphicStyle.pressedBackground()
                        } else {
                            NeumorphicStyle.background()
                        }
                    }
                )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled)
        .scaleEffect(isPressed && !isDisabled ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: 0,
            pressing: { pressing in
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.isPressed = pressing
                }
            },
            perform: { }
        )
    }
    
    private func getTextColor() -> Color {
        if isDisabled {
            return .gray
        }
        return colorScheme == .dark ? .white : NeumorphicStyle.primaryColor
    }
} 