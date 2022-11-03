//
//  DownloadViewController.swift
//  Youtube Downloader
//
//  Created by Mathias Beke on 8/11/17.
//  Copyright © 2017 Mathias Beke. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftUI


func errorDialog(question: String, text: String) -> Bool {
    let alert = NSAlert()
    alert.messageText = question
    alert.informativeText = text
    alert.alertStyle = .warning
    alert.addButton(withTitle: "OK")
    alert.addButton(withTitle: "Send crash report")
    return alert.runModal() == .alertFirstButtonReturn
}


class DownloadViewController: NSViewController {
    
    
    @IBOutlet weak var videoUrl: NSTextField!
    @IBOutlet weak var downloadPath: NSTextField!
    var downloadUrl: String = ""
    
    @IBOutlet weak var spinner: NSProgressIndicator!
    @IBOutlet weak var progressbar: NSProgressIndicator!
    @IBOutlet weak var downloadButton: NSButton!
    @IBOutlet weak var quitButton: NSButton!
    @IBOutlet weak var browserPath: NSButton!
    @IBOutlet weak var message: NSTextField!
    
    
    @IBOutlet weak var preview: PreviewView!
    
    @IBAction func browserPathClicked(_ sender: Any){
        let dialog = NSOpenPanel();

        dialog.title                   = "Choose a directory";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.allowsMultipleSelection = false;
        dialog.canChooseFiles = false;
        dialog.canChooseDirectories = true;

        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file

            if (result != nil) {
                self.downloadPath.stringValue = result!.path
            }
        } else {
            return
        }

    }
    
    
    
    @IBAction func downloadButtonClicked(_ sender: Any) {
        
        downloadButton.isHidden = true
        quitButton.isHidden = true
        browserPath.isHidden = true
        spinner.isHidden = false
        spinner.startAnimation(self)
        
        let url = videoUrl.stringValue
        
        // handle paths like ~/Downloads to absolute paths
        let download2path = downloadPath.stringValue.replacingOccurrences(of: "~", with: FileManager.default.homeDirectoryForCurrentUser.path)
        var documentsURL = URL(fileURLWithPath: download2path, isDirectory: true)
        // check out if the path is valid
        if !FileManager.default.fileExists(atPath: documentsURL.path){
            let alert = NSAlert()
            alert.messageText = "Oops, something went wrong"
            alert.informativeText = documentsURL.path + " is not a directory"
            alert.alertStyle = NSAlert.Style.warning
            alert.runModal()
            self.reset()
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            // This is run on the background queue
            var videoInfo: VideoInfo = VideoInfo()
            var err: Error? = nil
            
            do {
                videoInfo = try VideoInfo.getVideoInfo(url: url)
            }
            catch {
                err = error
            }
                
            self.downloadUrl = videoInfo.url
            var title = videoInfo.fulltitle
            
            
            // Escape slashes from path
            title = title.replacingOccurrences(of: "/", with: " ")

            DispatchQueue.main.async {
                // This is run on the main queue, after the previous code in outer block
                
                if err != nil {
                    let clickedOk = errorDialog(question: "Oops, something went wrong", text: err!.localizedDescription)
                    if !clickedOk {
                        sendCrashReport(err: err!)
                    }
                    self.reset()
                    return
                }

                self.preview.setInfo(info: videoInfo)
                self.spinner.isHidden = true
                self.progressbar.isHidden = false
                self.preview.isHidden = false
                self.videoUrl.isHidden = true
                self.downloadPath.isHidden = true

                
                let destination: DownloadRequest.Destination = { _, _ in
                    let suffix = Date().toString(dateFormat: "dd-MM-YY")
                    let pathComponent = "\(title) (\(suffix)).mp4"
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
        self.downloadPath.stringValue = "~/Downloads"
        self.preview.isHidden = true
        self.videoUrl.isHidden = false
        self.browserPath.isHidden = false
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
