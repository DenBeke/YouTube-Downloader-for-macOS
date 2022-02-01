//
//  crash_report.swift
//  Youtube Downloader
//
//  Created by Mathias Beke on 01/02/2022.
//  Copyright © 2022 Mathias Beke. All rights reserved.
//

import Foundation

import Sentry



func sendCrashReport(err: Error) {
    // TODO implement this
    print("sending crash report to Sentry...")
    
    SentrySDK.start { options in
            options.dsn = "https://4a4d6b6204844d08bd72a83b7c83ea05@o658684.ingest.sentry.io/6178630"
        }
    
    
    SentrySDK.configureScope { scope in
        scope.setExtra(value: err, key: "original-error")
        scope.setLevel(.error)
    }
    
    SentrySDK.capture(message: err.localizedDescription)
}
