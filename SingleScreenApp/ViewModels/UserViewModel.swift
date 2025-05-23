import Foundation
import SwiftUI
import Combine

@MainActor
class UserViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    
    @Published var createUserState: ViewState<UserCreateResponse> = .idle
    @Published var fetchUserState: ViewState<User> = .idle
    @Published var showSuccessToast = false
    @Published var isNetworkAvailable = true
    
    private let userService = UserService.shared
    private let networkMonitor = NetworkMonitor()
    private var cancellables = Set<AnyCancellable>()
    private var toastTask: Task<Void, Never>?
    
    var isLoading: Bool {
        createUserState.isLoading || fetchUserState.isLoading
    }
    
    var errorMessage: String? {
        createUserState.error ?? fetchUserState.error
    }
    
    var createdUser: UserCreateResponse? {
        createUserState.value
    }
    
    var fetchedUser: User? {
        fetchUserState.value
    }
    
    var isFormValid: Bool {
        !name.isEmpty && isValidEmail(email)
    }
    
    init() {
        setupNetworkMonitoring()
    }
    
    deinit {
        cancelToastTask()
    }
    
    func setupNetworkMonitoring() {
        networkMonitor.$isConnected
            .receive(on: RunLoop.main)
            .sink { [weak self] isConnected in
                self?.isNetworkAvailable = isConnected
                
                if !isConnected {
                    if self?.createUserState.isLoading == true {
                        self?.createUserState = .error("No internet connection")
                    }
                    
                    if self?.fetchUserState.isLoading == true {
                        self?.fetchUserState = .error("No internet connection")
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return email.isEmpty ? false : emailPredicate.evaluate(with: email)
    }
    
    private func cancelToastTask() {
        toastTask?.cancel()
        toastTask = nil
    }
    
    private func scheduleToastDismissal() {
        cancelToastTask()
        
        toastTask = Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            if !Task.isCancelled {
                showSuccessToast = false
            }
        }
    }
    
    func submitUser() async {
        if !isNetworkAvailable {
            createUserState = .error("No internet connection")
            generateHapticFeedback(.error)
            return
        }
        
        createUserState = .loading
        
        do {
            // Use the predefined values for Ronit
            let response = try await userService.createUser(name: "Ronit", email: "ronit@example.com")
            createUserState = .success(response)
            generateHapticFeedback(.success)
            showSuccessToast = true
            
            // Auto-dismiss the success toast after 3 seconds
            scheduleToastDismissal()
        } catch let error as APIError {
            createUserState = .error(error.description)
            generateHapticFeedback(.error)
        } catch {
            createUserState = .error(error.localizedDescription)
            generateHapticFeedback(.error)
        }
    }
    
    func submitCustomUser() async {
        if !isNetworkAvailable {
            createUserState = .error("No internet connection")
            generateHapticFeedback(.error)
            return
        }
        
        createUserState = .loading
        
        do {
            let response = try await userService.createUser(name: name, email: email)
            createUserState = .success(response)
            generateHapticFeedback(.success)
            showSuccessToast = true
            
            // Auto-dismiss the success toast after 3 seconds
            scheduleToastDismissal()
        } catch let error as APIError {
            createUserState = .error(error.description)
            generateHapticFeedback(.error)
        } catch {
            createUserState = .error(error.localizedDescription)
            generateHapticFeedback(.error)
        }
    }
    
    func fetchRandomUser() async {
        if !isNetworkAvailable {
            fetchUserState = .error("No internet connection")
            generateHapticFeedback(.error)
            return
        }
        
        let randomID = Int.random(in: 1...12)
        await fetchUser(id: randomID)
    }
    
    func fetchUser(id: Int) async {
        fetchUserState = .loading
        
        do {
            let user = try await userService.fetchUser(id: id)
            fetchUserState = .success(user)
            generateHapticFeedback(.success)
        } catch let error as APIError {
            fetchUserState = .error(error.description)
            generateHapticFeedback(.error)
        } catch {
            fetchUserState = .error(error.localizedDescription)
            generateHapticFeedback(.error)
        }
    }
    
    func generateHapticFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func resetCreateUserState() {
        createUserState = .idle
    }
    
    func resetFetchUserState() {
        fetchUserState = .idle
    }
} 