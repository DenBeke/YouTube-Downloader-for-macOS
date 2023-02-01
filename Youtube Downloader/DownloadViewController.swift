//
//  DownloadViewController.swift
//  Youtube Downloader
//
//  Created by Mathias Beke on 8/11/17.
//  Copyright © 2017 Mathias Beke. All rights reserved.
//

import Cocoa
import Alamofire


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
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        getURLFromClipboard()
    }
    
    func getURLFromClipboard() {
        let readURL = NSPasteboard.general.pasteboardItems?.first?.string(forType: .string)
        
        if let clipboardContent = readURL {
            if !clipboardContent.contains("youtube.com") && !clipboardContent.contains("youtu.be") { return }
            guard let _ = URL(string: clipboardContent) else { return }
            self.videoUrl.stringValue = clipboardContent
        }
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
