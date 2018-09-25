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
        UserDefaults.standard.set(txtPin.text, forKey: "pin")
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

}
