//
//  ToDoListController.swift
//  Wunderlist2.0
//
//  Created by Claudia Contreras on 6/23/20.
//  Copyright © 2020 thecoderpilot. All rights reserved.
//


struct dataToSend: Codable {
    var title: String
    var complete: Bool
    var user_id: Int
}


import Foundation
import CoreData

class ToDoListController {
    
   // var bearer: Bearer?
    
    let baseURL = URL(string: "https://todolist1213.herokuapp.com/api")!
    var returnedEntries: [ToDoListRepresentation] = []
    typealias CompletionHandler = (Result<Bool, NetworkError>) -> Void
    
    func put(title: String, complete: Bool, bearer: Bearer, completion: @escaping CompletionHandler = { _ in }) {
        let queryURL = baseURL.appendingPathComponent("/user/todos")
        
        var request = URLRequest(url: queryURL)
        request.httpMethod = "POST"
        request.addValue("\(bearer.token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        print(bearer.token)
        
        do {
            let newData = dataToSend(title: title, complete: complete, user_id: bearer.userID)
            
            request.httpBody = try JSONEncoder().encode(newData)
        } catch {
           NSLog("Error encoding toDoItem: \(error)")
            completion(.failure(.decodeFailed))
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                NSLog("Error POSTting task to server: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(.otherEror(error)))
                }
                return
            }

            guard let data = data  else { return }
            let jsonDecoder = JSONDecoder()
            do {
                let dataResults = try jsonDecoder.decode(ToDoListRepresentation.self, from: data)
                
                ToDoList(id: dataResults.id, title: dataResults.title, userID: dataResults.userID, complete: dataResults.complete, context: CoreDataStack.shared.mainContext)
                do {
                    try CoreDataStack.shared.mainContext.save()
                } catch {
                    NSLog("Error saving manage object context: \(error)")
                }
            } catch {
                
            }
            
            DispatchQueue.main.async {
                completion(.success(true))
            }
        }.resume()
    }
    
    func fetchToDoListFromServer(bearer: Bearer, completion: @escaping CompletionHandler = { _ in }) {
        
        let queryURL = baseURL.appendingPathComponent("/user/\(bearer.userID)/task")
        
        var request = URLRequest(url: queryURL)
        request.httpMethod = "GET"
        request.addValue("\(bearer.token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { (data, response, error) in

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

            // Pull the JSON out of the data, and turn it into [ToDoListRepresentation]
            do {
                let toDoListRepresentations = try JSONDecoder().decode([ToDoListRepresentation].self, from: data)

                // Figure out which toDoItem representations don't exist in Core Data, so we can add them, and figure out which ones have changed
                print(toDoListRepresentations)
                //try self.updateToDoItem(with: toDoListRepresentations)

                DispatchQueue.main.async {
                    completion(.success(true))
                }
                
            } catch {
                NSLog("Error decoding toDoList representations: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(.decodeFailed))
                }
            }
        }.resume()
    }

    func updateToDoItem(with representations: [ToDoListRepresentation]) throws {

        let identifiersToFetch = representations.compactMap({ $0.id })

        let representationsByID = Dictionary(uniqueKeysWithValues:
            zip(identifiersToFetch, representations)
        )

        // Make a copy of the representationsByID for later use
        var toDoListToCreate = representationsByID

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

                for toDoList in existingToDoItems {

                    let id = toDoList.id
                    guard let representation = representationsByID[id] else { continue }
                    
                    toDoList.title = representation.title
                    toDoList.complete = representation.complete
                    //toDoList.date = representation.date

                    // If we updated the task, that means we don't need to make a copy of it. It already exists in Core Data, so remove it from the tasks we still need to create
                    toDoListToCreate.removeValue(forKey: id)
                }

                // Add the tasks that don't exist
                for representation in toDoListToCreate.values {
                    ToDoList(toDoListRepresentation: representation, context: context)
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
//        guard let identifier = toDoItem.id else {
//            completion(.failure(.noIdentifier))
//            return
//        }

        let requestURL = baseURL
           // .appendingPathComponent(identifier.uuidString)
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
