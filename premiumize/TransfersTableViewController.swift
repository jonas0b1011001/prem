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

    private var dataFinished: [transfer] = []
    private var dataRunning: [transfer] = []
    private let apiManager = APIManager()
    private let refreshCtrl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Transfers"
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showCreateAlert(sender:)))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "clear", style: .plain, target: self, action: #selector(showClearAlert))
        self.navigationItem.rightBarButtonItems = [addButton]
        refreshCtrl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.tableView.refreshControl = refreshCtrl
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
        refreshCtrl.endRefreshing()
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
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func showCreateAlert(sender:UIBarButtonItem){
        let ctvc = self.storyboard?.instantiateViewController(withIdentifier: "CreateTransferViewController") as! CreateTransferViewController
        ctvc.modalPresentationStyle = .popover
        present(ctvc, animated: true, completion: nil)
        ctvc.popoverPresentationController?.barButtonItem = sender
    }
    
    func createTransfer(src: String, completion: ((Bool) -> Void)?) {
        apiManager.apiTransferCreate(src: src) {
            (data, error) in
            if let error = error {
                completion?(false)
                print("TTVC:createTransfer - APIRequest error\n\(error.localizedDescription)")
                return
            }
            do{
                let apiResponse = try JSONDecoder().decode(ApiResponse.self, from: data!)
                if apiResponse.requestSuccess {
                    completion?(true)
                    self.loadData()
                }
            } catch{
                completion?(false)
                print("TTVC:createTransfer - JSON Decode failed")
            }
        }
    }
    
    //ToDo
    func directdl(src: String){
        apiManager.apiTransferDirectdl(src: src) {
            (data, error) in
            if let error = error {
                print("TTVC:directdl - APIRequest error\n\(error.localizedDescription)")
                return
            }
            do{
                let directdl = try JSONDecoder().decode(Directdl.self, from: data!)
                self.createTransfer(src: directdl.location, completion: nil)
            } catch{
                print("TTVC:directdl - JSON Decode failed")
            }
        }
    }
}
