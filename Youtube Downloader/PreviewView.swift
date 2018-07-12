//
//  PreviewView.swift
//  Youtube Downloader
//
//  Created by Mathias Beke on 11/07/18.
//  Copyright © 2018 Mathias Beke. All rights reserved.
//

import Cocoa

@IBDesignable

class PreviewView: NibLoader {
    
    
    @IBOutlet weak var thumbnail: NSImageView!
    @IBOutlet weak var title: NSTextField!
    @IBOutlet weak var uploader: NSTextField!
    
    
    func setInfo(info: VideoInfo) {
        self.title.stringValue = info.fulltitle
        self.uploader.stringValue = info.uploader
        self.thumbnail.image = NSImage(byReferencing: URL(string: info.thumbnail)!)
    }
    
    
    @IBOutlet var topView2: NSView!
    
    override var topView: NSView! {
        set {
            super.topView = topView2
        }
        get {
            return super.topView
        }
    }
    
    
}
