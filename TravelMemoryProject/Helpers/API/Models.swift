
import Foundation

public struct RandomFact: Codable {
    public var _id: String?
    public var __v: Int?
    public var user: String?
    public var text: String?
    public var updatedAt: String?
    public var createdAt: String?
    public var deleted: Bool?
    public var source: Source?
    public var status: Status?
    public var used: Bool?
    public var type: String?
    
    public enum Source: String, Codable {
        case user
        case api
    }
    
    public struct Status: Codable {
        public var verified: Bool?
        public var sentCount: Int?
    }
}


// MARK: - LoginModel
public struct LoginModel: Codable {
    let status: Bool
    let message: String
    let data: DataClass
}

// MARK: - DataClass
public struct DataClass: Codable {
    let id: Int
    let name, email: String
    let emailVerifiedAt: JSONNull?
    let createdAt, updatedAt, token: String

    enum CodingKeys: String, CodingKey {
        case id, name, email
        case emailVerifiedAt = "email_verified_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case token
    }
}
// MARK: - RegisterModel
public struct RegisterModel: Codable {
    let status: Bool
    let message: String
    let data: RegisterData
}

// MARK: - RegisterModel
public struct RegisterData: Codable {
    let name, email, updatedAt, createdAt: String
    let id: Int
    let token: String

    enum CodingKeys: String, CodingKey {
        case name, email
        case updatedAt = "updated_at"
        case createdAt = "created_at"
        case id, token
    }
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
