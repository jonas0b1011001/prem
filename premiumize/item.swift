//
//  item.swift
//  premiumize
//
//  Created by Jonas Geissler on 16.09.18.
//  Copyright © 2018 Jonas Geissler. All rights reserved.
//

import Foundation

struct item: Codable{
    
    enum TranscodeStatus: String, Codable{
        case good_as_is, not_applicable
    }
    
    let id: String
    let transcode_status: TranscodeStatus?
    let name: String
    let type: String
    let size: Double?
    let created_at: Double?
    let link: URL?
    let stream_link: URL?
    
    public var description: String{
        return "id: \(self.id)\n"
            + "id: \(String(describing: self.transcode_status))\n"
            + "id: \(self.name)\n"
            + "id: \(self.type)\n"
            + "id: \(self.size ?? 0)\n"
            + "id: \(self.created_at ?? 0)\n"
            + "id: \(String(describing: self.link))\n"
            + "id: \(String(describing: self.stream_link))"
    }
}
