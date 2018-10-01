//
//  DetailsViewController.swift
//  premiumize
//
//  Created by Jonas Geissler on 21.09.18.
//  Copyright © 2018 Jonas Geissler. All rights reserved.
//

import UIKit

class DetailsTableViewController: UITableViewController {

    public var itemID: String = ""
    
    private let apiManager = APIManager()
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblSize: UILabel!
    @IBOutlet weak var lblCreatedAt: UILabel!
    @IBOutlet weak var lblLink: UILabel!
    @IBOutlet weak var lblTranscodeStatus: UILabel!
    @IBOutlet weak var lblID: UILabel!
    @IBAction func btnDone(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
    }
    
    func updateUI(data: [String]){
        lblName.text = data[0]
        lblType.text = data[1]
        lblSize.text = data[2]
        lblCreatedAt.text = data[3]
        lblLink.text = data[4]
        lblTranscodeStatus.text = data[5]
        lblID.text = data[6]
        print("DVC:updateUI - item \(data[0]) loaded")
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
                self.updateUI(data: itemDetails.getDetails)
            } catch {
                print("DVC:loadData - JSON Decode failed")
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
            print("DVC:getError - JSON Decode failed")
        }
    }
}
