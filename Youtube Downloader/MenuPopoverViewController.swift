//
//  DownloadViewController.swift
//  Youtube Downloader
//
//  Created by Mathias Beke on 8/11/17.
//  Copyright © 2017 Mathias Beke. All rights reserved.
//

import Cocoa
import Alamofire

class MenuPopoverViewController: NSViewController {
    
    
    @IBOutlet weak var videoUrl: NSTextField!
    @IBOutlet weak var downloadButton: NSButton!
    
    var downloadUrl: String = ""
    
    @IBAction func downloadButtonClicked(_ sender: Any) {
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "goToPreview"), sender: self)
    }
    
    
    func reset() {
        self.videoUrl.stringValue = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier!.rawValue == "goToPreview" {
            if let preview = segue.destinationController as? PreviewViewController {
                preview.url = videoUrl.stringValue
            }
        }
    }

    
}


extension MenuPopoverViewController {

    static func freshController() -> MenuPopoverViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier(rawValue: "MenuPopoverViewController")
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? MenuPopoverViewController else {
            fatalError("Why cant i find MenuPopoverViewController? - Check Main.storyboard")
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
