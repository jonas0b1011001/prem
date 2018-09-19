//
//  ViewController.swift
//  premiumize
//
//  Created by Jonas Geissler on 16.09.18.
//  Copyright © 2018 Jonas Geissler. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    fileprivate var resp: String = "loading..."
    fileprivate var id: String = "ID"
    fileprivate var pin: String = "PIN"
    @IBOutlet weak var lblStatus: UILabel!
    
    @IBOutlet weak var txtID: UITextField!
    @IBOutlet weak var txtPin: UITextField!
    @IBAction func btnSave(_ sender: Any) {
        UserDefaults.standard.set(txtID.text, forKey: "id")
        UserDefaults.standard.set(txtPin.text, forKey: "pin")
    }
    @IBAction func btnAction(_ sender: UIButton) {
        getAccountInfo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtPin.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        txtPin.text = UserDefaults.standard.string(forKey: "pin") ?? ""
        txtID.text = UserDefaults.standard.string(forKey: "id") ?? ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getAccountInfo() {
        id = txtID.text ?? ""
        pin = txtPin.text ?? ""
        let configuration = URLSessionConfiguration.ephemeral
        let url = URL(string: "https://www.premiumize.me/api/folder/list?customer_id=\(id)&pin=\(pin)")!
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

