/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation
import TodoListAPI
import SQL
import PostgreSQL
import HeliumLogger
import LoggerAPI


/**
 The PostgreSQL database should contain the following schema:

 CREATE TABLE todos
 (
	tid 		bigserial 		PRIMARY KEY,
 	user_id 	varchar(128)	NOT NULL,
	title		varchar(256)	NOT NULL,
	completed	boolean			NOT NULL,
	ordering	integer			NOT NULL
 );

*/
let COUNT = "count"
let TID = "tid"
let TITLE = "title"
let COMPLETED = "completed"
let ORDER = "ordering"


public final class TodoList: TodoListAPI {
    
    static let defaultPostgreHost = "localhost"
    static let defaultPostgrePort = Int32(5432)
    static let defaultDatabaseName = "todolist"
    static let defaultUsername = ""
    static let defaultPassword = ""
    var postgreConnection: PostgreSQL.Connection!

    var host: String = TodoList.defaultPostgreHost
    var port: Int32 = TodoList.defaultPostgrePort
    var password: String = TodoList.defaultPassword
    var username: String = TodoList.defaultUsername
    var database: String = TodoList.defaultDatabaseName
    var defaultUsername = "default"

    public init(database: String = TodoList.defaultDatabaseName,
                host: String = TodoList.defaultPostgreHost,
                port: Int32 = TodoList.defaultPostgrePort,
                username: String? = defaultUsername, password: String? = defaultPassword) {

        do {
            self.database = database
            self.host = host
            self.port = Int32(port)
            self.username = username!
            self.password = password!
            let connectionString = try URI("postgres://\(self.host):\(self.port)/\(self.database)")
            postgreConnection = try PostgreSQL.Connection(connectionString)
            
            // Open the server
            try postgreConnection.open()

            // Check the status
            guard postgreConnection.internalStatus == PostgreSQL.Connection.InternalStatus.OK else {
                throw TodoCollectionError.ConnectionRefused
            }

        } catch {
            print("(\(#function) at \(#line)) - Failed to connect to the server")
        }
    }

    public init(dbConfiguration: DatabaseConfiguration) {

        do {
            self.host = dbConfiguration.host!
            self.port = Int32(dbConfiguration.port!)
            self.username = dbConfiguration.username!
            self.password = dbConfiguration.password!
            let connectionString = try URI("postgres://\(self.username):\(self.password)@\(self.host):\(self.port)/\(TodoList.defaultDatabaseName)")
            postgreConnection = try PostgreSQL.Connection(connectionString)

            // Open
            try postgreConnection.open()

            // Check the server status
            
            guard postgreConnection.internalStatus == PostgreSQL.Connection.InternalStatus.OK else {
                throw TodoCollectionError.ConnectionRefused
            }

        } catch {
            print("(\(#function) at \(#line)) - Failed to connect to the server")
        }
    }

    public func count(withUserID: String?, oncompletion: (Int?, ErrorProtocol?) -> Void) {

        let userID = withUserID ?? defaultUsername

        let query = "SELECT COUNT(*) FROM todos WHERE user_id='\(userID)'"

        do {
            let result = try self.postgreConnection.execute(query)

            guard result.status == PostgreSQL.Result.Status.TuplesOK else {
                oncompletion(nil, TodoCollectionError.ParseError)
                return
            }

            guard let count = try Int(String(result[0].data(COUNT))) else {
                oncompletion(nil, TodoCollectionError.ParseError)
                return
            }
            oncompletion(count, nil)

        } catch {
            oncompletion(nil, error)
        }
    }

    public func clear(withUserID: String?, oncompletion: (ErrorProtocol?) -> Void) {

        let userID = withUserID ?? defaultUsername
        let query = "DELETE FROM todos WHERE user_id='\(userID)'"

        do {
            let result = try self.postgreConnection.execute(query)

            guard result.status == PostgreSQL.Result.Status.CommandOK else {
                oncompletion(TodoCollectionError.ParseError)
                return
            }
            oncompletion(nil)

        } catch {
            oncompletion(error)
        }
    }

    public func clearAll(oncompletion: (ErrorProtocol?) -> Void) {

        let query = "TRUNCATE TABLE todos"

        do {
            let result = try self.postgreConnection.execute(query)

            guard result.status == PostgreSQL.Result.Status.CommandOK else {
                oncompletion(TodoCollectionError.ParseError)
                return
            }
            oncompletion(nil)

        } catch {
            oncompletion(error)
        }
    }

