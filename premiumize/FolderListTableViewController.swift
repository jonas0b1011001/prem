//
//  TestTableViewController.swift
//  premiumize
//
//  Created by Jonas Geissler on 21.09.18.
//  Copyright © 2018 Jonas Geissler. All rights reserved.
//

import UIKit
import Foundation
import AVKit
import AVFoundation

class FolderListTableViewController: UITableViewController {

    private let apiManager = APIManager()
    private let refreshCtrl = UIRefreshControl()
        
    @objc func btnCreateFolder(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Create Folder", message: "Enter Folder name", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = "New Folder"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let folderName = alert!.textFields![0].text!
            if folderName != "" {
                self.createFolder(name: folderName)
            } else {
                print("FLTVC:btnCreateFolder - No Foldername provided")
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    var data: [Item] = []
    public var folderID: String = "0"
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData(folderID: folderID)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Loading"
        let uiAddButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(btnCreateFolder(_:)))
        self.navigationItem.rightBarButtonItems = [uiAddButton]
        refreshCtrl.addTarget(self, action: #selector(loadData(_:)), for: .valueChanged)
        self.tableView.refreshControl = refreshCtrl
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        let item = data[indexPath.row] as Item
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = item.sizeString
        if item.isFolder {
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        } else {
            cell.accessoryType = UITableViewCell.AccessoryType.detailButton
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
        nextViewController.itemID = data[indexPath.row].id
        self.present(nextViewController, animated: true, completion: nil)
    }
    
    func updateUI(data: FolderListResponse){
        self.navigationItem.title = data.name
        self.data = data.content
        self.tableView.reloadData()
        refreshCtrl.endRefreshing()
        print("FLTVC:updateUI - Folder /\(data.name)/ updated successfully")
    }
    
    @objc private func loadData(_ sender: Any) {
        loadData(folderID: folderID)
    }
    
    func loadData(folderID: String){
        apiManager.apiFolderList(id: folderID) {
            (data, error) in
            if let error = error {
                print("FLTVC:loadData - APIRequest error\n\(error.localizedDescription)")
                return
            }
            do{
                let folderList = try JSONDecoder().decode(FolderListResponse.self, from: data!)
                self.updateUI(data: folderList)
            } catch{
                print("FLTVC:loadData - JSON Decode failed")
            }
        }
    }
    
    func renameItem(itemID: String, name: String, isFolder: Bool){
        if isFolder{
            renameFolder(folderID: itemID, name: name)
        }else{
            renameFile(fileID: itemID, name: name)
        }
    }
    
    func renameFile(fileID: String, name: String){
        apiManager.apiItemRename(name: name, ID: fileID) {
            (data, error) in
            if let error = error {
                print("FLTVC:renameFile- APIRequest error\n\(error.localizedDescription)")
                return
            }
            do{
                let apiResponse = try JSONDecoder().decode(ApiResponse.self, from: data!)
                if apiResponse.requestSuccess {
                    self.loadData(folderID: self.folderID)
                }
            } catch{
                print("FLTVC:renameFile - JSON Decode failed")
            }
        }
    }
    
    func renameFolder(folderID: String, name: String){
        apiManager.apiFolderRename(name: name, ID: folderID) {
            (data, error) in
            if let error = error {
                print("FLTVC:renameFolder - APIRequest error\n\(error.localizedDescription)")
                return
            }
            do{
                let apiResponse = try JSONDecoder().decode(ApiResponse.self, from: data!)
                if apiResponse.requestSuccess {
                    self.loadData(folderID: self.folderID)
                }
            } catch{
                print("FLTVC:renameFolder - JSON Decode failed")
            }
        }
    }
    
    func deleteItem(itemID: String, isFolder: Bool){
        if isFolder{
            deleteFolder(folderID: itemID)
        }else{
            deleteFile(fileID: itemID)
        }
    }
    
    func deleteFile(fileID: String){
        apiManager.apiItemDelete(ID: fileID) {
            (data, error) in
            if let error = error {
                print("FLTVC:deleteFile- APIRequest error\n\(error.localizedDescription)")
                return
            }
            do{
                let apiResponse = try JSONDecoder().decode(ApiResponse.self, from: data!)
                if apiResponse.requestSuccess {
                    self.loadData(folderID: self.folderID)
                }
            } catch{
                print("FLTVC:deleteFile - JSON Decode failed")
            }
        }
    }
    
    func deleteFolder(folderID: String){
        apiManager.apiFolderDelete(ID: folderID) {
            (data, error) in
            if let error = error {
                print("FLTVC:deleteFolder - APIRequest error\n\(error.localizedDescription)")
                return
            }
            do{
                let apiResponse = try JSONDecoder().decode(ApiResponse.self, from: data!)
                if apiResponse.requestSuccess {
                    self.loadData(folderID: self.folderID)
                }
            } catch{
                print("FLTVC:deleteFolder - JSON Decode failed")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = data[indexPath.row] as Item
        if selectedItem.isFolder {
            let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "FolderListTableView") as! FolderListTableViewController
            nextViewController.folderID = selectedItem.id
            self.navigationController?.pushViewController(nextViewController, animated: true)
        } else {
            guard let url = selectedItem.getLink else {
                print("FLTVC:didSelectRowAt - No URL to play")
                self.tableView?.deselectRow(at: indexPath, animated: true)
                return
            }
            play(link: url)
        }
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = self.contextualDeleteAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfig
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let renameAction = self.contextualRenameAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [renameAction])
        return swipeConfig
    }
 
    func contextualRenameAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction
    {
        let item = data[indexPath.row]
        let action = UIContextualAction(style: .normal,
                                         title: "Rename") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                                            let alert = UIAlertController(title: "Rename item", message: "Enter new title", preferredStyle: .alert)
                                            alert.addTextField { (textField) in
                                                textField.text = item.name
                                            }
                                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                                                let textField = alert!.textFields![0]
                                                if (self.data[indexPath.row].name != textField.text!){
                                                    self.renameItem(itemID: item.id, name: textField.text!, isFolder: (item.isFolder))
                                                }
                                            }))
                                            self.present(alert, animated: true, completion: nil)
                                            completionHandler(true)
        }
            action.image = UIImage(named: "Rename")
            action.backgroundColor = UIColor.blue
            return action
    }
    
    func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let item = data[indexPath.row]
        let action = UIContextualAction(style: .normal,
                                        title: "Delete") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                                            let alert = UIAlertController(title: "Delete \(item.name)", message: "Do you really want to delete the item?", preferredStyle: .alert)
                                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) in
                                                return
                                            }))
                                            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (UIAlertAction) in
                                                self.deleteItem(itemID: item.id, isFolder: item.isFolder)
                                            }))
                                            self.present(alert, animated: true, completion: nil)
                                            completionHandler(true)
        }
        action.image = UIImage(named: "delete")
        action.backgroundColor = UIColor.red
        return action
    }
    
    func createFolder (name: String){
        apiManager.apiFolderCreate(name: name, parentID: folderID) {
            (data, error) in
            if let error = error {
                print("FLTVC:createFolder - APIRequest error\n\(error.localizedDescription)")
                return
            }
            do{
                let apiResponse = try JSONDecoder().decode(ApiResponse.self, from: data!)
                if apiResponse.requestSuccess {
                    self.loadData(folderID: self.folderID)
                }
            } catch{
                print("FLTVC:createFolder - JSON Decode failed")
            }
        }
    }
    
    func play(link: URL){
        // Create an AVPlayer, passing it the HTTP Live Streaming URL.
        let player = AVPlayer(url: link)
        
        // Create a new AVPlayerViewController and pass it a reference to the player.
        let controller = AVPlayerViewController()
        controller.player = player
        
        //Active AudioSession - Any playing audio will be stopped at this point!
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        // Modally present the player and call the player's play() method when complete.
        present(controller, animated: true) {
            player.play()
        }
    }
}
