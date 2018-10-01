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
    let content: [Item]
    let name: String
    let parent_id: String
    let breadcrumbs: [breadcrumb]
    
    public var fullPath: String{
        var path: String = "/"
        for x in breadcrumbs{
            path = path + "\(x.name)/"
        }
        return "\(path)"
    }
}

struct breadcrumb: Codable{
    let id: String
    let name: String
}
