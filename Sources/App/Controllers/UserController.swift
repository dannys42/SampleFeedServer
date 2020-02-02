import Crypto
import Vapor
import FluentSQLite

/// Creates new users and logs them in.
final class UserController {
    /// Logs a user in, returning a token for accessing protected endpoints.
    func login(_ req: Request) throws -> Future<UserToken> {
        // get user auth'd by basic auth middleware
        let user = try req.requireAuthenticated(User.self)
        
        // create new token for this user
        let token = try UserToken.create(userID: user.requireID())
        
        // save and return token
        return token.save(on: req)
    }
    
    /// Creates a new user.
    func create(_ req: Request) throws -> Future<UserResponse> {
        print("Attempt to create user: \(req)")
        // decode request content
        return try req.content.decode(CreateUserRequest.self).flatMap { user -> Future<User> in
            // Check if user already exists.
            // Ref: https://stackoverflow.com/questions/58466181/vapor-3-how-to-check-for-similar-email-before-saving-object
            return User.query(on: req).filter(\.email == user.email).first().flatMap { existingUser in
                guard existingUser == nil else {
                    throw Abort(.conflict, reason: "A user with this email already exists")
                }
                
                // hash user's password using BCrypt
                let hash = try BCrypt.hash(user.password)
                
                // save new user
                return User(id: nil, name: user.name, email: user.email, passwordHash: hash)
                    .save(on: req)
            }
        }.map { user in
            // map to public user response (omits password hash)
            return try UserResponse(id: user.requireID(), name: user.name, email: user.email)
        }
    }
}

// MARK: Content

/// Data required to create a user.
struct CreateUserRequest: Content {
    /// User's full name.
    var name: String
    
    /// User's email address.
    var email: String
    
    /// User's desired password.
    var password: String
    
}

/// Public representation of user data.
struct UserResponse: Content {
    /// User's unique identifier.
    /// Not optional since we only return users that exist in the DB.
    var id: Int
    
    /// User's full name.
    var name: String
    
    /// User's email address.
    var email: String
}
