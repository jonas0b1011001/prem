//
//  AccountTableViewController.swift
//  premiumize
//
//  Created by Jonas Geissler on 23.09.18.
//  Copyright © 2018 Jonas Geissler. All rights reserved.
//

import UIKit

class AccountTableViewController: UITableViewController, UITextFieldDelegate {
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
        self.txtPIN.text = UserDefaults(suiteName: "group.gj.premiumize.iPremiumize")!.string(forKey: "pin") ?? ""
        refreshCtrl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.tableView.refreshControl = refreshCtrl
        self.txtPIN.delegate = self
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
        refreshCtrl.endRefreshing()
        print("ATVC:updateUI - Account Info updated successfully!")
    }
    
    func loginFailed(){
        self.lblID.text = " "
        self.lblLimit.text = " "
        self.lblPremium.text = " "
        self.lblSpace.text = " "
        refreshCtrl.endRefreshing()
        print("ATVC:loginFailed - Account Info cleared!")
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
                    self.getError(data: data!)
                    self.loginFailed()
                }
        }
    }
    
    func getError(data: Data){
        do{
            let apiError = try JSONDecoder().decode(ApiError.self, from: data)
            let alert = UIAlertController(title: "Error", message: apiError.message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } catch{
            print("ATVC:getError - JSON Decode failed")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        textField.resignFirstResponder()
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UserDefaults(suiteName: "group.gj.premiumize.iPremiumize")!.set(txtPIN.text, forKey: "pin")
        print("ATVC:textFieldDidEndEditing - Pin saved")
        loadData()
    }
}
