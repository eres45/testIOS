import Foundation

struct UserResponse: Codable {
    let data: User
    let support: Support
}

struct User: Codable, Identifiable {
    let id: Int
    let email: String
    let firstName: String
    let lastName: String
    let avatar: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case avatar
    }
}

struct Support: Codable {
    let url: String
    let text: String
}

struct UserRequest: Codable {
    let name: String
    let email: String
}

struct UserCreateResponse: Codable {
    let name: String
    let email: String?
    let job: String?
    let id: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case email
        case job
        case id
        case createdAt = "createdAt"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        
        // Handle either email or job being present
        if let emailValue = try? container.decodeIfPresent(String.self, forKey: .email) {
            email = emailValue
            job = nil
        } else if let jobValue = try? container.decodeIfPresent(String.self, forKey: .job) {
            job = jobValue
            email = jobValue // Map job to email as per our workaround
        } else {
            email = nil
            job = nil
        }
        
        id = try container.decode(String.self, forKey: .id)
        createdAt = try container.decode(String.self, forKey: .createdAt)
    }
} 