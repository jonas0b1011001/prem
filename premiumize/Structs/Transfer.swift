//
//  item.swift
//  premiumize
//
//  Created by Jonas Geissler on 16.09.18.
//  Copyright © 2018 Jonas Geissler. All rights reserved.
//

import Foundation

struct transfer: Codable{
    
    enum status: String, Codable{
        case waiting, finished, running, deleted, banned, error, timeout, seeding, queued
    }
    
    let id: String
    let name: String
    let message: String?
    let status: status
    let progress: Float?
    let target_folder: String?
    let folder_id: String?
    let file_id: String?
    
    public var description: String{
        return "id: \(self.id)\n"
            + "name: \(self.name)\n"
            + "message: \(self.message ?? "")\n"
            + "status: \(String(describing: self.status))\n"
            + "progress: \(self.progress ?? 0)\n"
            + "target_folder: \(self.target_folder ?? "")\n"
            + "folder_id: \(self.folder_id ?? "")\n"
            + "file_id: \(self.file_id ?? "")\n"
    }
    
    public var progressString: String {
        guard let progress = self.progress else {
            return ""
        }
        return "\(String(describing: Int(progress))) %"
    }
}
