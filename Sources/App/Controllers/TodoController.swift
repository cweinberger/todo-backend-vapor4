import Fluent
import Vapor

struct TodoController {
    func index(req: Request) throws -> EventLoopFuture<[TodoAPIModel]> {
        return Todo.query(on: req.db).all()
            .flatMapThrowing { todos in
                try todos.map { try TodoAPIModel($0) }
            }
    }

    struct CreateTodoRequestBody: Content {
        let title: String
        let order: Int?

        func makeTodo() -> Todo {
            return Todo(title: title, completed: false, order: order)
        }
    }

    func create(req: Request) throws -> EventLoopFuture<TodoAPIModel> {
        let createTodoRequestBody = try req.content.decode(CreateTodoRequestBody.self)
        let todo = createTodoRequestBody.makeTodo()
        return todo.save(on: req.db)
            .flatMapThrowing { try TodoAPIModel(todo) }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Todo.find(req.parameters.get("todoID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .map { .ok }
    }

    func deleteAll(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Todo.query(on: req.db) // all Todo items
            .delete() // delete
            .transform(to: .ok) // transform to response status code 200
    }

    func getSingle(req: Request) throws -> EventLoopFuture<TodoAPIModel> {
        guard let todoIDString = req.parameters.get("todoID"), // get parameter value of `todoID`
            let todoID = UUID(todoIDString) else { // create UUID from it
                throw Abort(.badRequest, reason: "Invalid parameter `todoID`")
        }
        return Todo.find(todoID, on: req.db)
            .unwrap(or: Abort(.notFound)) // return 404 if the todo hasn't been found
            .flatMapThrowing { try TodoAPIModel($0) }
    }

    struct PatchTodoRequestBody: Content {
        let title: String?
        let completed: Bool?
        let order: Int?
    }

    func update(req: Request) throws -> EventLoopFuture<TodoAPIModel> {
        guard let todoIDString = req.parameters.get("todoID"),
            let todoID = UUID(todoIDString) else {
                throw Abort(.badRequest, reason: "Invalid parameter `todoID`")
        }

        let patchTodoRequestBody = try req.content.decode(PatchTodoRequestBody.self)

        return Todo.find(todoID, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { todo in
                if let title = patchTodoRequestBody.title {
                    todo.title = title
                }
                if let completed = patchTodoRequestBody.completed {
                    todo.completed = completed
                }
                if let order = patchTodoRequestBody.order {
                    todo.order = order
                }
                return todo.update(on: req.db)
                    .transform(to: todo) // return updated todo
            }
            .flatMapThrowing { try TodoAPIModel($0) } // convert updated todo to TodoAPIModel
    }
}
