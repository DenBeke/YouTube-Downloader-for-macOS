//
//  VideoInfo.swift
//  Youtube Downloader
//
//  Created by Mathias Beke on 13/11/17.
//  Copyright © 2017 Mathias Beke. All rights reserved.
//

import Foundation

class VideoInfo: Codable {
    var fulltitle: String = ""
    var url: String = ""
    var thumbnail: String = ""
    var uploader: String = ""
    
    static func getVideoInfo(url: String) -> VideoInfo {
        let path   = String(Bundle.main.path(forResource: "youtube-dl", ofType: "")!)
        let json = executeCommand(command: path, args: ["-f mp4/best", "--dump-json", url])
        
        let jsonDecoder = JSONDecoder()
        let info = try? jsonDecoder.decode(VideoInfo.self, from: json.data(using: .utf8)!)
        
        return info!
    }
}
