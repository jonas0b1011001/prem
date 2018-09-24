//
//  TabBarViewController.swift
//  premiumize
//
//  Created by Jonas Geissler on 22.09.18.
//  Copyright © 2018 Jonas Geissler. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (UserDefaults.standard.string(forKey: "pin") ?? "" == ""){ //Initial Start
            self.performSegue(withIdentifier: "toLoginSegue", sender: nil)
        } else {
//            if let clipboardString = UIPasteboard.general.string {
//                let url = URL(string: clipboardString)
//                //create transfer, should move to a different spot
//            }
        }
    }

}
