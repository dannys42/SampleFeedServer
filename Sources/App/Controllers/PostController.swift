import Vapor
import FluentSQLite

/// Simple Post-list controller.
final class PostController {
    
    /// Returns a list of all posts on the given wall
    func index(_ req: Request) throws -> Future<[Post]> {
        // fetch auth'd user
        let _ = try req.requireAuthenticated(User.self)
        
        let wallId = try req.parameters.next(Int.self)

        // TODO: Ensure user is a meber of the wall
        
        // query all posts's belonging to this wall
        return Post.query(on: req)
            .filter(\.wallId == wallId).all()
    }

    /// Creates a new post for the auth'd user.
    func create(_ req: Request) throws -> Future<Post> {
        // fetch auth'd user
        let user = try req.requireAuthenticated(User.self)
        
        let wallId = try req.parameters.next(Int.self)

        // decode request content
        return try req.content.decode(CreatePostRequest.self).flatMap { post in
            // save new post
            return try Post(wallId: wallId, text: post.text, userId: user.requireID())
                .save(on: req)
        }
    }

    /// Deletes an existing post for the auth'd user.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        // fetch auth'd user
        let user = try req.requireAuthenticated(User.self)
        
        // decode request parameter (posts/:id)
        return try req.parameters.next(Post.self).flatMap { post -> Future<Void> in
            // ensure the post being deleted belongs to this user
            guard try post.userId == user.requireID() else {
                throw Abort(.forbidden)
            }
            
            // delete model
            return post.delete(on: req)
        }.transform(to: .ok)
    }
}

// MARK: Content

/// Represents data required to create a new post.
struct CreatePostRequest: Content {
    /// Post text.
    var text: String
}
