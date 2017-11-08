//
//  download_url.swift
//  YouTube Download
//
//  Created by Mathias Beke on 8/11/17.
//  Copyright © 2017 Mathias Beke. All rights reserved.
//

import Foundation

func executeCommand(command: String, args: [String]) -> String {
    
    let task = Process()
    
    task.launchPath = command
    task.arguments = args
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output: String = String(data: data, encoding: String.Encoding.utf8)!
    
    return output
}

func getDownloadUrl(url: String) -> String {
    let path   = String(Bundle.main.path(forResource: "ytdl", ofType: "")!)
    let output = executeCommand(command: path, args: ["--download-url", url])
    return output
}



struct Response: Codable {
    let title: String
}

func getTitle(url: String) -> String {
    let path   = String(Bundle.main.path(forResource: "ytdl", ofType: "")!)
    let json = executeCommand(command: path, args: ["--json", url])
    
    let jsonDecoder = JSONDecoder()
    let info = try? jsonDecoder.decode(Response.self,
                                       from: json.data(using: .utf8)!)
    
    return info!.title
    
}
