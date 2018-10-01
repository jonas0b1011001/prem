//
//  CreateTransferViewController.swift
//  premiumize
//
//  Created by Jonas Geissler on 24.09.18.
//  Copyright © 2018 Jonas Geissler. All rights reserved.
//

import UIKit

class CreateTransferViewController: UIViewController, UITextViewDelegate {
    
    private let apiManager = APIManager()
    
    @IBOutlet weak var txtURL: UITextView!
    @IBOutlet weak var btnSave: UIButton!
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
        txtURL.delegate = self
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
                let cache = try JSONDecoder().decode(CacheCheckResponse.self, from: data!)
                print(cache.response)
                print("CTVC:cacheCheck - success")
            } catch{
                print("CTVC:cacheCheck - JSON Decode failed")
                self.getError(data: data!)
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
            print("CTVC:getError - JSON Decode failed")
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if(!textView.text.isEmpty){
            cacheCheck(itemURL: textView.text)
        }
        btnSave.isEnabled = !textView.text.isEmpty
    }
}
