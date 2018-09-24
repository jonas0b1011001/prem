//
//  APIManager.swift
//  premiumize
//
//  Created by Jonas Geissler on 23.09.18.
//  Copyright © 2018 Jonas Geissler. All rights reserved.
//

import Foundation
import UIKit

class APIManager {
    
    fileprivate let pinQueryItem = URLQueryItem(name:"pin", value:UserDefaults.standard.string(forKey: "pin") ?? "")
    fileprivate let baseURL = "https://www.premiumize.me/api"
    fileprivate let session = URLSession(configuration: URLSessionConfiguration.ephemeral, delegate: nil, delegateQueue: OperationQueue.main)
    
    func sendApiRequest(url: URL, completionHandler: @escaping (Data?, Error?) -> Void){
        print("APIM: sending request:\n\(url)")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let task = session.dataTask(with: url) {
            (data, response, error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if let error = error {
                completionHandler(nil, error)
                return
            }
            
            completionHandler(data, nil)
        }
        task.resume()
    }
    
    func apiAccountInfo(completionHandler: @escaping (Data?, Error?) -> Void) {
        var urlComponents = URLComponents(string: baseURL + "/account/info")!
        let queryItems = [pinQueryItem]
        urlComponents.queryItems = queryItems
        let url = urlComponents.url

        sendApiRequest(url: url!, completionHandler: completionHandler)
    }
    
    func apiFolderList(id: String, completionHandler: @escaping (Data?, Error?) -> Void) {
        var urlComponents = URLComponents(string: baseURL + "/folder/list")!
        let idQueryItem = URLQueryItem(name:"id", value:id)
        let queryItems = [pinQueryItem, idQueryItem]
        urlComponents.queryItems = queryItems
        let url = urlComponents.url
        
        sendApiRequest(url: url!, completionHandler: completionHandler)
    }
    
    func apiFolderCreate(name: String,parentID: String, completionHandler: @escaping (Data?, Error?) -> Void) {
        var urlComponents = URLComponents(string: baseURL + "/folder/create")!
        let parentIDQueryItem = URLQueryItem(name:"parent_id", value:parentID)
        let nameQueryItem = URLQueryItem(name:"name", value:name)
        let queryItems = [pinQueryItem, parentIDQueryItem, nameQueryItem]
        urlComponents.queryItems = queryItems
        let url = urlComponents.url
        
        sendApiRequest(url: url!, completionHandler: completionHandler)
    }
    
    func apiFolderRename(name: String,ID: String, completionHandler: @escaping (Data?, Error?) -> Void) {
        var urlComponents = URLComponents(string: baseURL + "/folder/rename")!
        let idQueryItem = URLQueryItem(name:"id", value:ID)
        let nameQueryItem = URLQueryItem(name:"name", value:name)
        let queryItems = [pinQueryItem, idQueryItem, nameQueryItem]
        urlComponents.queryItems = queryItems
        let url = urlComponents.url
        
        sendApiRequest(url: url!, completionHandler: completionHandler)
    }
    
    // No idea how this is supposed to work
    func apiFolderPaste(files: String, folders: String, targetID: String, completionHandler: @escaping (Data?, Error?) -> Void) {
        var urlComponents = URLComponents(string: baseURL + "/folder/paste")!
        let targetIDQueryItem = URLQueryItem(name:"target_id", value:targetID)
        let filesQueryItem = URLQueryItem(name:"files", value:files)
        let foldersQueryItem = URLQueryItem(name:"folders", value:folders)
        let queryItems = [pinQueryItem, filesQueryItem, foldersQueryItem, targetIDQueryItem]
        urlComponents.queryItems = queryItems
        let url = urlComponents.url
        
        sendApiRequest(url: url!, completionHandler: completionHandler)
    }
    
    func apiFolderDelete(ID: String, completionHandler: @escaping (Data?, Error?) -> Void) {
        var urlComponents = URLComponents(string: baseURL + "/folder/delete")!
        let parentIDQueryItem = URLQueryItem(name:"id", value:ID)
        let queryItems = [pinQueryItem, parentIDQueryItem]
        urlComponents.queryItems = queryItems
        let url = urlComponents.url
        
        sendApiRequest(url: url!, completionHandler: completionHandler)
    }
    
    // No idea how this is supposed to work
    func apiFolderUploadinfo(ID: String, completionHandler: @escaping (Data?, Error?) -> Void) {
        var urlComponents = URLComponents(string: baseURL + "/folder/uploadinfo")!
        let idQueryItem = URLQueryItem(name:"id", value:ID)
        let queryItems = [pinQueryItem, idQueryItem]
        urlComponents.queryItems = queryItems
        let url = urlComponents.url
        
        sendApiRequest(url: url!, completionHandler: completionHandler)
    }
    
    func apiItemRename(name: String,ID: String, completionHandler: @escaping (Data?, Error?) -> Void) {
        var urlComponents = URLComponents(string: baseURL + "/item/rename")!
        let idQueryItem = URLQueryItem(name:"id", value:ID)
        let nameQueryItem = URLQueryItem(name:"name", value:name)
        let queryItems = [pinQueryItem, idQueryItem, nameQueryItem]
        urlComponents.queryItems = queryItems
        let url = urlComponents.url
        
        sendApiRequest(url: url!, completionHandler: completionHandler)
    }
    
    func apiItemDetails(ID: String, completionHandler: @escaping (Data?, Error?) -> Void) {
        var urlComponents = URLComponents(string: baseURL + "/item/details")!
        let idQueryItem = URLQueryItem(name:"id", value:ID)
        let queryItems = [pinQueryItem, idQueryItem]
        urlComponents.queryItems = queryItems
        let url = urlComponents.url
        
        sendApiRequest(url: url!, completionHandler: completionHandler)
    }
    
    func apiItemDelete(ID: String, completionHandler: @escaping (Data?, Error?) -> Void) {
        var urlComponents = URLComponents(string: baseURL + "/item/delete")!
        let idQueryItem = URLQueryItem(name:"id", value:ID)
        let queryItems = [pinQueryItem, idQueryItem]
        urlComponents.queryItems = queryItems
        let url = urlComponents.url
        
        sendApiRequest(url: url!, completionHandler: completionHandler)
    }
    
    func apiTransferList(completionHandler: @escaping (Data?, Error?) -> Void) {
        var urlComponents = URLComponents(string: baseURL + "/transfer/list")!
        let queryItems = [pinQueryItem]
        urlComponents.queryItems = queryItems
        let url = urlComponents.url
        
        sendApiRequest(url: url!, completionHandler: completionHandler)
    }
    
    func apiTransferDelete(ID: String, completionHandler: @escaping (Data?, Error?) -> Void) {
        var urlComponents = URLComponents(string: baseURL + "/transfer/delete")!
        let idQueryItem = URLQueryItem(name:"id", value:ID)
        let queryItems = [pinQueryItem, idQueryItem]
        urlComponents.queryItems = queryItems
        let url = urlComponents.url
        
        sendApiRequest(url: url!, completionHandler: completionHandler)
    }

    func apiTransferClearfinished(completionHandler: @escaping (Data?, Error?) -> Void) {
        var urlComponents = URLComponents(string: baseURL + "/transfer/clearfinished")!
        let queryItems = [pinQueryItem]
        urlComponents.queryItems = queryItems
        let url = urlComponents.url
        
        sendApiRequest(url: url!, completionHandler: completionHandler)
    }
    
    func apiTransferCreate(src: String, completionHandler: @escaping (Data?, Error?) -> Void) {
        var urlComponents = URLComponents(string: baseURL + "/transfer/create")!
        let srcQueryItem = URLQueryItem(name: "src", value: src)
        let queryItems = [pinQueryItem, srcQueryItem]
        urlComponents.queryItems = queryItems
        let url = urlComponents.url
        
        sendApiRequest(url: url!, completionHandler: completionHandler)
    }
    
    func apiTransferDirectdl(src: String, completionHandler: @escaping (Data?, Error?) -> Void) {
        var urlComponents = URLComponents(string: baseURL + "/transfer/directdl")!
        let srcQueryItem = URLQueryItem(name: "src", value: src)
        let queryItems = [pinQueryItem,srcQueryItem]
        urlComponents.queryItems = queryItems
        let url = urlComponents.url
        
        sendApiRequest(url: url!, completionHandler: completionHandler)
    }
}
