//
//  DetailsViewController.swift
//  premiumize
//
//  Created by Jonas Geissler on 21.09.18.
//  Copyright © 2018 Jonas Geissler. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    public var itemID: String = ""
    
    private let apiManager = APIManager()
    
    @IBOutlet weak var uiNavItem: UINavigationItem!
    @IBOutlet weak var lblID: UILabel!
    @objc func btnDone(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        uiNavItem.title = "Details"
        uiNavItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(btnDone(_:)))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
    }
    
    func updateUI(data: Item){
        lblID.text = data.description
        print("DVC:updateUI - item \(data.name) loaded")
    }
    
    func loadData(){
        apiManager.apiItemDetails(ID: itemID) {
            (data, error) in
            if let error = error {
                print("DVC:loadData - APIRequest error\n\(error.localizedDescription)")
                return
            }
            do{
                let itemDetails = try JSONDecoder().decode(Item.self, from: data!)
                self.updateUI(data: itemDetails)
            } catch {
                print("DVC:loadData - JSON Decode failed")
            }
        }
    }
}
