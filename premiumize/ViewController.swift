//
//  ViewController.swift
//  premiumize
//
//  Created by Jonas Geissler on 16.09.18.
//  Copyright © 2018 Jonas Geissler. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    fileprivate var resp: String = "loading..."
    @IBOutlet weak var lblStatus: UILabel!
    
    @IBAction func btnAction(_ sender: UIButton) {
        getAccountInfo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getAccountInfo() {
        let configuration = URLSessionConfiguration.ephemeral
        let url = URL(string: "https://www.premiumize.me/api/folder/list?customer_id=xxxxxxx&pin=zjgu884n4yfxsezg")!
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: url, completionHandler: { [weak self] (data: Data?, response: URLResponse?, error: Error?) -> Void in
            guard let data = data else {
                return
            }
            do {
                //Decode retrived data with JSONDecoder and assing type of Article object
                let articlesData = try JSONDecoder().decode(AccountInfoResponse.self, from: data)
                self!.resp = articlesData.description
                self!.lblStatus.text = self!.resp
                
            } catch {
                do {
                    let articlesData = try JSONDecoder().decode(FolderListResponse.self, from: data)
                    self!.resp = articlesData.description
                    self!.lblStatus.text = self!.resp
                }catch {
                    do {
                        let articlesData = try JSONDecoder().decode(ApiResponse.self, from: data)
                        self!.resp = articlesData.description
                        self!.lblStatus.text = self!.resp
                    }catch let jsonError {
                        print(jsonError)
                    }
                }
            }
        })
        task.resume()
    }

}

