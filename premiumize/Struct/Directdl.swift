//
//  Directdl.swift
//  premiumize
//
//  Created by Jonas Geissler on 23.09.18.
//  Copyright © 2018 Jonas Geissler. All rights reserved.
//

import Foundation

struct Directdl: Decodable{
    
    enum Status: String, Codable {
        case success, error
    }
    
    let status : Status
    let location: String
    let filename: String
    let filesize: Double
}
