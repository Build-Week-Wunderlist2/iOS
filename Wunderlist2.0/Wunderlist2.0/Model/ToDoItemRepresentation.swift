//
//  ToDoItemRepresentation.swift
//  Wunderlist2.0
//
//  Created by Claudia Contreras on 6/18/20.
//  Copyright © 2020 thecoderpilot. All rights reserved.
//

import Foundation

struct ToDoItemRepresentation: Codable {
    var complete: Bool?
    var id: Int16
    var title: String
    var date: Date
    var toDoDescription: String
    var toDoID: Int16
    var deadline: Date?
    var repeatsDaily: Bool?
    var repeatsWeekly: Bool?
    var repeatsMonthly: Bool?
    
    enum CodingKeys: String, CodingKey {
        case complete
        case id
        case title
        case date = "created_at"
        case toDoDescription = "description"
        case toDoID = "todo_id"
        case deadline
        case repeatsDaily
        case repeatsWeekly
        case repeatsMonthly
    }
}

// Will need to do coding keys to match the actual data from the backend

