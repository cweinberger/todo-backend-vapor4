import Fluent
import FluentSQLiteDriver
import Vapor

// Called before your application initializes.
public func configure(_ app: Application) throws {
    // Serves files from `Public/` directory
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.middleware.use(CORSMiddleware()) // Add CORS with default configuration

    // Configure SQLite database
    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

    // Configure migrations
    app.migrations.add(CreateTodo())
    try app.autoMigrate().wait() // enable auto migrate
    
    try routes(app)
}
