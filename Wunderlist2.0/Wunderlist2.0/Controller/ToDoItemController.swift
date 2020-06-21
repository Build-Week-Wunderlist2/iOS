//
//  ToDoItemController.swift
//  Wunderlist2.0
//
//  Created by Claudia Contreras on 6/18/20.
//  Copyright © 2020 thecoderpilot. All rights reserved.
//

import Foundation
import CoreData

class ToDoItemController {
    let baseURL = URL(string: "https://todolist1213.herokuapp.com/api")!
    
    typealias CompletionHandler = (Result<Bool, NetworkError>) -> Void
    
    func put(toDoItem: ToDoItem, completion: @escaping CompletionHandler) {
        
        // Check to make sure an id exists, otherwise we can't PUT the Task to a unique place in Firebase
        
        guard let identifier = toDoItem.id else {
            completion(.failure(.noIdentifier))
            return
        }
        
        let requestURL = baseURL
            .appendingPathComponent(identifier.uuidString)
            .appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            guard let toDoItemRepresentation = toDoItem.toDoItemRepresentation else {
                completion(.failure(.noRep))
                return
            }
            
            request.httpBody = try JSONEncoder().encode(toDoItemRepresentation)
        } catch {
            NSLog("Error encoding toDoItem \(toDoItem): \(error)")
            completion(.failure(.decodeFailed))
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            if let error = error {
                NSLog("Error PUTting task to server: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(.otherEror(error)))
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(.success(true))
            }
        }.resume()
    }
    
    func fetchToDoItemsFromServer(completion: @escaping CompletionHandler = { _ in }) {
        
        let requestURL = baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            
            if let error = error {
                NSLog("Error fetching tasks: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(.otherEror(error)))
                }
                return
            }
            
            guard let data = data else {
                NSLog("Error: No data returned from data task")
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }
            
            // Pull the JSON out of the data, and turn it into [TaskRepresentation]
            do {
                let toDoItemRepresentations = try JSONDecoder().decode([String: ToDoItemRepresentation].self, from: data).map({ $0.value })
                
                // Figure out which toDoItem representations don't exist in Core Data, so we can add them, and figure out which ones have changed
                try self.updateToDoItem(with: toDoItemRepresentations)
                
                DispatchQueue.main.async {
                    completion(.success(true))
                }
            } catch {
                NSLog("Error decoding task representations: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(.decodeFailed))
                }
            }
        }.resume()
    }
    
    func updateToDoItem(with representations: [ToDoItemRepresentation]) throws {
        
        let identifiersToFetch = representations.compactMap({ UUID(uuidString: $0.identifier) })
        
        let representationsByID = Dictionary(uniqueKeysWithValues:
            zip(identifiersToFetch, representations)
        )
        
        // Make a copy of the representationsByID for later use
        var toDoItemToCreate = representationsByID
        
        // Ask Core Data to find any tasks with these identifiers
        
        // if identifiersToFetch.contains(someTaskInCoreData)
        let predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        
        let fetchRequest: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        fetchRequest.predicate = predicate
        
        // Create a new background context. The thread that this context is created on is completely random; you have no control over it.
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        // I want to make sure I'm using this context on the right thread, so I will call .perform
        context.performAndWait {
            do {
                
                // This will only fetch the tasks that match the criteria in our predicate
                let existingToDoItems = try context.fetch(fetchRequest)
                
                // Let's update the tasks that already exist in Core Data
                
                for toDoItem in existingToDoItems {
                    
                    guard let id = toDoItem.id,
                        let representation = representationsByID[id] else { continue }
                    
                    toDoItem.title = representation.title
                    toDoItem.toDoDescription = representation.toDoDescription
                    toDoItem.complete = representation.complete
                    toDoItem.date = representation.date
                    
                    // If we updated the task, that means we don't need to make a copy of it. It already exists in Core Data, so remove it from the tasks we still need to create
                    toDoItemToCreate.removeValue(forKey: id)
                }
                
                // Add the tasks that don't exist
                for representation in toDoItemToCreate.values {
                    ToDoItem(toDoItemRepresentation: representation, context: context)
                }
                
            } catch {
                NSLog("Error fetching tasks for UUIDs: \(error)")
            }
        }
        
        // This will save the correct context (background context)
        try CoreDataStack.shared.save(context: context)
    }
    
    func deleteToDoItemFromServer(_ toDoItem: ToDoItem, completion: @escaping CompletionHandler = { _ in }) {
        // Make the URL by adding the identifier to the base URL, and add the .json
        guard let identifier = toDoItem.id else {
            completion(.failure(.noIdentifier))
            return
        }
        
        let requestURL = baseURL
            .appendingPathComponent(identifier.uuidString)
            .appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (_, response, error) in
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                //Some code here about what went wrong
                NSLog("Error: Status code is not the expected 200. Instead it is \(response.statusCode)")
            }
            
            
            if let error = error {
                NSLog("Error deleting task for id \(identifier.uuidString): \(error)")
                DispatchQueue.main.async {
                    completion(.failure(.otherEror(error)))
                }
                return
            }
            DispatchQueue.main.async {
                completion(.success(true))
            }
        }.resume()
    }
    
}
