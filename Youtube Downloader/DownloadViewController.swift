//
//  DownloadViewController.swift
//  Youtube Downloader
//
//  Created by Mathias Beke on 8/11/17.
//  Copyright © 2017 Mathias Beke. All rights reserved.
//

import Cocoa
import Alamofire

class DownloadViewController: NSViewController {
    
    
    @IBOutlet weak var videoUrl: NSTextField!
    var downloadUrl: String = ""
    
    @IBOutlet weak var progressbar: NSProgressIndicator!
    @IBOutlet weak var downloadButton: NSButton!
    @IBOutlet weak var message: NSTextField!
    
    @IBAction func downloadButtonClicked(_ sender: Any) {
        
        downloadButton.isHidden = true
        downloadUrl = getDownloadUrl(url: videoUrl.stringValue)
        //NSWorkspace.shared.open(NSURL(string: downloadUrl)! as URL)
        
        let title = getTitle(url: videoUrl.stringValue)
        
        let destination = DownloadRequest.suggestedDownloadDestination(for: .downloadsDirectory)
        
        self.progressbar.isHidden = false
        
        Alamofire.download(downloadUrl, to: destination).downloadProgress { progress in
            print("Download Progress: \(progress.fractionCompleted)")
            self.progressbar.doubleValue = progress.fractionCompleted
            }.response { response in
                self.progressbar.isHidden = true
                self.message.stringValue = "Downloaded: \(title)"
                self.message.isHidden = false
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}


extension DownloadViewController {

    static func freshController() -> DownloadViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier(rawValue: "DownloadViewController")
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? DownloadViewController else {
            fatalError("Why cant i find DownloadViewController? - Check Main.storyboard")
        }
        return viewcontroller
    }
}

