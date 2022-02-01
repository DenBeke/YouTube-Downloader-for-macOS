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
        
        // Check if URL is valid
        if !canOpenURL(url) {
            throw GetInfoError("Invalid URL: " + url)
        }
        
        // Get with yt-dlp
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


func canOpenURL(_ urlString: String) -> Bool {

    let pat = "((https|http)://){0,1}((\\w|-)+)(([.]|[/])((\\w|-)+))+"
    let regex = try! NSRegularExpression(pattern: pat, options: [])
    
    let matches = regex.numberOfMatches(in: urlString, options: [], range: NSMakeRange(0,urlString.utf16.count))
    if (matches == 1 ) {
        return true
    }
    else {
        return false
    }
}
