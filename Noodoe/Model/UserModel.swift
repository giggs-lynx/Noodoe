//
//  UserModel.swift
//  Noodoe
//
//  Created by giggs on 17/03/2018.
//  Copyright © 2018 giggs. All rights reserved.
//

import Foundation

class UserModel: Codable {
    
    var objectId: String?
    var userName: String?
    var phone: String?
    var timezone: Int?
    var sessionToken: String?
    
    init() {
        
    }
    
}
