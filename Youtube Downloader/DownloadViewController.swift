//
//  DownloadViewController.swift
//  Youtube Downloader
//
//  Created by Mathias Beke on 16/07/18.
//  Copyright © 2018 Mathias Beke. All rights reserved.
//

import Cocoa
import Alamofire

class DownloadViewController: NSViewController {

    // Download URL of with video data
    var videoInfo: VideoInfo!
    
    
    // Views
    @IBOutlet weak var progressbar: NSProgressIndicator!
    @IBOutlet weak var message: NSTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        self.message.stringValue = "Downloading \(videoInfo.fulltitle)..."
        
        var title = videoInfo.fulltitle
        // Escape slashes from path
        title = title.replacingOccurrences(of: "/", with: " ")
        
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let suffix = Date().toString(dateFormat: "dd-MM-YY")
            let pathComponent = "\(title) (\(suffix)).mp4"
            var documentsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent(pathComponent)
            return (documentsURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        Alamofire.download(videoInfo.url, to: destination).downloadProgress { progress in
            print("Download Progress: \(progress.fractionCompleted)")
            self.progressbar.doubleValue = progress.fractionCompleted
            }.response { response in
                //self.progressbar.isHidden = true
                self.message.stringValue = "Downloaded: \(title)"
                self.message.isHidden = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                    //self.reset()
                })
        }
        
        
    }
    
}
