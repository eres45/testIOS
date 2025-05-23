import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = UserViewModel()
    @State private var activeTab = 0
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background color that adapts to light/dark mode
                Group {
                    if colorScheme == .dark {
                        Color.black.opacity(0.9)
                    } else {
                        NeumorphicStyle.backgroundColor
                    }
                }
                .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: adaptiveSpacing(for: geometry)) {
                    Picker("Mode", selection: $activeTab) {
                        Text("Create User").tag(0)
                        Text("Fetch User").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .padding(.top, adaptiveTopPadding(for: geometry))
                    
                    // Network status indicator
                    if !viewModel.isNetworkAvailable {
                        HStack {
                            Image(systemName: "wifi.slash")
                            Text("No internet connection")
                        }
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 12)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(12)
                    }
                    
                    TabView(selection: $activeTab) {
                        // Create User Tab
                        if !viewModel.isNetworkAvailable && viewModel.createUserState != .loading {
                            NoInternetView {
                                // Retry action
                                viewModel.setupNetworkMonitoring()
                            }
                            .tag(0)
                        } else {
                            CreateUserView(viewModel: viewModel)
                                .tag(0)
                        }
                        
                        // Fetch User Tab
                        if !viewModel.isNetworkAvailable && viewModel.fetchUserState != .loading {
                            NoInternetView {
                                // Retry action
                                viewModel.setupNetworkMonitoring()
                            }
                            .tag(1)
                        } else {
                            FetchUserView(viewModel: viewModel)
                                .tag(1)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut, value: activeTab)
                }
                .background(colorScheme == .dark ? Color.black.opacity(0.9) : NeumorphicStyle.backgroundColor)
                .navigationTitle("User API Demo")
                
                // Toast notifications
                VStack {
                    Spacer()
                    
                    if viewModel.showSuccessToast {
                        ToastView(
                            type: .success,
                            title: "Success!",
                            message: "User created successfully"
                        ) {
                            viewModel.showSuccessToast = false
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.spring(), value: viewModel.showSuccessToast)
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        ToastView(
                            type: .error,
                            title: "Error",
                            message: errorMessage
                        ) {
                            // Reset the error state
                            if viewModel.createUserState.error != nil {
                                viewModel.resetCreateUserState()
                            } else {
                                viewModel.resetFetchUserState()
                            }
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.spring(), value: viewModel.errorMessage)
                    }
                }
                .padding(.bottom)
            }
        }
    }
    
    // Adaptive spacing based on device size
    private func adaptiveSpacing(for geometry: GeometryProxy) -> CGFloat {
        let screenHeight = geometry.size.height
        
        if screenHeight < 700 { // iPhone SE and smaller
            return 8
        } else if screenHeight < 850 { // Standard iPhones
            return 16
        } else { // Pro Max and larger
            return 24
        }
    }
    
    // Adaptive top padding based on device size
    private func adaptiveTopPadding(for geometry: GeometryProxy) -> CGFloat {
        let screenHeight = geometry.size.height
        
        if screenHeight < 700 { // iPhone SE and smaller
            return 8
        } else if screenHeight < 850 { // Standard iPhones
            return 16
        } else { // Pro Max and larger
            return 24
        }
    }
}

struct CreateUserView: View {
    @ObservedObject var viewModel: UserViewModel
    @FocusState private var focusedField: Field?
    @State private var useCustomValues = false
    @Environment(\.colorScheme) var colorScheme
    
