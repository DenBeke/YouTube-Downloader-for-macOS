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
    @IBOutlet weak var percentLabel: NSTextField!
    
    
    @IBOutlet weak var videoUrl: NSTextField!
    var downloadUrl: String = ""
    
    @IBOutlet weak var spinner: NSProgressIndicator!
    @IBOutlet weak var progressbar: NSProgressIndicator!
    @IBOutlet weak var downloadButton: NSButton!
    @IBOutlet weak var quitButton: NSButton!
    @IBOutlet weak var message: NSTextField!
    
    @IBOutlet weak var videoQuality: NSPopUpButton!
    @IBOutlet weak var qualityButton: NSButton!
    
    @IBOutlet weak var preview: PreviewView!
    
    
    
    @IBAction func downloadButtonClicked(_ sender: Any) {
        
        downloadButton.isHidden = true
        quitButton.isHidden = true
        spinner.isHidden = false
        spinner.startAnimation(self)
        
        let url = videoUrl.stringValue
        
        DispatchQueue.global(qos: .background).async{
            self.loadAvailableFormats(for: url)
            DispatchQueue.main.async {
                self.spinner.isHidden = true
                self.videoQuality.isHidden = false
                self.qualityButton.isHidden = false
            }
        }
    }
    
    @IBAction func qualityButtonClicked(_ sender: Any) {
        
        self.spinner.isHidden = false
        self.videoQuality.isHidden = true
        self.qualityButton.isHidden = true
        
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
                self.percentLabel.isHidden = false
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
                    self.percentLabel.stringValue = String(format: "%.1f%%", progress.fractionCompleted * 100)
                    self.progressbar.doubleValue = progress.fractionCompleted
                    }.response { response in
                        self.progressbar.isHidden = true
                        self.percentLabel.isHidden = true
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
        self.percentLabel.isHidden = true
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
    func loadAvailableFormats(for urlString: String) {
        print("loadAvailableFormats called for \(urlString)")
        
        // 1️⃣ Locate the bundled yt-dlp
        guard let ytDlpURL = Bundle.main.url(forResource: "yt-dlp", withExtension: nil) else {
            print("yt-dlp not in bundle!")
            return
        }
        
        // 2️⃣ Spawn yt-dlp -F <url>
        let proc = Process()
        proc.executableURL = ytDlpURL
        proc.arguments     = ["-F", urlString]
        let pipe           = Pipe()
        proc.standardOutput = pipe

        do { try proc.run() }
        catch {
            print("yt-dlp -F failed:", error)
            return
        }

        // 3️⃣ Read & parse all formats
        let raw = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: raw, encoding: .utf8) else { return }

        let allFormats: [(code: String, desc: String)] = output
            .split(separator: "\n")
            .compactMap { line in
                let parts = line
                    .trimmingCharacters(in: .whitespaces)
                    .split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
                guard parts.count >= 2 else { return nil }
                return (code: String(parts[0]), desc: String(parts[1...].joined(separator: " ")))
            }

        // 4️⃣ Group by resolution (or audio-only)
        let re = try! NSRegularExpression(pattern: #"(\d+x\d+)"#, options: [])
        var grouped = [String: (code: String, desc: String)]()

        for fmt in allFormats {
            let nsDesc = fmt.desc as NSString
            if let match = re.firstMatch(in: fmt.desc, options: [], range: NSRange(location: 0, length: nsDesc.length)),
               let range = Range(match.range(at: 1), in: fmt.desc) {
                let resolution = String(fmt.desc[range])
                if grouped[resolution] == nil {
                    grouped[resolution] = (fmt.code, fmt.desc)
                }
            } else {
                if grouped["audio only"] == nil {
                    grouped["audio only"] = (fmt.code, fmt.desc)
                }
            }
        }

        // 5️⃣ Sort by numeric width (audio-only last)
        let uniqueFormats = grouped.values.sorted { a, b in
            func width(from desc: String) -> Int {
                if desc == "audio only" { return 0 }
                let components = desc.split(separator: " ").first?.split(separator: "x") ?? []
                return Int(components.first ?? "") ?? 0
            }
            return width(from: a.desc) < width(from: b.desc)
        }

        print("Condensed to \(uniqueFormats.count) unique qualities")

        // 6️⃣ Populate the popup on the main thread
        DispatchQueue.main.async {
            self.videoQuality.removeAllItems()
            uniqueFormats.forEach { fmt in
                let title = "\(fmt.code) – \(fmt.desc)"
                self.videoQuality.addItem(withTitle: title)
                self.videoQuality.lastItem?.representedObject = fmt.code
            }
            self.videoQuality.isEnabled = true
            self.videoQuality.selectItem(at: 0)
            print("Popup populated with unique qualities")
        }
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
