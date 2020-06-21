//
//  ToDoItemRepresentation.swift
//  Wunderlist2.0
//
//  Created by Claudia Contreras on 6/18/20.
//  Copyright © 2020 thecoderpilot. All rights reserved.
//

import Foundation

struct ToDoItemRepresentation: Codable {
    var complete: Bool
    var identifier: String
    var title: String
    var date: Date
    var toDoDescription: String
}

// Will need to do coding keys to match the actual data from the backend

