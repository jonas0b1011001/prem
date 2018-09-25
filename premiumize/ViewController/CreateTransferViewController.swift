//
//  CreateTransferViewController.swift
//  premiumize
//
//  Created by Jonas Geissler on 24.09.18.
//  Copyright © 2018 Jonas Geissler. All rights reserved.
//

import UIKit

class CreateTransferViewController: UIViewController {
    
    private let apiManager = APIManager()
    
    @IBOutlet weak var txtURL: UITextView!
    @IBAction func btnCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // TODO: Do some preprocessing with the entered url
    @IBAction func btnSaveToCloud(_ sender: UIButton) {
        let urlString = txtURL.text ?? ""
        
//        let url = URL(string: urlString)
//        if let host = url!.host {
//            //check services/list/
//            print(host)
//        } else {
//            //invalid URL - create task anyways? maybe..
//        }
        if urlString == "" {
            setCreationFailed()
            return
        }
        let tbvc = self.presentingViewController as! TabBarViewController
        let nc = tbvc.viewControllers![1] as! UINavigationController
        let ttvc = nc.viewControllers[0] as! TransfersTableViewController
        ttvc.createTransfer(src: urlString) {
            (success) in
            if success {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.setCreationFailed()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func setCreationFailed(){
        self.txtURL.backgroundColor = UIColor.red
    }
    
    func cacheCheck(itemURL: String){
        apiManager.apiCacheCheck(itemURL: itemURL) {
            (data, error) in
            if let error = error {
                print("CTVC:cacheCheck - APIRequest error\n\(error.localizedDescription)")
                return
            }
            do{
                let cache = try JSONDecoder().decode(ApiResponse.self, from: data!)
                print("CTVC:cacheCheck - success")
            } catch{
                print("CTVC:cacheCheck - JSON Decode failed")
            }
        }
    }
}
