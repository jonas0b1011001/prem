//
//  ServicesListResponse.swift
//  premiumize
//
//  Created by Jonas Geissler on 24.09.18.
//  Copyright © 2018 Jonas Geissler. All rights reserved.
//

import Foundation

struct ServicesListResponse: Decodable {
    
    let cache: [String]
    let directdl: [String]
    let fairusefactor: [String: Int]
    
}
