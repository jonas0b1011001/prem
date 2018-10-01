//
//  apiresponse.swift
//  premiumize
//
//  Created by Jonas Geissler on 16.09.18.
//  Copyright © 2018 Jonas Geissler. All rights reserved.
//

import Foundation

struct ApiResponse: Codable{
    
    enum Status: String, Codable {
        case success, error
    }
    
    let status: Status
    let message: String?
    
    public var description: String {
        return "status: \(self.status.rawValue)\n"
            + "message: '\(self.message ?? "none")'"
    }
    
    public var requestSuccess: Bool {
        return self.status.rawValue == "success"
    }
}