    public func get(withUserID: String?, oncompletion: ([TodoItem]?, ErrorProtocol?) -> Void) {

        let userID = withUserID ?? defaultUsername
        let query = "SELECT * FROM todos WHERE user_id='\(userID)'"

        do {
            let result = try self.postgreConnection.execute(query)

            guard result.status == PostgreSQL.Result.Status.TuplesOK else {
                oncompletion(nil, TodoCollectionError.ParseError)
                return
            }
            var todoItems = [TodoItem]()

            for i in 0 ..< result.count {
                let tid = try String(result[i].data(TID))
                let title = try String(result[i].data(TITLE))
                let completed = try String(result[i].data(COMPLETED)) == "t" ? true : false
                guard let order = try Int(String(result[i].data(ORDER))) else {
                    oncompletion(nil, TodoCollectionError.ParseError)
                    return
                }

                todoItems.append(TodoItem(documentID: tid, userID: userID, order: order, title: title, completed: completed))
            }

            oncompletion(todoItems, nil)

        } catch {
            oncompletion(nil, error)
        }
    }

    public func get(withUserID: String?, withDocumentID: String, oncompletion: (TodoItem?, ErrorProtocol?) -> Void ) {

        let userID = withUserID ?? defaultUsername
        let query = "SELECT * FROM todos WHERE user_id='\(userID)' AND tid='\(withDocumentID)'"

        do {
            let result = try self.postgreConnection.execute(query)

            guard result.status == PostgreSQL.Result.Status.TuplesOK else {
                oncompletion(nil, TodoCollectionError.ParseError)
                return
            }

            let title = try String(result[0].data(TITLE))
            let completed = try String(result[0].data(COMPLETED)) == "t" ? true : false
            guard let order = try Int(String(result[0].data(ORDER))) else {
                oncompletion(nil, TodoCollectionError.ParseError)
                return
            }
            let todoItem = TodoItem(documentID: withDocumentID, userID: userID, order: order, title: title, completed: completed)
            oncompletion(todoItem, nil)

        } catch {
            oncompletion(nil, error)
        }
    }

    public func add(userID: String?, title: String, order: Int, completed: Bool,
             oncompletion: (TodoItem?, ErrorProtocol?) -> Void ) {

        let userID = userID ?? defaultUsername
        let query = "INSERT INTO todos (user_id, title, completed, ordering) VALUES ('\(userID)', '\(title)', \(completed), \(order)) RETURNING tid;"

        do {
            let result = try self.postgreConnection.execute(query)

            guard result.status == PostgreSQL.Result.Status.TuplesOK else {
                oncompletion(nil, TodoCollectionError.ParseError)
                return
            }

            let docID = try (String(result[0].data(TID)))
            let todoItem = TodoItem(documentID: docID, userID: userID, order: order, title: title, completed: completed)
            oncompletion(todoItem, nil)

        } catch {
            oncompletion(nil, error)
        }
    }

    public func update(documentID: String, userID: String?, title: String?, order: Int?,
                completed: Bool?, oncompletion: (TodoItem?, ErrorProtocol?) -> Void ) {

        let userID = userID ?? defaultUsername

        var query = "UPDATE todos SET"
        var updateValues = [String]()

        if let title = title {
            updateValues.append(" title = '\(title)' ")
        }

        if let order = order {
            updateValues.append(" \(ORDER) = \(order) ")
        }

        if let completed = completed {
            updateValues.append(" completed = \(completed) ")
        }

        let joiner = ","
        let joinedString = updateValues.joined(separator: joiner)
        query.append(joinedString)

        let condition = "WHERE tid='\(documentID)' AND user_id='\(userID)' RETURNING title, ordering, completed;"
        query.append(condition)

        do {
            let result = try self.postgreConnection.execute(query)

            guard result.status == PostgreSQL.Result.Status.TuplesOK else {
                oncompletion(nil, TodoCollectionError.ParseError)
                return
            }

            let title = try String(result[0].data(TITLE))
            let completed = try String(result[0].data(COMPLETED)) == "t" ? true : false
            guard let order = try Int(String(result[0].data(ORDER))) else {
                oncompletion(nil, TodoCollectionError.ParseError)
                return
            }

            let todoItem = TodoItem(documentID: documentID, userID: userID, order: order, title: title, completed: completed)
            oncompletion(todoItem, nil)

        } catch {
            oncompletion(nil, error)
        }
    }

    public func delete(withUserID: String?, withDocumentID: String, oncompletion: (ErrorProtocol?) -> Void) {
        
        let userID = withUserID ?? defaultUsername
        let query = "DELETE FROM todos WHERE user_id='\(userID)' AND tid=\(withDocumentID)"

        do {
            let result = try self.postgreConnection.execute(query)

            guard result.status == PostgreSQL.Result.Status.CommandOK else {
                oncompletion(TodoCollectionError.ParseError)
                return
            }
            oncompletion(nil)

        } catch {
            oncompletion(error)
        }
    }
}
