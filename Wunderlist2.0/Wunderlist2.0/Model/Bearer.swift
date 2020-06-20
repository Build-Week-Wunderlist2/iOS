//
//  UserID.swift
//  Wunderlist2.0
//
//  Created by Claudia Contreras on 6/19/20.
//  Copyright © 2020 thecoderpilot. All rights reserved.
//

import Foundation

struct Bearer: Codable {
    let token: String
    let userID: Int
    
    enum CodingKeys: String, CodingKey {
        case token
        case userID = "user_id"
    }
}
