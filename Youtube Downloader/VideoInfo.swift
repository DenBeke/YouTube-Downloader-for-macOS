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
    
    static func getVideoInfo(url: String) throws -> VideoInfo {
        let path   = String(Bundle.main.path(forResource: "yt-dlp", ofType: "")!)
        let json = try executeCommand(command: path, args: ["-f", "b", "--dump-json", url])
        
        
        print("test")
        
        let jsonDecoder = JSONDecoder()
        //let info = try? jsonDecoder.decode(VideoInfo.self, from: json.data(using: .utf8)!)
        
        
        var info: VideoInfo
        

        do {
            info = try jsonDecoder.decode(VideoInfo.self, from: json.data(using: .utf8)!)
        }
        catch {
            print("Unexpected error while parsing JSON: \(error)")
            throw ParseError(error.localizedDescription)
        }
    
        
        return info
    }
}
