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

/**
 The PostgreSQL database should contain the following schema:
 
 CREATE TABLE todos
 (
	tid 		bigserial 		PRIMARY KEY,
	title		varchar(256)	NOT NULL,
	owner_id 	varchar(128)	NOT NULL,
	completed	integer			NOT NULL,
	ordering	integer			NOT NULL
 );
 
*/

public final class TodoList : TodoListAPI {
    
    let connectionString = "postgres://localhost:5432/todolist"
    
    public func count(withUserID userID: String?, oncompletion: (Int?, ErrorProtocol?) -> Void) {
    
        let query = "SELECT COUNT(*) FROM todos WHERE owner_id=\(userID)"
        
        do {
            let connection = try Connection(URI(connectionString))
            
            let result = try connection.execute("SELECT * FROM todos")
            
            
        } catch {
            
        }
        
    }
    
    public func clear(withUserID ownerID: String?, oncompletion: (ErrorProtocol?) -> Void) {
        
        let query = "DELETE FROM todos WHERE owner=\(ownerID)"
        
        do {
            let connection = try Connection(URI(connectionString))
            
            let result = try connection.execute(query)
            
            
        } catch {
            
        }
    }
    
    public func clearAll(oncompletion: (ErrorProtocol?) -> Void) {
        
        let query = "TRUNCATE TABLE todos"
        
        do {
            let connection = try Connection(URI(connectionString))
            
            let result = try connection.execute(query)
            
            
        } catch {
            
        }
    }
    
    public func get(withUserID userID: String?, oncompletion: ([TodoItem]?, ErrorProtocol?) -> Void) {
        
        let query = "SELECT * FROM todos WHERE owner_id=\(userID)"
        
        do {
            let connection = try Connection(URI(connectionString))
            
            let result = try connection.execute(query)
            
            
        } catch {
            
        }
        
    }
    
    public func get(withUserID userID: String?, withDocumentID documentID: String, oncompletion: (TodoItem?, ErrorProtocol?) -> Void ) {
        
        let query = "SELECT * FROM todos WHERE ownerid=\(userID) AND tid=\(documentID)"
        
        do {
            let connection = try Connection(URI(connectionString))
            
            let result = try connection.execute(query)
            
            
        } catch {
            
        }
        
    }
    
    public func add(userID: String?, title: String, order: Int, completed: Bool,
             oncompletion: (TodoItem?, ErrorProtocol?) -> Void ) {
        
        let query = "INSERT INTO todos (title, owner_id, completed, orderno) VALUES (\(title), \(userID), \(completed), \(order));"
        
        do {
            let connection = try Connection(URI(connectionString))
            
            let result = try connection.execute(query)
            
            
        } catch {
            
        }
        
    }
    
    public func update(documentID: String, userID: String?, title: String?, order: Int?,
                completed: Bool?, oncompletion: (TodoItem?, ErrorProtocol?) -> Void ) {
        
        let query = "UPDATE todos SET completed=\(completed) WHERE tid=\(documentID)"
        
        do {
            let connection = try Connection(URI(connectionString))
            
            let result = try connection.execute(query)
            
            
        } catch {
            
        }
        
    }
    
    public func delete(withUserID userID: String?, withDocumentID documentID: String, oncompletion: (ErrorProtocol?) -> Void) {
    
        let query = "DELETE FROM todos WHERE owner_id=\(userID) AND tid=\(documentID)"
        
        do {
            let connection = try Connection(URI(connectionString))
            
            let result = try connection.execute(query)
            
            
        } catch {
            
        }
        
    }
    
}