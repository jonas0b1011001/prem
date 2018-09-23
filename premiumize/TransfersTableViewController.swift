//
//  TransfersTableViewController.swift
//  premiumize
//
//  Created by Jonas Geissler on 22.09.18.
//  Copyright © 2018 Jonas Geissler. All rights reserved.
//

import UIKit
import Foundation

class TransfersTableViewController: UITableViewController {

    var dataFinished: [transfer] = []
    var dataRunning: [transfer] = []
    let apiManager = APIManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Transfers"
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(loadData))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showCreateAlert))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "clear", style: .plain, target: self, action: #selector(showClearAlert))
        self.navigationItem.rightBarButtonItems = [refreshButton, addButton]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
        case 0:
            return "Running Transfers: \(dataRunning.count)"
        case 1:
            return "Finished Transfers: \(dataFinished.count)"
        default:
        return "error"
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return dataRunning.count
        } else {
            return dataFinished.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transfersCell", for: indexPath) as! TransferTableViewCell
        var transfer: transfer
        if indexPath.section == 0{
            transfer = dataRunning[indexPath.row] as transfer
            cell.lblState.text = transfer.message
            cell.lblState.textColor = UIColor.blue
            cell.progressBar.progress = transfer.progress!
            cell.lblProgress.text = transfer.progressString
        } else {
            transfer = dataFinished[indexPath.row] as transfer
            cell.lblState.text = transfer.status.rawValue
            cell.lblState.textColor = UIColor(red:0.00, green:0.83, blue:0.04, alpha:1.0)
            cell.progressBar.progress = 100
            cell.progressBar.tintColor = UIColor(red:0.00, green:0.83, blue:0.04, alpha:1.0)
            cell.lblProgress.text = "100 %"
        }
        cell.lblName.text = transfer.name
        return cell
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = self.contextualDeleteAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfig
    }
    
    func updateUI(data: TransferListResponse){
        self.dataFinished = data.getFinishedTransfers
        self.dataRunning = data.getRunningTransfers
        self.tableView.reloadData()
        print("TTVC:updateUI - Transfer List updated successfully")
    }
    
    @objc func loadData(){
        apiManager.apiTransferList() {
            (data, error) in
            if let error = error {
                print("TTVC:loadData - APIRequest error\n\(error.localizedDescription)")
                return
            }
            do{
                let transferList = try JSONDecoder().decode(TransferListResponse.self, from: data!)
                self.updateUI(data: transferList)
            } catch{
                print("TTVC:loadData - JSON Decode failed")
            }
        }
    }
    
    func deleteTransfer(ID: String){
        apiManager.apiTransferDelete(ID: ID) {
            (data, error) in
            if let error = error {
                print("TTVC:deleteTransfer - APIRequest error\n\(error.localizedDescription)")
                return
            }
            do{
                let apiResponse = try JSONDecoder().decode(ApiResponse.self, from: data!)
                if apiResponse.requestSuccess {
                    self.loadData()
                }
            } catch{
                print("TTVC:deleteTransfer - JSON Decode failed")
            }
        }
    }
    
    func clearFinished(){
        apiManager.apiTransferClearfinished() {
            (data, error) in
            if let error = error {
                print("TTVC:clearFinished - APIRequest error\n\(error.localizedDescription)")
                return
            }
            do{
                let apiResponse = try JSONDecoder().decode(ApiResponse.self, from: data!)
                if apiResponse.requestSuccess {
                    self.loadData()
                }
            } catch{
                print("TTVC:clearFinished - JSON Decode failed")
            }
        }
    }
    
    func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        var item: transfer
        if (indexPath.section == 0){
            item = dataRunning[indexPath.row]
        } else {
            item = dataFinished[indexPath.row]
        }
        let action = UIContextualAction(style: .normal,
                                        title: "Delete") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                                            let alert = UIAlertController(title: "Delete \(item.name)", message: "Do you really want to delete the transfer?", preferredStyle: .alert)
                                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) in
                                                return
                                            }))
                                            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (UIAlertAction) in
                                                self.deleteTransfer(ID: item.id)
                                            }))
                                            self.present(alert, animated: true, completion: nil)
                                            completionHandler(true)
        }
        action.image = UIImage(named: "delete")
        action.backgroundColor = UIColor.red
        return action
    }
    
    @objc func showClearAlert(){
        let alert = UIAlertController(title: "Clear Finished", message: "Do you really want do clear all finished transfers?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (UIAlertAction) in
            self.clearFinished()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (UIAlertAction) in
            return
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func showCreateAlert(){
        let alert = UIAlertController(title: "Create Download", message: "Enter URL to download", preferredStyle: .alert)
        alert.addTextField { (txtInput) in
            txtInput.placeholder = "URL"
        }
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { [weak alert] (_) in
            let url = alert!.textFields![0].text!
            if url != "" {
                self.createTransfer(src: url)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    public func createTransfer(src: String){
        apiManager.apiTransferCreate(src: src) {
            (data, error) in
            if let error = error {
                print("TTVC:createTransfer - APIRequest error\n\(error.localizedDescription)")
                return
            }
            do{
                let apiResponse = try JSONDecoder().decode(ApiResponse.self, from: data!)
                if apiResponse.requestSuccess {
                    self.loadData()
                }
            } catch{
                print("TTVC:createTransfer - JSON Decode failed")
            }
        }
    }
}
