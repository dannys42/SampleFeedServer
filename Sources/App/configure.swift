import Authentication
import FluentSQLite
import Vapor
import VaporExt
import Rainbow

enum ConfigureFailures: Error, CustomStringConvertible {
    case missingEnvVar(String)
    
    public var description: String {
        switch self {
            case let .missingEnvVar(variable): return "Missing enviroment variable '\(variable)'"
        }
    }
}
fileprivate extension Environment {
    static var dbfile: String = "DBFILE"

}

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    Environment.dotenv()
    let params = try ConfigParameters()

    // Ensure we understand various content types
    let contentConfig = ContentConfig.default()
    services.register(contentConfig)
    
    // Log to console for debugging
    services.register(LogMiddleware(log: PrintLogger()))

    // Register providers first
    try services.register(FluentSQLiteProvider())
    try services.register(AuthenticationProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(LogMiddleware.self) // log all calls
    // middlewares.use(SessionsMiddleware.self) // Enables sessions.
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a SQLite database
    let storage: SQLiteStorage
    if params.dbfile == "/dev/null" || params.dbfile == "" {
        print("WARNING: using in-memory store.  Data will not be persisted when you restart the server.  If you wish to persist it, specify the full path to the persistent store using the DBFILE environment variable".bold )
        storage = .memory
    } else {
        storage = .file(path: params.dbfile)
    }
    let sqlite = try SQLiteDatabase(storage: storage)

    // Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.enableLogging(on: .sqlite)
    databases.add(database: sqlite, as: .sqlite)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .sqlite)
    migrations.add(model: UserToken.self, database: .sqlite)
    migrations.add(model: Post.self, database: .sqlite)
    migrations.add(model: Wall.self, database: .sqlite)
    services.register(migrations)

}
