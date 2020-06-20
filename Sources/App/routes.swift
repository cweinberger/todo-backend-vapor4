import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }
    
    app.get("hello") { req in
        return "Hello, world!"
    }

    let todoController = TodoController()
    app.get("todos", use: todoController.index)
    app.post("todos", use: todoController.create)
    app.on(.DELETE, "todos", ":todoID", use: todoController.delete)
    app.on(.DELETE, "todos", use: todoController.deleteAll) // DELETE all todos
    app.get("todos", ":todoID", use: todoController.getSingle) // get single todo by :todoID
    app.on(.PATCH, "todos", ":todoID", use: todoController.update) // update an existing todo with :todoID
}
