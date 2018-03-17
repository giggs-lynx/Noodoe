//
//  ErrorModel.swift
//  Noodoe
//
//  Created by giggs on 17/03/2018.
//  Copyright © 2018 giggs. All rights reserved.
//

import Foundation

struct ErrorModel: Codable {
    
    var code: Int?
    var error: String?
    
    init() {
        
    }
    
}
