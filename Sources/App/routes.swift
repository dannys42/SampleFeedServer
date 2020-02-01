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
    let todoController = WallController()
    bearer.get("walls", use: todoController.index)
    bearer.post("walls", use: todoController.create)
    bearer.delete("walls", Post.parameter, use: todoController.delete)

    let wall = bearer.grouped("walls", Int.parameter)
    wall.get("posts", use: WallController.index)
//    wall.post("posts", use: PostController.create)
    /*
    wall.get("posts") { req in
        let wallId = req.parameters.next(Int.self)
        let postController = PostController(wallId: wallId)
        
//        postController.index(req)
//        return req
        return req.response()
    }
 */
    
//    let wall = walls.group(":id") { wall in
//        let wallId = wall.parameters.next(Int.self)
//        let postController = PostController(wallId: wallId)
//        wall.get("posts", use: postController.index)
//    }
//    bearer.get("wall", use: wallController.index)
}
