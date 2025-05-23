import XCTest
@testable import SingleScreenApp

class UserServiceTests: XCTestCase {
    var userService: UserService!
    var mockURLSession: MockURLSession!

    override func setUp() {
        super.setUp()
        mockURLSession = MockURLSession()
        userService = UserService(urlSession: mockURLSession)
    }

    override func tearDown() {
        userService = nil
        mockURLSession = nil
        super.tearDown()
    }
    
    func testCreateUserSuccess() async throws {
        // Arrange
        let name = "Ronit"
        let email = "ronit@example.com"
        
        let jsonString = """
        {
            "name": "Ronit",
            "email": "ronit@example.com",
            "id": "123",
            "createdAt": "2023-01-01T12:00:00.000Z"
        }
        """
        let jsonData = jsonString.data(using: .utf8)!
        
        mockURLSession.mockData = jsonData
        mockURLSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://reqres.in/api/users")!,
            statusCode: 201,
            httpVersion: nil,
            headerFields: nil
        )
        
        // Act
        let result = try await userService.createUser(name: name, email: email)
        
        // Assert
        XCTAssertEqual(result.name, "Ronit")
        XCTAssertEqual(result.email, "ronit@example.com")
        XCTAssertEqual(result.id, "123")
        XCTAssertEqual(result.createdAt, "2023-01-01T12:00:00.000Z")
    }
    
    func testCreateUserNetworkError() async {
        // Arrange
        let name = "Ronit"
        let email = "ronit@example.com"
        
        mockURLSession.mockError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        
        // Act & Assert
        do {
            _ = try await userService.createUser(name: name, email: email)
            XCTFail("Expected network error but call succeeded")
        } catch let error as APIError {
            XCTAssertEqual(error, APIError.noInternet)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testFetchUserSuccess() async throws {
        // Arrange
        let userId = 2
        
        let jsonString = """
        {
            "data": {
                "id": 2,
                "email": "janet.weaver@reqres.in",
                "first_name": "Janet",
                "last_name": "Weaver",
                "avatar": "https://reqres.in/img/faces/2-image.jpg"
            },
            "support": {
                "url": "https://reqres.in/#support-heading",
                "text": "To keep ReqRes free, contributions towards server costs are appreciated!"
            }
        }
        """
        let jsonData = jsonString.data(using: .utf8)!
        
        mockURLSession.mockData = jsonData
        mockURLSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://reqres.in/api/users/2")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // Act
        let result = try await userService.fetchUser(id: userId)
        
        // Assert
        XCTAssertEqual(result.id, 2)
        XCTAssertEqual(result.email, "janet.weaver@reqres.in")
        XCTAssertEqual(result.firstName, "Janet")
        XCTAssertEqual(result.lastName, "Weaver")
        XCTAssertEqual(result.avatar, "https://reqres.in/img/faces/2-image.jpg")
    }
    
    func testFetchUserNotFound() async {
        // Arrange
        let userId = 999 // Non-existent user
        
        mockURLSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://reqres.in/api/users/999")!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )
        
        // Act & Assert
        do {
            _ = try await userService.fetchUser(id: userId)
            XCTFail("Expected not found error but call succeeded")
        } catch let error as APIError {
            XCTAssertEqual(error, APIError.serverError(404))
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}

// Mock URLSession for testing
class MockURLSession: URLSessionProtocol {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        
        guard let data = mockData, let response = mockResponse else {
            throw APIError.invalidResponse
        }
        
        return (data, response)
    }
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        
        guard let data = mockData, let response = mockResponse else {
            throw APIError.invalidResponse
        }
        
        return (data, response)
    }
} 