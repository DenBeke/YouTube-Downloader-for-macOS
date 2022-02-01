//
//  execute_command.swift
//  Youtube Downloader
//
//  Created by Mathias Beke on 13/11/17.
//  Copyright © 2017 Mathias Beke. All rights reserved.
//

import Foundation

func executeCommand(command: String, args: [String]) throws -> String {
    
    let task = Process()
    
    task.launchPath = command
    task.arguments = args
    
    let pipeStdOut = Pipe()
    let pipeStdErr = Pipe()
    task.standardOutput = pipeStdOut
    task.standardError = pipeStdErr
    task.launch()
    
    //task.waitUntilExit()
    // we already start reading the pipe so it won't get full
    let data = pipeStdOut.fileHandleForReading.readDataToEndOfFile()
    let output: String = String(data: data, encoding: String.Encoding.utf8)!
    
    
    if task.terminationStatus != 0 {
        let data = pipeStdErr.fileHandleForReading.readDataToEndOfFile()
        let errOutput: String = String(data: data, encoding: String.Encoding.utf8)!
        print("Unexpected error while executing command: \(errOutput)")
        throw GetInfoError(errOutput)
    }
    
    return output
}
