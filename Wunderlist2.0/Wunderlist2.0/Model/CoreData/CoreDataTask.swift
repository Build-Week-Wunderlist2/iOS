//
//  CoreDataTask.swift
//  Wunderlist2.0
//
//  Created by Claudia Contreras on 6/18/20.
//  Copyright © 2020 thecoderpilot. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    // This is a shared instance of the Core Data Stack
    static let shared = CoreDataStack()
    
    lazy var container: NSPersistentContainer = {
       let container = NSPersistentContainer(name: "Wunderlist")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    func save(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) throws {
           var error: Error?
           
           context.performAndWait {
               do {
                   try context.save()
               } catch let saveError {
                  error = saveError
               }
           }
           if let error = error {
               throw error
           }
       }
}
