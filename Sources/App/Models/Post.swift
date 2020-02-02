import FluentSQLite
import Vapor

/// A single entry of a post list.
final class Post: SQLiteModel {
    /// The unique identifier for this `Post`.
    var id: Int?

    /// Reference to the wall that this Post belongs to.
    var wallId: Wall.ID

    /// A title describing what this `Post` entails.
    var title: String
    
    /// Reference to user that created this POST.
    var userId: User.ID
    
    /// Creates a new `Post`.
    init(id: Int? = nil, wallId: Wall.ID, title: String, userId: User.ID) {
        self.id = id
        self.title = title
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
            builder.field(for: \.title)
            builder.field(for: \.userId)
            builder.reference(from: \.userId, to: \User.id)
        }
    }
}

/// Allows `Wall` to be encoded to and decoded from HTTP messages.
extension Post: Content { }

/// Allows `Wall` to be used as a dynamic parameter in route definitions.
extension Post: Parameter { }
