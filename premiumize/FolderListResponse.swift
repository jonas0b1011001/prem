//
//  FolderListResponse.swift
//  premiumize
//
//  Created by Jonas Geissler on 19.09.18.
//  Copyright © 2018 Jonas Geissler. All rights reserved.
//

import Foundation

struct FolderListResponse: Codable {
    
    enum Status: String, Codable {
        case success, error
    }
    
    let status: Status
    let content: [item]
    let name: String
    let parent_id: String
    
    public var description: String{
        var content = ""
        for item in self.content {
            content += "\(item.name)\n"
        }
        return "status: \(self.status)\n"
            + "content: \(content)"
            + "name: \(self.name)\n"
            + "parent_id \(self.parent_id)"
    }
}
