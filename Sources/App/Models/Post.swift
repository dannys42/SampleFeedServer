import FluentSQLite
import Vapor

/// A single entry of a post list.
final class Post: SQLiteModel {
    /// The unique identifier for this `Post`.
    var id: Int?

    /// Reference to the wall that this Post belongs to.
    var wallId: Wall.ID

    /// The text content of this `Post`.
    var text: String
    
    /// Reference to user that created this POST.
    var userId: User.ID
    
    /// Creates a new `Post`.
    init(id: Int? = nil, wallId: Wall.ID, text: String, userId: User.ID) {
        self.id = id
        self.text = text
        self.userId = userId
        self.wallId = wallId
    }
}

extension Post {
    /// Fluent relation to user that owns this post.
    var user: Parent<Post, User> {
        return parent(\.userId)
    }
    /// Fluent relation to the wall that owns this post.
    var wall: Parent<Post, Wall> {
        return parent(\.wallId)
    }
}

/// Allows `Wall` to be used as a Fluent migration.
extension Post: Migration {
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.create(Post.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.text)
            builder.field(for: \.userId)
            builder.field(for: \.wallId)
            builder.reference(from: \.userId, to: \User.id)
            builder.reference(from: \.wallId, to: \Wall.id)
        }
    }
}

/// Allows `Post` to be encoded to and decoded from HTTP messages.
extension Post: Content { }

/// Allows `Post` to be used as a dynamic parameter in route definitions.
extension Post: Parameter { }
