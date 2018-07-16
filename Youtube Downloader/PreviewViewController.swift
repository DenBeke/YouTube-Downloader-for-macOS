//
//  ViewController.swift
//  Youtube Downloader
//
//  Created by Mathias Beke on 8/11/17.
//  Copyright © 2017 Mathias Beke. All rights reserved.
//

import Cocoa

class PreviewViewController: NSViewController {

    // URL of YouTube page containing the video
    var url: String = ""
    
    // Download URL of with video data
    var downloadUrl: String = ""
    
    var videoInfo: VideoInfo!
    
    
    // Views
    @IBOutlet weak var spinner: NSProgressIndicator!
    @IBOutlet weak var preview: PreviewView!
    @IBOutlet weak var downloadButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
        self.spinner.startAnimation(self)
        
        DispatchQueue.global(qos: .background).async {
            // This is run on the background queue
            
            self.videoInfo = VideoInfo.getVideoInfo(url: self.url)
            
            self.downloadUrl = self.videoInfo.url
            var title = self.videoInfo.fulltitle
            
            
            // Escape slashes from path
            title = title.replacingOccurrences(of: "/", with: " ")
            
            DispatchQueue.main.async {
                // This is run on the main queue, after the previous code in outer block
                
                print("Ready!")
                
                self.spinner.stopAnimation(self)
                self.spinner.isHidden = true
                
                self.preview.setInfo(info: self.videoInfo)
                self.preview.isHidden = false
                
                self.downloadButton.isHidden = false
                
            }
        }
 
 
        
        
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func downloadButtonClicked(_ sender: Any) {
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "goToDownload"), sender: self)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        self.view.window?.close()
        if segue.identifier!.rawValue == "goToDownload" {
            if let download = segue.destinationController as? DownloadViewController {
                download.videoInfo = self.videoInfo
            }
        }
    }
    
}

