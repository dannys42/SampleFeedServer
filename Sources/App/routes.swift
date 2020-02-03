import Crypto
import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // public routes
    let userController = UserController()
    router.post("users", use: userController.create)
    
    // basic / password auth protected routes
    let basic = router.grouped(User.basicAuthMiddleware(using: BCryptDigest()))
    basic.post("login", use: userController.login)
    
    // bearer / token auth protected routes
    let bearer = router.grouped(User.tokenAuthMiddleware())
    let wallController = WallController()
    bearer.get("walls", use: wallController.index)
    bearer.post("walls", use: wallController.create)
    bearer.delete("walls", Post.parameter, use: wallController.delete)

    bearer.get("walls", Int.parameter, use: wallController.getSingle)

//    wall.post("posts", use: PostController.create)
    bearer.group("walls", Int.parameter) { wallRoute in
        let postController = PostController()
        wallRoute.get("posts", use: postController.index)
        wallRoute.post("posts", use: postController.create)
    }

//    let wall = walls.group(":id") { wall in
//        let wallId = wall.parameters.next(Int.self)
//        let postController = PostController(wallId: wallId)
//        wall.get("posts", use: postController.index)
//    }
//    bearer.get("wall", use: wallController.index)
}
