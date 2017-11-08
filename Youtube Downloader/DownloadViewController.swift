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
    
    @IBAction func downloadButtonClicked(_ sender: Any) {
        downloadUrl = getDownloadUrl(url: videoUrl.stringValue)
        //NSWorkspace.shared.open(NSURL(string: downloadUrl)! as URL)
        
        let destination = DownloadRequest.suggestedDownloadDestination(for: .downloadsDirectory)
        Alamofire.download(downloadUrl, to: destination).downloadProgress { progress in
            print("Download Progress: \(progress.fractionCompleted)")
            self.progressbar.doubleValue = progress.fractionCompleted
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}


extension DownloadViewController {
    // MARK: Storyboard instantiation
    static func freshController() -> DownloadViewController {
        //1.
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        //2.
        let identifier = NSStoryboard.SceneIdentifier(rawValue: "DownloadViewController")
        //3.
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? DownloadViewController else {
            fatalError("Why cant i find DownloadViewController? - Check Main.storyboard")
        }
        return viewcontroller
    }
}

