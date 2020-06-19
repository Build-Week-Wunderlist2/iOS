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
    @discardableResult convenience init(id: UUID = UUID(),
                                        title: String,
                                        date: Date,
                                        complete: Bool,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.id = id
        self.title = title
        self.date = date
        self.complete = complete
    }
}
