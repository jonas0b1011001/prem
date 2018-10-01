//
//  DownloadManager.swift
//  premiumize
//
//  Created by Jonas Geissler on 29.09.18.
//  Copyright © 2018 Jonas Geissler. All rights reserved.
//

import Foundation
import UIKit

class DownloadManager : NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
    
    static var shared = DownloadManager()
    private var downloads: [String] = []
    private var tasks:[URLSessionDownloadTask] = []
    
    var session : URLSession {
        get {
            let config = URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier!).background")
            
            // Warning: If an URLSession still exists from a previous download, it doesn't create
            // a new URLSession object but returns the existing one with the old delegate object attached!
            return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
        }
    }
    
    func isDownloading(id: String) -> Bool{
        return downloads.contains(id)
    }
    
    func createDownload(url: URL, folder: String, name: String, id: String){
        print("DM:createDownload - starting Download \(url.absoluteString)")
        let task = session.downloadTask(with: url)
        task.taskDescription = "\(folder)\(name)"
        downloads.append(id)
        tasks.append(task)
        task.resume()
    }
    
    func cancelDownload(id: String){
        let index = downloads.firstIndex(of: id)
        let task = tasks[index!]
        task.cancel()
        downloads.remove(at: index!)
        tasks.remove(at: index!)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if totalBytesExpectedToWrite > 0 {
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            DispatchQueue.main.async {UIApplication.shared.isNetworkActivityIndicatorVisible = true}
            debugPrint("Progress \(downloadTask) \(progress)")
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let filemgr = FileManager.default
        let dirPaths = filemgr.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDir = dirPaths[0].path
        let newPath = docsDir + downloadTask.taskDescription!
        let newURL = URL.init(fileURLWithPath: newPath)
        
        try? FileManager.default.copyItem(at: location, to: newURL)
        DispatchQueue.main.async {UIApplication.shared.isNetworkActivityIndicatorVisible = false}
        let index = tasks.firstIndex(of: downloadTask)
        downloads.remove(at: index!)
        tasks.remove(at: index!)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
}
