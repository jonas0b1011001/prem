//
//  CacheCheckResponse.swift
//  premiumize
//
//  Created by Jonas Geissler on 30.09.18.
//  Copyright © 2018 Jonas Geissler. All rights reserved.
//

import Foundation

struct CacheCheckResponse: Codable {
    enum Status: String, Codable{
        case success
        case error
    }
    
    let status: Status
    let response: [Bool]
    let transcoded: [Bool]
}