    enum Field {
        case name, email
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: adaptiveSpacing(for: geometry)) {
                    Text("Create User")
                        .font(adaptiveFont(for: geometry, style: .title2))
                        .fontWeight(.bold)
                    
                    StateDisplayView(state: viewModel.createUserState, title: "Create User State")
                        .padding(.bottom, adaptiveSpacing(for: geometry) / 2)
                    
                    VStack(spacing: adaptiveSpacing(for: geometry)) {
                        Toggle("Use custom values", isOn: $useCustomValues)
                            .padding(.horizontal, 10)
                        
                        if useCustomValues {
                            NeumorphicTextField(
                                placeholder: "Name",
                                text: $viewModel.name,
                                isValid: !viewModel.name.isEmpty || viewModel.name.isEmpty,
                                validationMessage: "Name is required"
                            )
                            .focused($focusedField, equals: .name)
                            .submitLabel(.next)
                            .onChange(of: viewModel.name) { _ in
                                withAnimation {
                                    // Field validation is handled in isValid
                                }
                            }
                            
                            NeumorphicTextField(
                                placeholder: "Email",
                                text: $viewModel.email,
                                isValid: viewModel.isFormValid || viewModel.email.isEmpty,
                                validationMessage: "Please enter a valid email address"
                            )
                            .focused($focusedField, equals: .email)
                            .submitLabel(.done)
                            .keyboardType(.emailAddress)
                            .onChange(of: viewModel.email) { _ in
                                withAnimation {
                                    // Field validation is handled in isValid
                                }
                            }
                            
                            AsyncButtonView(
                                text: "Submit",
                                isDisabled: !viewModel.isFormValid,
                                isLoading: viewModel.createUserState.isLoading
                            ) {
                                focusedField = nil // Dismiss keyboard
                                Task {
                                    await viewModel.submitCustomUser()
                                }
                            }
                            .padding(.top, adaptiveSpacing(for: geometry))
                        } else {
                            // Show default values
                            InfoRow(label: "Name", value: "Ronit")
                            InfoRow(label: "Email", value: "ronit@example.com")
                            
                            AsyncButtonView(
                                text: "Submit",
                                isLoading: viewModel.createUserState.isLoading
                            ) {
                                focusedField = nil // Dismiss keyboard
                                Task {
                                    await viewModel.submitUser()
                                }
                            }
                            .padding(.top, adaptiveSpacing(for: geometry))
                        }
                    }
                    .padding(adaptivePadding(for: geometry))
                    .background(colorScheme == .dark ? darkModeBackground() : NeumorphicStyle.background())
                    .padding(.horizontal)
                    
                    if let user = viewModel.createdUser {
                        VStack(spacing: adaptiveSpacing(for: geometry) / 1.5) {
                            Text("User Created!")
                                .font(adaptiveFont(for: geometry, style: .headline))
                                .padding(.top, adaptiveSpacing(for: geometry) / 2)
                            
                            VStack(alignment: .leading, spacing: adaptiveSpacing(for: geometry) / 2) {
                                InfoRow(label: "Name", value: user.name)
                                if let email = user.email {
                                    InfoRow(label: "Email", value: email)
                                }
                                InfoRow(label: "ID", value: user.id)
                                InfoRow(label: "Created", value: formatDate(user.createdAt))
                            }
                        }
                        .padding(adaptivePadding(for: geometry))
                        .frame(maxWidth: .infinity)
                        .background(colorScheme == .dark ? darkModeBackground() : NeumorphicStyle.background())
                        .padding(.horizontal)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .animation(.spring(), value: viewModel.createdUser)
                    }
                }
                .padding(.vertical, adaptivePadding(for: geometry) / 2)
            }
            .dismissKeyboard()
            .keyboardAdaptive()
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func adaptiveSpacing(for geometry: GeometryProxy) -> CGFloat {
        let screenHeight = geometry.size.height
        
        if screenHeight < 700 { // iPhone SE and smaller
            return 12
        } else if screenHeight < 850 { // Standard iPhones
            return 20
        } else { // Pro Max and larger
            return 24
        }
    }
    
    private func adaptivePadding(for geometry: GeometryProxy) -> CGFloat {
        let screenHeight = geometry.size.height
        
        if screenHeight < 700 { // iPhone SE and smaller
            return 12
        } else if screenHeight < 850 { // Standard iPhones
            return 16
        } else { // Pro Max and larger
            return 20
        }
    }
    
    private func adaptiveFont(for geometry: GeometryProxy, style: Font.TextStyle) -> Font {
        let screenHeight = geometry.size.height
        
        if screenHeight < 700 { // iPhone SE and smaller
            switch style {
            case .title: return .title2
            case .title2: return .title3
            case .headline: return .headline
            case .body: return .subheadline
            default: return .body
            }
        } else {
            return Font(style)
        }
    }
    
    private func darkModeBackground() -> some View {
        RoundedRectangle(cornerRadius: NeumorphicStyle.borderRadius)
            .fill(Color(UIColor.systemGray6))
            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
    }
}

