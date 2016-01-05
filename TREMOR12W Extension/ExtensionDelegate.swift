//
//  ExtensionDelegate.swift
//  TREMOR12W Extension
//
//  Created by Pieter Kubben on 05-01-16.
//  Copyright © 2016 DigitalNeurosurgeon.com. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
    
    func applicationDidFinishLaunching() {
        setupConnectivity()
    }
    
    private func setupConnectivity() {
        if WCSession.isSupported() {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
    }
    
}
