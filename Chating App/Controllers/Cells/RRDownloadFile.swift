////
////  Download.swift
////  narutoDownload
////
////  Created by Remi Robert on 28/11/14.
////  Copyright (c) 2014 remirobert. All rights reserved.
////
//
//import UIKit
//
//class RRDownloadFile: NSObject, URLSessionDelegate {
//    var downloads = Array<InfoDownload>()
//    var session: URLSession!
//    let identifierDownload = "com.RRDownloadFile"
//
//    let pathDirectory: NSURL? = FileManager.default
//        .urls(for: .documentDirectory,
//              in: .userDomainMask).first as NSURL?
//
//    class InfoDownload: NSObject {
//        var fileTitle: String!
//        var downloadSource: NSURL!
//        var downloadTask: URLSessionDownloadTask!
//        var taskResumeData: NSData!
//        var isDownloading: Bool!
//        var downloadComplete: Bool!
//        var pathDestination: NSURL!
//        var progressBlockCompletion: ((_ bytesWritten: Int64, _ bytesExpectedToWrite: Int64)->())!
//        var responseBlockCompletion: ((_ error: NSError?, _ fileDestination: NSURL?) -> ())!
//
//        init(downloadTitle fileTitle: String, downloadSource source: NSURL) {
//            super.init()
//
//            self.fileTitle = fileTitle
//            self.downloadSource = source
//            self.pathDestination = nil
//            self.isDownloading = false;
//            self.downloadComplete = false;
//        }
//
//    }
//
//    private class Singleton {
//        class var sharedInstance: RRDownloadFile {
//            struct Static {
//                static var instance: RRDownloadFile?
//                  static var token = 0
//            }
//
//            //let sharedInstance: RRDownloadFile = { CarsConfigurator() }()
//            //dispatch_once(&Static.token, { () -> Void in
//                Static.instance = RRDownloadFile()
//            init(){
//                Static.instance?.initSessionDownload()
//            }
//                
//        }
//            return Static.instance!
//        }
//    }
//
//    private func initSessionDownload() {
//        let sessionConfiguration: URLSessionConfiguration = URLSessionConfiguration
//            .background(withIdentifier: self.identifierDownload)
//        sessionConfiguration.allowsCellularAccess = true
//        sessionConfiguration.httpMaximumConnectionsPerHost = 10
//        self.session = URLSession(configuration: sessionConfiguration,
//            delegate: self, delegateQueue: nil)
//    }
//
//    private func saveDataTaskDownload(currentDownload: InfoDownload, location: NSURL) -> NSError? {
//        let fileManager: FileManager = FileManager.default
//        let pathData = currentDownload.pathDestination
//        var error: NSError? = NSError()
//
//        if fileManager.fileExists(atPath: pathData!.path!) == true {
//            if fileManager.replaceItemAtURL(originalItemURL: pathData! as URL as URL, withItemAtURL: location as URL,
//                                            backupItemName: nil, options: FileManager.ItemReplacementOptions.UsingNewMetadataOnly) == false {
//                print(error!)
//            }
//        }
//        else {
//            if fileManager.moveItemAtURL(location as URL, toURL: pathData as! URL) == false {
//                return error
//            }
//        }
//        return nil
//    }
//
//    class func setDestinationDownload(currentDownload: InfoDownload, urlDestination: NSURL?) -> NSError? {
//        let fileManager = FileManager.default
//
//        if urlDestination == nil {
//            currentDownload.pathDestination = fileManager.urls(for: .documentDirectory,
//                                                               in: .userDomainMask)[0] as? NSURL
//            currentDownload.pathDestination = currentDownload.pathDestination?
//                .appendingPathComponent("\(String(describing: urlDestination?.path!))/\(String(describing: currentDownload.fileTitle))") as NSURL?
//        }
//        else {
//            var error: NSError? = NSError()
//            var path = fileManager.urls(for: .documentDirectory,
//                                        in: .userDomainMask)[0] as? NSURL
//            path = path?.appendingPathComponent(urlDestination!.path!) as NSURL?
//
//            if fileManager.createDirectory(at: path! as URL,
//                withIntermediateDirectories: true, attributes: nil){
//                currentDownload.pathDestination = path?.appendingPathComponent(currentDownload.fileTitle) as NSURL?
//            }
//            else {
//                return error
//            }
//        }
//        return nil
//    }
//
//    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
//        session.getTasksWithCompletionHandler { (dataTask: [AnyObject]!, uploadTask: [AnyObject]!,
//            downloadTask: [AnyObject]!) -> Void in
//
//        }
//    }
//
//    func URLSession(session: URLSession, task: URLSessionTask, didCompleteWithError error: NSError?) {
//        if (error != nil) {
//            if let selectedDownloadTask = RRDownloadFile.getTaskByIdentifier(identifier: task.taskIdentifier) {
//                selectedDownloadTask.downloadTask.cancel()
//                selectedDownloadTask.responseBlockCompletion(error, nil)
//                var index = find(Singleton.sharedInstance.downloads, selectedDownloadTask)
//                Singleton.sharedInstance.downloads.removeAtIndex(index!)
//            }
//        }
//    }
//
//    func URLSession(session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
//        if let selectedDownloadTask = RRDownloadFile.getTaskByIdentifier(identifier: downloadTask.taskIdentifier) {
//            selectedDownloadTask.downloadTask.cancel()
//            self.saveDataTaskDownload(currentDownload: selectedDownloadTask, location: location)
//            selectedDownloadTask.responseBlockCompletion(nil, selectedDownloadTask.pathDestination!)
//            var index = find(Singleton.sharedInstance.downloads, selectedDownloadTask)
//            Singleton.sharedInstance.downloads.removeAtIndex(index!)
//        }
//    }
//
//    func URLSession(session: URLSession, downloadTask: URLSessionDownloadTask,
//        didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
//        totalBytesExpectedToWrite: Int64) {
//        if let selectedDownloadTask = RRDownloadFile.getTaskByIdentifier(identifier: downloadTask.taskIdentifier) {
//            selectedDownloadTask.progressBlockCompletion?(totalBytesWritten,
//                                                          totalBytesExpectedToWrite)
//        }
//    }
//
//    private class func getTaskByIdentifier(identifier: Int) -> InfoDownload! {
//        var selectedDownload: InfoDownload! = nil
//        for currentDownload in Singleton.sharedInstance.downloads {
//            if (currentDownload as InfoDownload).downloadTask.taskIdentifier == identifier {
//                selectedDownload = currentDownload
//                return selectedDownload
//            }
//        }
//        return nil
//    }
//
//    private class func downloadFile(fileName: String, downloadSource sourceUrl: NSURL, destination: NSURL?,
//                                    progressBlockCompletion progressBlock:((_ bytesWritten: Int64, _ bytesExpectedToWrite: Int64)->())?,
//                                    responseBlockCompletion responseBlock:@escaping ((_ error: NSError?, _ fileDestination: NSURL?) -> ())) -> URLSessionDownloadTask {
//
//            var newDownload = InfoDownload(downloadTitle: fileName, downloadSource: sourceUrl)
//            newDownload.progressBlockCompletion = progressBlock
//            newDownload.responseBlockCompletion = responseBlock
//
//        if let errorDestination = self.setDestinationDownload(currentDownload: newDownload, urlDestination: destination) {
//            responseBlock(errorDestination, nil)
//                return newDownload.downloadTask
//            }
//
//            newDownload.downloadTask = Singleton.sharedInstance.session
//                .downloadTaskWithURL(newDownload.downloadSource, completionHandler: nil)
//            newDownload.downloadTask.resume()
//            newDownload.isDownloading = true
//            Singleton.sharedInstance.downloads.append(newDownload);
//            return newDownload.downloadTask
//
//    }
//
//    /**
//    Creates a new download request URL string.
//
//    :param: file name of the download.
//    :param: URLString The URL string.
//    */
//    class func download(fileName: String, downloadSource sourceUrl: NSURL,
//                        progressBlockCompletion progressBlock:((_ bytesWritten: Int64, _ bytesExpectedToWrite: Int64)->())?,
//                        responseBlockCompletion responseBlock:@escaping ((_ error: NSError?, _ fileDestination: NSURL?) -> ())) -> URLSessionDownloadTask {
//
//        return self.downloadFile(fileName: fileName, downloadSource: sourceUrl, destination: nil,
//            progressBlockCompletion: progressBlock, responseBlockCompletion: responseBlock)
//    }
//
//    /**
//    Creates a new download request URL string.
//
//    :param: file name of the download.
//    :param: URLString The URL string.
//    :param: destination path download
//    */
//    class func download(fileName: String, downloadSource sourceUrl: NSURL, pathDestination destination: NSURL,
//                        progressBlockCompletion progressBlock:((_ bytesWritten: Int64, _ bytesExpectedToWrite: Int64)->())?,
//                        responseBlockCompletion responseBlock:@escaping ((_ error: NSError?, _ fileDestination: NSURL?) -> ())) -> URLSessionDownloadTask {
//
//        return self.downloadFile(fileName: fileName, downloadSource: sourceUrl, destination: destination,
//                progressBlockCompletion: progressBlock, responseBlockCompletion: responseBlock)
//    }
//
//    /**
//    Pause a download.
//
//    :param: the download task.
//    */
//    class func pauseDownload(downloadTask task: URLSessionDownloadTask) {
//        if let selectedDownload = self.getTaskByIdentifier(identifier: task.taskIdentifier) {
//            //selectedDownload.downloadTask.suspend()
//            selectedDownload.isDownloading = false
//            task.cancel { (data: Data!) -> Void in
//                selectedDownload.taskResumeData = data as NSData?
//                selectedDownload.isDownloading = false
//            }
//        }
//    }
//
//    /**
//    Resume a suspend download.
//
//    :param: the download task.
//    */
//    class func resumeDownload(downloadTask task: URLSessionDownloadTask) {
//        if let selectedDownload = self.getTaskByIdentifier(identifier: task.taskIdentifier) {
//            if selectedDownload.isDownloading == false {
//                selectedDownload.downloadTask = Singleton.sharedInstance.session
//                    .downloadTask(withResumeData: selectedDownload.taskResumeData as Data)
//                selectedDownload.isDownloading = true
//                selectedDownload.downloadTask.resume()
//            }
//        }
//    }
//
//    /**
//    Cancel a download.
//
//    :param: the download task.
//    */
//    class func cancelDownload(downloadTask task: URLSessionDownloadTask) {
//        if let selectedDownload = self.getTaskByIdentifier(identifier: task.taskIdentifier) {
//            selectedDownload.downloadTask.cancel()
//        }
//    }
//}
