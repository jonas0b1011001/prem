//
//  item.swift
//  premiumize
//
//  Created by Jonas Geissler on 16.09.18.
//  Copyright © 2018 Jonas Geissler. All rights reserved.
//

import Foundation

struct Item: Codable{
    
    enum TranscodeStatus: String, Codable{
        case good_as_is, not_applicable
    }
    
    enum FileType: String, Codable{
        case folder, file
    }
    
    let id: String
    let transcode_status: TranscodeStatus?
    var name: String
    let type: FileType
    let size: Double?
    let created_at: Double?
    let stream_link: String?
    let link: String?
    
    public var description: String{
        return "id: \(self.id)\n"
            + "transcode: \(String(describing: self.transcode_status))\n"
            + "name: \(self.name)\n"
            + "Type: \(self.type.rawValue)\n"
            + "Size: \(self.size ?? 0)\n"
            + "Created: \(self.created_at ?? 0)\n"
            + "Link: \(self.link ?? "")\n"
    }
    
    public var sizeString: String{
        guard var size = self.size else{
            return ""
        }
        let units: [String] = ["B","kiB","MiB","GiB","TiB","PiB","EiB"]
        var index = 0
        while (size > 1024) {
            size /= 1024
            index += 1
        }
        return String(format: "%.3f ", size) + units[index]
    }
    
    public var isFolder: Bool{
        return self.type.rawValue == "folder"
    }
    
    public var getLink: URL?{
        guard let streamLink = self.stream_link else{
            guard let link = self.link else{
                return nil
            }
            return URL(string: link)
        }
        return URL(string: streamLink)
    }
}
