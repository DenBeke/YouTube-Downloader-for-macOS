//
//  execute_command.swift
//  Youtube Downloader
//
//  Created by Mathias Beke on 13/11/17.
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
