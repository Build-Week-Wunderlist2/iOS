//
//  ToDoListRepresentation.swift
//  Wunderlist2.0
//
//  Created by Claudia Contreras on 6/18/20.
//  Copyright © 2020 thecoderpilot. All rights reserved.
//

import Foundation

struct ToDoListRepresentation: Codable {
    var complete: Bool
    var id: Int16
    var title: String
    var userID: Int16
    //var date: Date
    
    enum CodingKeys: String, CodingKey {
        case complete
        case id
        case title
        case userID = "user_id"
        //case date = "created_at"
    }
}
