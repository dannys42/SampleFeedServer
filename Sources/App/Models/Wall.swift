//
//  Wall.swift
//  
//
//  Created by Danny Sung on 01/30/2020.
//

import Foundation

import FluentSQLite
import Vapor

/// A wall which may contain posts
final class Wall: SQLiteModel {
    /// The unique identifier for this `Wall`.
    var id: Int?

    /// A summary describing what this `Wall` is about.
    var topic: String

    /// A public `Wall` does not require authentication to view.  (TODO: currently unsupported)
    var isPublic: Bool

    /// Reference to user that owns this `Wall`.
    var userID: User.ID
    
    /// Creates a new `Wall`.
    init(id: Int? = nil, topic: String, isPublic: Bool, userID: User.ID) {
        self.id = id
        self.topic = topic
        self.isPublic = isPublic
        self.userID = userID
    }
}

extension Wall {
    /// Fluent relation to user that owns this wall.
    var user: Parent<Wall, User> {
        return parent(\.userID)
    }
    
    var posts: Children<Wall, Post> {
        return children(\.wallId)
    }
}

/// Allows `Wall` to be used as a Fluent migration.
extension Wall: Migration {
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.create(Wall.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.topic)
            builder.field(for: \.isPublic)
            builder.field(for: \.userID)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}

/// Allows `Wall` to be encoded to and decoded from HTTP messages.
extension Wall: Content { }

/// Allows `Wall` to be used as a dynamic parameter in route definitions.
extension Wall: Parameter { }
