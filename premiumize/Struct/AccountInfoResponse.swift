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
    
    public var premiumDateString: String {
        let date = Date(timeIntervalSince1970: self.premium_until)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd. MMMM yyyy" //Specify your format that you want
        return dateFormatter.string(from: date)
    }
    
    public var limitString: String{
        let limitPercent = self.limit_used * 100
        return String(format: "%.2f", limitPercent) + "%"
    }
    
    public var spaceString: String{
        var space = self.space_used
        let units: [String] = ["B","kiB","MiB","GiB","TiB","PiB","EiB"]
        var index = 0
        while (space > 1024) {
            space /= 1024
            index += 1
        }
        return String(format: "%.3f ", space) + units[index]
    }
    
    public var requestSuccess: Bool {
        return self.status.rawValue == "success"
    }
}
