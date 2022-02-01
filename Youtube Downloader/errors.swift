//
//  errors.swift
//  Youtube Downloader
//
//  Created by Mathias Beke on 01/02/2022.
//  Copyright © 2022 Mathias Beke. All rights reserved.
//

import Foundation


struct GetInfoError: Error, LocalizedError {
    let errorDescription: String?

    init(_ description: String) {
        errorDescription = description
    }
}


struct ParseError: Error, LocalizedError {
    let errorDescription: String?

    init(_ description: String) {
        errorDescription = description
    }
}

struct DownloadError: Error, LocalizedError {
    let errorDescription: String?

    init(_ description: String) {
        errorDescription = description
    }
}
