import Foundation

enum APIError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case invalidData
    case networkError(Error)
    case noInternet
    case timeout
    case serverError(Int)
    
    var description: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .invalidData:
            return "Invalid data received"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .noInternet:
            return "No internet connection"
        case .timeout:
            return "Request timed out"
        case .serverError(let code):
            return "Server error: \(code)"
        }
    }
    
    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.invalidData, .invalidData),
             (.noInternet, .noInternet),
             (.timeout, .timeout):
            return true
        case (.serverError(let lhsCode), .serverError(let rhsCode)):
            return lhsCode == rhsCode
        case (.networkError(let lhsError), .networkError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

class APIService {
    static let shared = APIService()
    private let baseURL = "https://reqres.in/api"
    private let networkMonitor: NetworkMonitor
    private let urlSession: URLSessionProtocol
    
    init(urlSession: URLSessionProtocol = URLSession.shared, networkMonitor: NetworkMonitor = NetworkMonitor()) {
        self.urlSession = urlSession
        self.networkMonitor = networkMonitor
    }
    
    func fetchUser(id: Int) async throws -> User {
        guard let url = URL(string: "\(baseURL)/users/\(id)") else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await urlSession.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw APIError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            let userResponse = try decoder.decode(UserResponse.self, from: data)
            return userResponse.data
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func createUser(request: UserRequest) async throws -> UserCreateResponse {
        guard let url = URL(string: "\(baseURL)/users") else {
            throw APIError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            urlRequest.httpBody = try encoder.encode(request)
            
            let (data, response) = try await urlSession.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw APIError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            return try decoder.decode(UserCreateResponse.self, from: data)
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func request<T: Decodable>(
        url: URL,
        method: HTTPMethod,
        body: Data? = nil,
        timeoutInterval: TimeInterval = 30,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        if !networkMonitor.isConnected {
            throw APIError.noInternet
        }
        
        var request = URLRequest(url: url, timeoutInterval: timeoutInterval)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = body
        }
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    return try decoder.decode(T.self, from: data)
                } catch {
                    print("Decoding error: \(error)")
                    throw APIError.invalidData
                }
            case 401:
                throw APIError.serverError(401)
            case 404:
                throw APIError.serverError(404)
            case 500...599:
                throw APIError.serverError(httpResponse.statusCode)
            default:
                throw APIError.invalidResponse
            }
        } catch let error as APIError {
            throw error
        } catch let urlError as URLError {
            if urlError.code == .timedOut {
                throw APIError.timeout
            } else if urlError.code == .notConnectedToInternet {
                throw APIError.noInternet
            } else {
                throw APIError.networkError(urlError)
            }
        } catch {
            throw APIError.networkError(error)
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
} 