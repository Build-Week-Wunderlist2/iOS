//
//  ToDoItemController.swift
//  Wunderlist2.0
//
//  Created by Claudia Contreras on 6/18/20.
//  Copyright © 2020 thecoderpilot. All rights reserved.
//

struct NewItem: Codable {
    var description: String
    var task_id: Int
    var complete: Bool
    var repeatsDaily: Bool
    var repeatsWeekly: Bool
    var repeatsMonthly: Bool
}

import Foundation
import CoreData

class ToDoItemController {
    var bearer: Bearer?
    
    let baseURL = URL(string: "https://todolist1213.herokuapp.com/api")!
    var returnedToDoItems: [ToDoItemRepresentation] = []
    
    typealias CompletionHandler = (Result<Bool, NetworkError>) -> Void
    
    func put(bearer: Bearer, complete: Bool, description: String, toDoID: Int, repeatsDaily: Bool, repeatsWeekly: Bool, repeatsMonthly: Bool, completion: @escaping CompletionHandler = { _ in }) {
        
        let requestURL = baseURL.appendingPathExtension("post/task")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.addValue("\(bearer.token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let newData = NewItem(description: description, task_id: toDoID, complete: complete, repeatsDaily: repeatsDaily, repeatsWeekly: repeatsWeekly, repeatsMonthly: repeatsMonthly)
            
            request.httpBody = try JSONEncoder().encode(newData)
        } catch {
            NSLog("Error encoding toDoItem: \(error)")
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
            
            guard data != nil else { return }
            //let jsonDecoder = JSONDecoder()
            do {
//                let dataResults = try jsonDecoder.decode(ToDoItemRepresentation.self, from: data)
//                
//                ToDoItem(id: dataResults.id, date: Date(), complete: dataResults.complete, toDoDescription: dataResults.toDoDescription, toDoID: dataResults.toDoID, deadline: dataResults.deadline, repeatsDaily: dataResults.repeatsDaily, repeatsWeekly: dataResults.repeatsWeekly, repeatsMonthly: dataResults.repeatsMonthly, context: CoreDataStack.shared.mainContext)
                
                do {
                    try CoreDataStack.shared.mainContext.save()
                } catch {
                    NSLog("Error saving manage object context: \(error)")
                }
            }
            
            DispatchQueue.main.async {
                completion(.success(true))
            }
        }.resume()
    }
    
    func fetchToDoItemsFromServer(bearer: Bearer, completion: @escaping CompletionHandler = { _ in }) {
        let queryURL = baseURL.appendingPathComponent("/user/\(bearer.userID)/task")
        
        var request = URLRequest(url: queryURL)
               request.httpMethod = "GET"
               request.addValue("\(bearer.token)", forHTTPHeaderField: "Authorization")
               request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: queryURL) { (data, _, error) in
            
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
                let toDoItemRepresentations = try JSONDecoder().decode( [ToDoItemRepresentation].self, from: data)
                
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

        let identifiersToFetch = representations.compactMap({ $0.id })

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

                    let id = toDoItem.id
                    guard let representation = representationsByID[id] else { continue }

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
    
    func deleteToDoItemFromServer(bearer: Bearer, toDoItem: ToDoItem, completion: @escaping CompletionHandler = { _ in }) {
        
        let requestURL = baseURL.appendingPathComponent("/user/task/\(toDoItem.id)")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        request.addValue("\(bearer.token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { (_, response, error) in
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                //Some code here about what went wrong
                NSLog("Error: Status code is not the expected 200. Instead it is \(response.statusCode)")
            }
            
            if let error = error {
               // NSLog("Error deleting task for id \(identifier.uuidString): \(error)")
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
