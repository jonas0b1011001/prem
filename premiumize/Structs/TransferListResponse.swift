//
//  FolderListResponse.swift
//  premiumize
//
//  Created by Jonas Geissler on 19.09.18.
//  Copyright © 2018 Jonas Geissler. All rights reserved.
//

import Foundation

struct TransferListResponse: Codable {
    
    enum Status: String, Codable {
        case success, error
    }
    
    let status: Status
    let transfers: [transfer]
    
    public var getRunningTransfers: [transfer]{
        var list:[transfer] = []
        for transfer in self.transfers {
            if (transfer.status.rawValue != "finished") {
                (list.append(transfer))
            }
        }
        return list
    }
    
    public var getFinishedTransfers: [transfer]{
        var list:[transfer] = []
        for transfer in self.transfers {
            if (transfer.status.rawValue == "finished") {
                (list.append(transfer))
            }
        }
        return list
    }
}
