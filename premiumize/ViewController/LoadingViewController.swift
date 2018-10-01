//
//  LoadingViewController.swift
//  premiumize
//
//  Created by Jonas Geissler on 21.09.18.
//  Copyright © 2018 Jonas Geissler. All rights reserved.
//

import UIKit
import Foundation

class LoadingViewController: UIViewController {
    
    let apiManager = APIManager()
    
    @IBOutlet weak var btnRetry: UIButton!
    @IBAction func login(_ sender: Any) {
        if let userDefaults = UserDefaults(suiteName: "group.gj.premiumize.iPremiumize") {
            userDefaults.set(txtPin.text, forKey: "pin")
            print("LVC:login - PIN stored")
        }
        checkPin()
    }
    @IBOutlet weak var txtPin: UITextField!
    @IBOutlet weak var lblStatus: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
        activityIndicator.startAnimating()
        // Do any additional setup after loading the view.
    }

    func checkPin() {
        setLogin()
        apiManager.apiAccountInfo() {
            (data, error) in
            if let error = error {
                print("LVC:loadData - APIRequest error\n\(error.localizedDescription)")
                self.setRetry()
                return
            }
            do{
                let accountInfo = try JSONDecoder().decode(AccountInfoResponse.self, from: data!)
                if accountInfo.requestSuccess {
                    //Login successful
                    self.performSegue(withIdentifier: "Tab Bar", sender: nil)
                } else {
                    self.setRetry()
                }
            } catch{
                self.setRetry()
                print("LVC:loadData - JSON Decode failed")
                self.getError(data: data!)
            }
        }
    }
    
    func setRetry(){
        self.lblStatus.text = "Login failed!"
        self.txtPin.isEnabled = true
        self.btnRetry.isEnabled = true
        self.activityIndicator.isHidden = true
    }
    
    func setLogin(){
        self.lblStatus.isHidden = false
        activityIndicator.isHidden = false
        self.txtPin.isEnabled = false
        self.btnRetry.isEnabled = false
        self.lblStatus.text = "Logging In..."
    }

    func getError(data: Data){
        do{
            let apiError = try JSONDecoder().decode(ApiError.self, from: data)
            let alert = UIAlertController(title: "Error", message: apiError.message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } catch{
            print("LVC:getError - JSON Decode failed")
        }
    }
    
}
