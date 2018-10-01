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

    @IBOutlet weak var lblTitle: UILabel!
    private let apiManager = APIManager()
    private let downloadManager = DownloadManager()
    private let refreshCtrl = UIRefreshControl()
    private let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path
        
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
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    var data: [Item] = []
    private var path = ""
    public var folderID: String = "0"
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData(folderID: folderID)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let uiAddButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(btnCreateFolder(_:)))
        self.navigationItem.rightBarButtonItems = [uiAddButton]
        refreshCtrl.addTarget(self, action: #selector(loadData(_:)), for: .valueChanged)
        self.tableView.refreshControl = refreshCtrl
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var fileCell: UITableViewCell?
        var folderCell: folderCell?
        let item = data[indexPath.row] as Item
        if item.isFolder {
            folderCell = tableView.dequeueReusableCell(withIdentifier: "FTVC FolderCell", for: indexPath) as? folderCell
            folderCell!.lblFolderName.text = item.name
            folderCell!.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            
            return folderCell!
        } else {
            fileCell = tableView.dequeueReusableCell(withIdentifier: "FTVC FileCell", for: indexPath)
            fileCell!.textLabel?.text = item.name
            fileCell!.detailTextLabel?.text = item.sizeString
            fileCell!.accessoryType = UITableViewCell.AccessoryType.detailButton
            
            if itemExistsLocally(item: item) {
                fileCell?.detailTextLabel?.text?.append(" - downloaded")
            }
            if downloadManager.isDownloading(id: item.id){
                fileCell?.detailTextLabel?.text?.append(" - downloading")
            }
            
            return fileCell!
        }
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailsNavigationController") as! UINavigationController
        let dtvc = nextViewController.viewControllers[0] as! DetailsTableViewController
        dtvc.itemID = data[indexPath.row].id
        self.present(nextViewController, animated: true, completion: nil)
    }
    
    func updateUI(data: FolderListResponse){
        lblTitle.text = "\(data.name)/"
        self.data = data.content
        self.path = data.fullPath
        self.tableView.reloadData()
        refreshCtrl.endRefreshing()
        let filemgr = FileManager.default
        let dirPaths = filemgr.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDir = dirPaths[0].path
        let newPath = docsDir + self.path
        try? filemgr.createDirectory(atPath: newPath, withIntermediateDirectories: true, attributes: nil)
        print("FLTVC:updateUI - \(data.fullPath) updated successfully")
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
                self.getError(data: data!)
            }
        }
    }
    
    func renameItem(itemID: String, newName: String, oldName: String, isFolder: Bool){
        if isFolder{
            renameFolder(folderID: itemID, newName: newName, oldName: oldName)
        }else{
            renameFile(fileID: itemID, newName: newName, oldName: oldName)
        }
    }
    
    func renameFile(fileID: String, newName: String, oldName: String){
        apiManager.apiItemRename(name: newName, ID: fileID) {
            (data, error) in
            if let error = error {
                print("FLTVC:renameFile- APIRequest error\n\(error.localizedDescription)")
                return
            }
            do{
                let apiResponse = try JSONDecoder().decode(ApiResponse.self, from: data!)
                if apiResponse.requestSuccess {
                    self.loadData(folderID: self.folderID)
                    let oldPath = self.docDir+self.path+oldName
                    let newPath = self.docDir+self.path+newName
                    try? FileManager.default.moveItem(atPath: oldPath, toPath: newPath)
                }
            } catch {
                print("FLTVC:renameFile - JSON Decode failed")
                self.getError(data: data!)
            }
        }
    }
    
    func renameFolder(folderID: String, newName: String, oldName: String){
        apiManager.apiFolderRename(name: newName, ID: folderID) {
            (data, error) in
            if let error = error {
                print("FLTVC:renameFolder - APIRequest error\n\(error.localizedDescription)")
                return
            }
            do{
                let apiResponse = try JSONDecoder().decode(ApiResponse.self, from: data!)
                if apiResponse.requestSuccess {
                    self.loadData(folderID: self.folderID)
                    let oldPath = self.docDir+self.path+oldName
                    let newPath = self.docDir+self.path+newName
                    try? FileManager.default.moveItem(atPath: oldPath, toPath: newPath)
                }
            } catch{
                print("FLTVC:renameFolder - JSON Decode failed")
                self.getError(data: data!)
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
                self.getError(data: data!)
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
                self.getError(data: data!)
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
            if itemExistsLocally(item: selectedItem) {
                let fullPath = docDir + path + selectedItem.name
                print("FLTVC:didSelectRowAt - local file found")
                play(link: URL.init(fileURLWithPath: fullPath))
            }else{
                guard let url = selectedItem.getLink else {
                    print("FLTVC:didSelectRowAt - No URL to play")
                    self.tableView?.deselectRow(at: indexPath, animated: true)
                    return
                }
                play(link: url)
            }
        }
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = data[indexPath.row] as Item
        let deleteAction = self.contextualDeleteAction(forRowAtIndexPath: indexPath)
        if (downloadManager.isDownloading(id: item.id)){
            let swipeConfig = UISwipeActionsConfiguration(actions: [])
            return swipeConfig
        }
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfig
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = data[indexPath.row]
        let renameAction = self.contextualRenameAction(forRowAtIndexPath: indexPath)
        if item.isFolder {
            let swipeConfig = UISwipeActionsConfiguration(actions: [renameAction])
            return swipeConfig
        } else if (itemExistsLocally(item: item)){
            let deleteDownloadAction = self.contextualDeleteDownloadAction(forRowAtIndexPath: indexPath)
            let swipeConfig = UISwipeActionsConfiguration(actions: [renameAction, deleteDownloadAction])
            return swipeConfig
        } else if (downloadManager.isDownloading(id: item.id)){
            let cancelDownloadAction = self.contextualCancelDownloadAction(forRowAtIndexPath: indexPath)
            let swipeConfig = UISwipeActionsConfiguration(actions: [cancelDownloadAction])
            return swipeConfig
        }else{
            let downloadAction = self.contextualDownloadAction(forRowAtIndexPath: indexPath)
            let swipeConfig = UISwipeActionsConfiguration(actions: [renameAction, downloadAction])
            return swipeConfig
        }
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
                                                    self.renameItem(itemID: item.id, newName: textField.text!,oldName: item.name, isFolder: (item.isFolder))
                                                }
                                            }))
                                            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
                                            self.present(alert, animated: true, completion: nil)
                                            completionHandler(true)
        }
            action.image = UIImage(named: "Rename")
            action.backgroundColor = UIColor.blue
            return action
    }
    
    func contextualDownloadAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction
    {
        let item = data[indexPath.row]

        let action = UIContextualAction(style: .normal,
                                        title: "Download") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                                            self.downloadManager.createDownload(url: item.getLink!, folder: self.path, name: item.name, id: item.id)
                                            self.loadData(folderID: self.folderID)
                                            completionHandler(true)
        }
        action.image = UIImage(named: "Download")
        action.backgroundColor = UIColor.green
        return action
    }
    
    func contextualDeleteDownloadAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction
    {
        let item = data[indexPath.row]
        
        let action = UIContextualAction(style: .normal,
                                        title: "Delete Download") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                                            let fullPath = self.docDir + self.path + item.name
                                            try? FileManager.default.removeItem(atPath: fullPath)
                                            self.loadData(folderID: self.folderID)
                                            completionHandler(true)
        }
        return action
    }
    
    func contextualCancelDownloadAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction
    {
        let item = data[indexPath.row]
        
        let action = UIContextualAction(style: .normal,
                                        title: "Cancel Download") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                                            self.downloadManager.cancelDownload(id: item.id)
                                            self.loadData(folderID: self.folderID)
                                            completionHandler(true)
        }
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
                self.getError(data: data!)
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

    func itemExistsLocally(item: Item) -> Bool{
        let fullPath = docDir + path + item.name
        return FileManager.default.fileExists(atPath: fullPath)
    }
    
    func getError(data: Data){
        do{
            let apiError = try JSONDecoder().decode(ApiError.self, from: data)
            let alert = UIAlertController(title: "Error", message: apiError.message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } catch{
            print("FLTVC:getError - JSON Decode failed")
        }
    }
    
}

class folderCell: UITableViewCell {
    @IBOutlet weak var lblFolderName: UILabel!
}
