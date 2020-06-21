//
//  ToDo+Convenience.swift
//  Wunderlist2.0
//
//  Created by Claudia Contreras on 6/18/20.
//  Copyright © 2020 thecoderpilot. All rights reserved.
//

import Foundation
import CoreData

extension ToDoItem {
    @discardableResult convenience init(id: UUID = UUID(),
                                        title: String,
                                        date: Date,
                                        complete: Bool,
                                        toDoDescription: String,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.id = id
        self.title = title
        self.date = date
        self.complete = complete
        self.toDoDescription = toDoDescription
    }
    
    @discardableResult convenience init?(toDoItemRepresentation: ToDoItemRepresentation,
                                         context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let id = UUID(uuidString: toDoItemRepresentation.identifier) else { return nil}
        
        self.init(id: id,
                  title: toDoItemRepresentation.title,
                  date: toDoItemRepresentation.date,
                  complete: toDoItemRepresentation.complete,
                  toDoDescription: toDoItemRepresentation.toDoDescription,
                  context: context)
    }
    
    var toDoItemRepresentation: ToDoItemRepresentation? {
        guard let title = title,
        let date = date,
        let toDoDescription = toDoDescription else { return nil }
        
        let identifier = id ?? UUID()
        
        return ToDoItemRepresentation(complete: complete,
                                      identifier: identifier.uuidString,
                                      title: title,
                                      date: date,
                                      toDoDescription: toDoDescription)
    }
}
