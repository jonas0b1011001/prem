//
//  ServiceListTableViewController.swift
//  premiumize
//
//  Created by Jonas Geissler on 25.09.18.
//  Copyright © 2018 Jonas Geissler. All rights reserved.
//

import UIKit

class ServiceListTableViewController: UITableViewController {

    private var fairUseList:[String: Int] = [:]
    private var directdl:[String] = []
    private var cache:[String] = []
    private let apiManager = APIManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let uiDoneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(btnDone))
        self.navigationItem.rightBarButtonItems = [uiDoneButton]
        loadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return "Fair Use Factor"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fairUseList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServicesListTableViewCell", for: indexPath)
        let keys: [String] = Array(fairUseList.keys)
        let sortedKeys: [String] = keys.sorted(by: <)
        let key: String = sortedKeys[indexPath.row]
        let service:(Int) = fairUseList[key]!
        cell.textLabel?.text = key
        cell.detailTextLabel?.text = "\(service)"
        
        return cell
    }
    
    @objc func btnDone(){
        dismiss(animated: true, completion:   nil)
    }

    func updateUI(){
        self.tableView.reloadData()
        print("SLTVC:updateUI - Services List updated successfully")
    }
    
    func loadData(){
        apiManager.apiServicesList() {
            (data, error) in
            if let error = error {
                print("SLTVC:loadData - APIRequest error\n\(error.localizedDescription)")
                return
            }
            do{
                let servicesList = try JSONDecoder().decode(ServicesListResponse.self, from: data!)
                self.fairUseList = servicesList.fairusefactor
                self.cache = servicesList.cache
                self.directdl = servicesList.directdl
                self.updateUI()
            } catch{
                print("SLTVC:loadData - JSON Decode failed")
            }
        }
    }}
