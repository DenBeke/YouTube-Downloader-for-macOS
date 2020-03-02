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
    
    @IBOutlet weak var spinner: NSProgressIndicator!
    @IBOutlet weak var progressbar: NSProgressIndicator!
    @IBOutlet weak var downloadButton: NSButton!
    @IBOutlet weak var quitButton: NSButton!
    @IBOutlet weak var message: NSTextField!
    
    
    
    @IBOutlet weak var preview: PreviewView!
    
    
    
    @IBAction func downloadButtonClicked(_ sender: Any) {
        
        downloadButton.isHidden = true
        quitButton.isHidden = true
        spinner.isHidden = false
        spinner.startAnimation(self)
        
        let url = videoUrl.stringValue
        
        DispatchQueue.global(qos: .background).async {
            // This is run on the background queue
            let videoInfo = VideoInfo.getVideoInfo(url: url)
            
            self.downloadUrl = videoInfo.url
            var title = videoInfo.fulltitle
            
            
            // Escape slashes from path
            title = title.replacingOccurrences(of: "/", with: " ")

            DispatchQueue.main.async {
                // This is run on the main queue, after the previous code in outer block

                self.preview.setInfo(info: videoInfo)
                self.spinner.isHidden = true
                self.progressbar.isHidden = false
                self.preview.isHidden = false
                self.videoUrl.isHidden = true

                
                let destination: DownloadRequest.Destination = { _, _ in
                    let suffix = Date().toString(dateFormat: "dd-MM-YY")
                    let pathComponent = "\(title) (\(suffix)).mp4"
                    var documentsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
                    documentsURL.appendPathComponent(pathComponent)
                    return (documentsURL, [.removePreviousFile, .createIntermediateDirectories])
                }
                
                AF.download(self.downloadUrl, to: destination).downloadProgress { progress in
                    print("Download Progress: \(progress.fractionCompleted)")
                    self.progressbar.doubleValue = progress.fractionCompleted
                    }.response { response in
                        self.progressbar.isHidden = true
                        self.message.stringValue = "Downloaded: \(title)"
                        self.message.isHidden = false
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                             self.reset()
                        })
                }
            }
        }
        
        
        
        
    }
    
    
    func reset() {
        self.progressbar.isHidden = true
        self.progressbar.doubleValue = 0
        self.message.isHidden = true
        self.downloadButton.isHidden = false
        self.videoUrl.stringValue = ""
        self.preview.isHidden = true
        self.videoUrl.isHidden = false
        self.spinner.isHidden = true
        self.spinner.stopAnimation(self)
        self.quitButton.isHidden = false
        
        // Reset focus on textfield
        self.videoUrl.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    
    @IBAction func Quit(sender: AnyObject) {
        NSApplication.shared.terminate(self)
    }
    
}


extension DownloadViewController {

    static func freshController() -> DownloadViewController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let identifier = "DownloadViewController"
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? DownloadViewController else {
            fatalError("Why cant i find DownloadViewController? - Check Main.storyboard")
        }
        return viewcontroller
    }
}

extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
}
