//
//  ToDo+Convenience.swift
//  Wunderlist2.0
//
//  Created by Claudia Contreras on 6/18/20.
//  Copyright © 2020 thecoderpilot. All rights reserved.
//

enum RepeatSelection: String, CaseIterable {
    case none
    case daily
    case weekly
    case monthly
}

import Foundation
import CoreData

extension ToDoItem {
    @discardableResult convenience init(id: Int16,
                                        date: Date,
                                        complete: Bool = false,
                                        toDoDescription: String,
                                        toDoID: Int16,
                                        deadline: Date,
                                        repeatsDaily: Bool = false,
                                        repeatsWeekly: Bool = false,
                                        repeatsMonthly: Bool = false,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.id = id
        self.date = date
        self.complete = complete
        self.toDoDescription = toDoDescription
        self.toDoID = toDoID
        self.deadline = deadline
        self.repeatsDaily = repeatsDaily
        self.repeatsWeekly = repeatsWeekly
        self.repeatsMonthly = repeatsMonthly
    }
    
    @discardableResult convenience init?(toDoItemRepresentation: ToDoItemRepresentation,
                                         context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(id: toDoItemRepresentation.id,
                  date: toDoItemRepresentation.date,
                  complete: toDoItemRepresentation.complete,
                  toDoDescription: toDoItemRepresentation.toDoDescription,
                  toDoID: toDoItemRepresentation.toDoID,
                  deadline: toDoItemRepresentation.deadline,
                  repeatsDaily: toDoItemRepresentation.repeatsDaily,
                  repeatsWeekly: toDoItemRepresentation.repeatsWeekly,
                  repeatsMonthly: toDoItemRepresentation.repeatsMonthly)
    }
    
    var toDoItemRepresentation: ToDoItemRepresentation? {
        guard let date = date,
            let toDoDescription = toDoDescription,
        let deadline = deadline else { return nil }
        
        return ToDoItemRepresentation(complete: complete,
                                      id: id,
                                      date: date,
                                      toDoDescription: toDoDescription,
                                      toDoID: toDoID,
                                      deadline: deadline,
                                      repeatsDaily: repeatsDaily,
                                      repeatsWeekly: repeatsWeekly,
                                      repeatsMonthly: repeatsMonthly)
    }
}
