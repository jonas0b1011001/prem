//
//  ActionViewController.swift
//  iPremiumizeAction
//
//  Created by Jonas Geissler on 26.09.18.
//  Copyright © 2018 Jonas Geissler. All rights reserved.
//

import UIKit
import MobileCoreServices
import Foundation

class ActionViewController: UIViewController {

    fileprivate let baseURL = "https://www.premiumize.me/api"
    fileprivate let session = URLSession(configuration: URLSessionConfiguration.ephemeral, delegate: nil, delegateQueue: OperationQueue.main)
    
    
    @IBOutlet weak var btnDownload: UIButton!
    @IBOutlet weak var lblDirectURL: UILabel!
    @IBOutlet weak var lblURL: UILabel!
    @IBAction func btnCreate(_ sender: Any) {
        createTransfer(src: lblDirectURL.text!) {
            (success) in
            if success {
                self.done()
            } else {
                self.setCreationFailed()
            }
        }
    }
    @IBAction func btnDirectDL() {
        let resultsDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: ["directDL": lblDirectURL.text!]]
        
        let resultsProvider = NSItemProvider(item: resultsDictionary as NSSecureCoding, typeIdentifier: String(kUTTypePropertyList))
        
        let resultsItem = NSExtensionItem()
        resultsItem.attachments = [resultsProvider]
        
        self.extensionContext!.completeRequest(returningItems: [resultsItem], completionHandler: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (UserDefaults(suiteName: "group.gj.premiumize.iPremiumize")!.string(forKey: "pin") ?? "") == ""{
            lblURL.text = "Open iPremiumize to set up your Account!"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            for item: Any in self.extensionContext!.inputItems {
                let inputItem = item as! NSExtensionItem
                for provider: AnyObject in inputItem.attachments! {
                    let itemProvider = provider as! NSItemProvider
                    if itemProvider.hasItemConformingToTypeIdentifier(kUTTypePropertyList as String) {
                        // You _HAVE_ to call loadItemForTypeIdentifier in order to get the JS injected
                        itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String, options: nil, completionHandler: {
                            (list, error) in
                            if let results = list as? NSDictionary {
                                OperationQueue.main.addOperation {
                                let test:[String: String] = (results.value(forKey: results.allKeys[0] as! String) as! [String : String])
                                self.lblDirectURL.text = test["baseURI"]!
                                    // To Do : Check if hoster is supported, create only by action
                                self.directdl(src: test["baseURI"]!)
                                }
                            }
                        })
                    }
                }
        }
    }

    @IBAction func done() {
        self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
    func activateDirectDownload(url: String){
        btnDownload.isEnabled = true
        lblDirectURL.text = url
    }
    
    func setCreationFailed(){
        self.lblURL.backgroundColor = UIColor.red
    }

    func directdl(src: String){
        apiTransferDirectdl(src: src) {
            (data, error) in
            if let error = error {
                print("Ext.AVC:directdl - APIRequest error\n\(error.localizedDescription)")
                return
            }
            do{
                let directdl = try JSONDecoder().decode(Directdl.self, from: data!)
                self.activateDirectDownload(url: directdl.location)
            } catch{
                print("Ext.AVC:directdl - JSON Decode failed")
            }
        }
    }
    
    func createTransfer(src: String, completion: ((Bool) -> Void)?) {
        apiTransferCreate(src: src) {
            (data, error) in
            if let error = error {
                completion?(false)
                print("Ext.AVC:createTransfer - APIRequest error\n\(error.localizedDescription)")
                return
            }
            do{
                let apiResponse = try JSONDecoder().decode(ApiResponse.self, from: data!)
                if apiResponse.requestSuccess {
                    completion?(true)
                    self.done()
                    print("Ext.AVC:createTransfer - created")
                } else {
                    completion?(false)
                    print("Ext.ATVC:createTransfer - creation failed")
                }
            } catch{
                completion?(false)
                print("TTVC:createTransfer - JSON Decode failed")
            }
        }
    }
    
    func sendApiRequest(url: URL, completionHandler: @escaping (Data?, Error?) -> Void){
        print("APIM: sending request:\n\(url)")
        let task = session.dataTask(with: url) {
            (data, response, error) in
            if let error = error {
                completionHandler(nil, error)
            }
            
            completionHandler(data, nil)
        }
        task.resume()
    }
    
    func apiTransferCreate(src: String, completionHandler: @escaping (Data?, Error?) -> Void) {
        let pinQueryItem = URLQueryItem(name:"pin", value:UserDefaults(suiteName: "group.gj.premiumize.iPremiumize")!.string(forKey: "pin") ?? "")
        var urlComponents = URLComponents(string: baseURL + "/transfer/create")!
        let srcQueryItem = URLQueryItem(name: "src", value: src)
        let queryItems = [pinQueryItem, srcQueryItem]
        urlComponents.queryItems = queryItems
        let url = urlComponents.url
        
        sendApiRequest(url: url!, completionHandler: completionHandler)
    }
    
    func apiTransferDirectdl(src: String, completionHandler: @escaping (Data?, Error?) -> Void) {
        let pinQueryItem = URLQueryItem(name:"pin", value:UserDefaults(suiteName: "group.gj.premiumize.iPremiumize")!.string(forKey: "pin") ?? "")
        var urlComponents = URLComponents(string: baseURL + "/transfer/directdl")!
        let srcQueryItem = URLQueryItem(name: "src", value: src)
        let queryItems = [pinQueryItem,srcQueryItem]
        urlComponents.queryItems = queryItems
        let url = urlComponents.url
        
        sendApiRequest(url: url!, completionHandler: completionHandler)
    }
}
