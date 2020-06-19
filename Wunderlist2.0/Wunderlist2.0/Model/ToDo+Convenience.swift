//
//  ToDo+Convenience.swift
//  Wunderlist2.0
//
//  Created by Claudia Contreras on 6/18/20.
//  Copyright © 2020 thecoderpilot. All rights reserved.
//

import Foundation
import CoreData

extension ToDo {
    @discardableResult convenience init(identifier: String = UUID().uuidString,
                                        title: String,
                                        date: Date,
                                        isComplete: Bool,
                                        toDoItem: String,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.identifier = identifier
        self.title = title
        self.date = date
        self.isComplete = isComplete
        self.todoItem = toDoItem
    }
}
