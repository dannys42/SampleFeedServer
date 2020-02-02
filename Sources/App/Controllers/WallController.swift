//
//  WallController.swift
//  
//
//  Created by Danny Sung on 01/30/2020.
//

import Foundation
import Vapor
import FluentSQLite

/// Simple wall controller.
final class WallController {

    /// Returns a list of all walls for the auth'd user.
    static func index(_ req: Request) throws -> Future<[Wall]> {
        // wallId
        let wallId = try req.parameters.next(Int.self)
        
        // fetch auth'd user
        let user = try req.requireAuthenticated(User.self)
        
        // query all wall's belonging to user
        return try Wall.query(on: req)
            .filter(\.userID == user.requireID())
            .filter(\.id == wallId)
            .all()
    }
    /// Returns a list of all walls for the auth'd user.
    func index(_ req: Request) throws -> Future<[Wall]> {
        // fetch auth'd user
        let user = try req.requireAuthenticated(User.self)
        
        // query all wall's belonging to user
        return try Wall.query(on: req)
            .filter(\.userID == user.requireID()).all()
    }

    /// Creates a new Wall for the auth'd user.
    func create(_ req: Request) throws -> Future<Wall> {
        // fetch auth'd user
        let user = try req.requireAuthenticated(User.self)
        
        // decode request content
        return try req.content.decode(CreateWallRequest.self).flatMap { wall in
            // save new wall
            return try Wall(topic: wall.topic, isPublic: wall.isPublic, userID: user.requireID())
                .save(on: req)
        }
    }

    /// Deletes an existing wall for the auth'd user.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        // fetch auth'd user
        let user = try req.requireAuthenticated(User.self)
        
        // decode request parameter (walls/:id)
        return try req.parameters.next(Wall.self).flatMap { wall -> Future<Void> in
            // ensure the wall being deleted belongs to this user
            guard try wall.userID == user.requireID() else {
                throw Abort(.forbidden)
            }
            
            // delete model
            return wall.delete(on: req)
        }.transform(to: .ok)
    }
}

// MARK: Content

/// Represents data required to create a new wall.
struct CreateWallRequest: Content {
    /// Wall topic.
    var topic: String
    var isPublic: Bool
}
