//
//  AccountTableViewController.swift
//  premiumize
//
//  Created by Jonas Geissler on 23.09.18.
//  Copyright © 2018 Jonas Geissler. All rights reserved.
//

import UIKit

class AccountTableViewController: UITableViewController {
    @IBOutlet weak var lblID: UILabel!
    @IBOutlet weak var lblPremium: UILabel!
    @IBOutlet weak var lblLimit: UILabel!
    @IBOutlet weak var lblSpace: UILabel!
    @IBOutlet weak var txtPIN: UITextField!
    @IBAction func btnBuyPremium() {
        UIApplication.shared.open(URL(string: "http://www.premiumize.me/premium")!, options: [:])
    }
    
    private let apiManager = APIManager()
    private let refreshCtrl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshCtrl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.tableView.refreshControl = refreshCtrl
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
    }

    //Update UI with latest API Data
    func updateUI(data: AccountInfoResponse){
        self.lblID.text = data.customer_id
        self.lblLimit.text = data.limitString
        self.lblPremium.text = data.premiumDateString
        self.lblSpace.text = data.spaceString
        self.txtPIN.text = UserDefaults.standard.string(forKey: "pin") ?? ""
        refreshCtrl.endRefreshing()
        print("ATVC:updateUI - Account Info updated successfully!")
    }
    
    //Send API Request /account/info
    //Success: call reloadData to update UI
    @objc func loadData(){
            apiManager.apiAccountInfo() {
                (data, error) in
                if let error = error {
                    print("ATVC:loadData - APIRequest error\n\(error.localizedDescription)")
                    return
                }
                do{
                    let accountInfo = try JSONDecoder().decode(AccountInfoResponse.self, from: data!)
                    self.updateUI(data: accountInfo)
                } catch{
                    print("ATVC:loadData - JSON Decode failed")
                }
        }
    }
}
