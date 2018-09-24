//
//  CreateTransferViewController.swift
//  premiumize
//
//  Created by Jonas Geissler on 24.09.18.
//  Copyright © 2018 Jonas Geissler. All rights reserved.
//

import UIKit

class CreateTransferViewController: UIViewController {
    @IBOutlet weak var txtURL: UITextView!
    @IBAction func btnCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func btnSaveToCloud(_ sender: UIButton) {
        let url = txtURL.text ?? ""
        let tbvc = self.presentingViewController as! TabBarViewController
        let nc = tbvc.viewControllers![1] as! UINavigationController
        let ttvc = nc.viewControllers[0] as! TransfersTableViewController
        ttvc.createTransfer(src: url) {
            (success) in
            if success {
                self.dismiss(animated: true, completion: nil)
            } else {
                //try again
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("CTVC:viewDidLoad")
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
