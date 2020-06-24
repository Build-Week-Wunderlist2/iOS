//
//  ToDoList+Convenience.swift
//  Wunderlist2.0
//
//  Created by Claudia Contreras on 6/18/20.
//  Copyright © 2020 thecoderpilot. All rights reserved.
//

import Foundation
import CoreData

extension ToDoList {
    @discardableResult convenience init(id: Int16 = 0,
                                        title: String,
                                        userID: Int16,
                                        date: Date,
                                        complete: Bool,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.id = id 
        self.title = title
        self.userID = userID
        self.date = date
        self.complete = complete
    }
    
    @discardableResult convenience init?(toDoListRepresentation: ToDoListRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        guard let complete = toDoListRepresentation.complete,
            let id = toDoListRepresentation.id else { return nil }
        self.init(id: id,
                  title: toDoListRepresentation.title,
                  userID: toDoListRepresentation.userID,
                  date: toDoListRepresentation.date,
                  complete: complete,
                  context: context)
    }
    
    var toDoListRepresentation: ToDoListRepresentation? {
        
        guard let title = title,
            let date = date else { return nil }
        
        return ToDoListRepresentation(complete: complete,
                                     id: id,
                                     title: title,
                                     userID: userID,
                                     date: date)
    }
}