struct FetchUserView: View {
    @ObservedObject var viewModel: UserViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: adaptiveSpacing(for: geometry)) {
                    Text("Fetch User")
                        .font(adaptiveFont(for: geometry, style: .title2))
                        .fontWeight(.bold)
                    
                    StateDisplayView(state: viewModel.fetchUserState, title: "Fetch User State")
                        .padding(.bottom, adaptiveSpacing(for: geometry) / 2)
                    
                    AsyncButtonView(
                        text: "Fetch Random User",
                        isLoading: viewModel.fetchUserState.isLoading
                    ) {
                        Task {
                            await viewModel.fetchRandomUser()
                        }
                    }
                    .padding(.horizontal, adaptivePadding(for: geometry) + 12)
                    
                    if let user = viewModel.fetchedUser {
                        VStack(alignment: .center, spacing: adaptiveSpacing(for: geometry)) {
                            AsyncImage(url: URL(string: user.avatar)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: adaptiveImageSize(for: geometry), height: adaptiveImageSize(for: geometry))
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: adaptiveImageSize(for: geometry), height: adaptiveImageSize(for: geometry))
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(NeumorphicStyle.primaryColor, lineWidth: 3)
                                                .padding(-3)
                                        )
                                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                                case .failure:
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .padding(25)
                                        .frame(width: adaptiveImageSize(for: geometry), height: adaptiveImageSize(for: geometry))
                                        .background(Color.gray.opacity(0.2))
                                        .clipShape(Circle())
                                        .foregroundColor(.gray)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: adaptiveImageSize(for: geometry), height: adaptiveImageSize(for: geometry))
                            
                            VStack(spacing: adaptiveSpacing(for: geometry) / 3) {
                                Text("\(user.firstName) \(user.lastName)")
                                    .font(adaptiveFont(for: geometry, style: .title2))
                                    .fontWeight(.bold)
                                
                                Text(user.email)
                                    .foregroundColor(.secondary)
                                    .font(adaptiveFont(for: geometry, style: .subheadline))
                            }
                            
                            Text("User ID: \(user.id)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, adaptiveSpacing(for: geometry) / 4)
                        }
                        .padding(adaptivePadding(for: geometry))
                        .background(colorScheme == .dark ? darkModeBackground() : NeumorphicStyle.background())
                        .padding(.horizontal)
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.fetchedUser?.id)
                    } else if !viewModel.fetchUserState.isLoading {
                        VStack(spacing: adaptiveSpacing(for: geometry)) {
                            Image(systemName: "person.slash")
                                .font(.system(size: adaptiveIconSize(for: geometry)))
                                .foregroundColor(.gray.opacity(0.5))
                                .padding()
                            
                            Text("No User Data")
                                .font(adaptiveFont(for: geometry, style: .headline))
                            
                            Text("Tap the button above to fetch a random user from the API.")
                                .font(adaptiveFont(for: geometry, style: .subheadline))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(adaptivePadding(for: geometry) + 10)
                        .frame(maxWidth: .infinity)
                        .background(colorScheme == .dark ? darkModeBackground() : NeumorphicStyle.background())
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, adaptivePadding(for: geometry) / 2)
            }
        }
    }
    
    private func adaptiveSpacing(for geometry: GeometryProxy) -> CGFloat {
        let screenHeight = geometry.size.height
        
        if screenHeight < 700 { // iPhone SE and smaller
            return 12
        } else if screenHeight < 850 { // Standard iPhones
            return 20
        } else { // Pro Max and larger
            return 24
        }
    }
    
    private func adaptivePadding(for geometry: GeometryProxy) -> CGFloat {
        let screenHeight = geometry.size.height
        
        if screenHeight < 700 { // iPhone SE and smaller
            return 12
        } else if screenHeight < 850 { // Standard iPhones
            return 16
        } else { // Pro Max and larger
            return 20
        }
    }
    
    private func adaptiveImageSize(for geometry: GeometryProxy) -> CGFloat {
        let screenHeight = geometry.size.height
        
        if screenHeight < 700 { // iPhone SE and smaller
            return 100
        } else if screenHeight < 850 { // Standard iPhones
            return 120
        } else { // Pro Max and larger
            return 140
        }
    }
    
    private func adaptiveIconSize(for geometry: GeometryProxy) -> CGFloat {
        let screenHeight = geometry.size.height
        
        if screenHeight < 700 { // iPhone SE and smaller
            return 40
        } else if screenHeight < 850 { // Standard iPhones
            return 50
        } else { // Pro Max and larger
            return 60
        }
    }
    
    private func adaptiveFont(for geometry: GeometryProxy, style: Font.TextStyle) -> Font {
        let screenHeight = geometry.size.height
        
        if screenHeight < 700 { // iPhone SE and smaller
            switch style {
            case .title: return .title2
            case .title2: return .title3
            case .headline: return .headline
            case .body: return .subheadline
            default: return .body
            }
        } else {
            return Font(style)
        }
    }
    
    private func darkModeBackground() -> some View {
        RoundedRectangle(cornerRadius: NeumorphicStyle.borderRadius)
            .fill(Color(UIColor.systemGray6))
            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
    }
}

struct AsyncButtonView: View {
    var text: String
    var isDisabled: Bool = false
    var isLoading: Bool = false
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Text(text)
                    .fontWeight(.semibold)
                    .foregroundColor(isDisabled ? .gray.opacity(0.5) : NeumorphicStyle.primaryColor)
                    .opacity(isLoading ? 0 : 1)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(NeumorphicStyle.primaryColor)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(NeumorphicStyle.background())
            .opacity(isDisabled ? 0.7 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled || isLoading)
        .animation(.spring(response: 0.3), value: isLoading)
    }
}

struct InfoRow: View {
    var label: String
    var value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
            
            Spacer()
        }
    }
} 