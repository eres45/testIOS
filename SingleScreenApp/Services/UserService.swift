import Foundation

class UserService {
    static let shared = UserService()
    private let baseURL = "https://reqres.in/api"
    private let apiService: APIService
    private let urlSession: URLSessionProtocol
    
    init(urlSession: URLSessionProtocol = URLSession.shared) {
        self.urlSession = urlSession
        self.apiService = APIService(urlSession: urlSession)
    }
    
    func createUser(name: String, email: String) async throws -> UserCreateResponse {
        guard let url = URL(string: "\(baseURL)/users") else {
            throw APIError.invalidURL
        }
        
        let body = [
            "name": name,
            "email": email
        ]
        
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: body)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            return try await apiService.request(
                url: url,
                method: .post,
                body: bodyData,
                decoder: decoder
            )
        } catch {
            print("Error creating user: \(error)")
            throw error
        }
    }
    
    func fetchUser(id: Int) async throws -> User {
        guard let url = URL(string: "\(baseURL)/users/\(id)") else {
            throw APIError.invalidURL
        }
        
        do {
            let response: UserResponse = try await apiService.request(
                url: url,
                method: .get
            )
            return response.data
        } catch {
            print("Error fetching user: \(error)")
            throw error
        }
    }
} 