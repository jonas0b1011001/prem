//
//  FileListResponse.swift
//  premiumize
//
//  Created by Jonas Geissler on 18.09.18.
//  Copyright © 2018 Jonas Geissler. All rights reserved.
//

import Foundation

struct AccountInfoResponse: Codable{
    
    enum Status: String, Codable{
        case success
        case error
    }
    
    let status: Status
    let customer_id: String
    let premium_until: Double
    let limit_used: Float
    let space_used: Double
    
    public var description: String {
        return "status: \(self.status)\n"
        + "customer_id: \(self.customer_id)\n"
        + "premium_until: \(self.premium_until)\n"
        + "limit_used: \(self.limit_used)\n"
            + "space_used: \(self.space_used)\n"
    }
}
