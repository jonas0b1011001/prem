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
    let link: String?
        
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
        return "\(round( size * 1000 ) / 1000) \(units[index])"
    }
    
    public var dateString: String {
        guard let createdAt = self.created_at else{
            return ""
        }
        let date = Date(timeIntervalSince1970: createdAt)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd. MMMM yy, HH:MM" //Specify your format that you want
        return dateFormatter.string(from: date)
    }
    
    public var isFolder: Bool{
        return self.type.rawValue == "folder"
    }
    
    public var getLink: URL?{
        guard let link = self.link else{
            return nil
        }
        return URL(string: link)
    }
    
    public var getLinkString: String{
        guard let link = self.link else{
            return ""
        }
        return link
    }
    
    public var getTranscodeString: String{
        guard let transcode = self.transcode_status else{
            return ""
        }
        return transcode.rawValue
    }
    
    public var getDetails: [String]{
        var details:[String] = []
        details.append(self.name)
        details.append(self.type.rawValue)
        details.append(self.sizeString)
        details.append(self.dateString)
        details.append(self.getLinkString)
        details.append(self.getTranscodeString)
        details.append(self.id)
        return details
    }
}
