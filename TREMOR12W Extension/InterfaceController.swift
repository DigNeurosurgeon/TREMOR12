//
//  InterfaceController.swift
//  TREMOR12W Extension
//
//  Created by Pieter Kubben on 05-01-16.
//  Copyright © 2016 DigitalNeurosurgeon.com. All rights reserved.
//

import WatchKit
import WatchConnectivity
import Foundation
import CoreMotion

class InterfaceController: WKInterfaceController {

    @IBOutlet var recordButton: WKInterfaceButton!
    @IBOutlet var statusLabel: WKInterfaceLabel!
    lazy var motionManager = CMMotionManager()
    lazy var tremorSamples = [TremorSample]()
    var timeIntervalAtLastBoot = NSTimeInterval()
    var isRecording = false
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Calculate offset for CMDeviceMotion timestamps
        let secondsSinceReferenceDate = NSDate().timeIntervalSinceReferenceDate
        let secondsSinceLastBoot = NSProcessInfo().systemUptime
        timeIntervalAtLastBoot = secondsSinceReferenceDate - secondsSinceLastBoot
    }
    
    
    // MARK: - Recording


    @IBAction func onRecord() {
        if !isRecording {
            startRecording()
        } else {
            stopRecording()
        }
    }
    
    func startRecording() {
        startMotionManager()
        isRecording = true
        recordButton.setTitle("Stop")
        statusLabel.setText("")
    }
    
    func stopRecording() {
        stopMotionManager()
        isRecording = false
        recordButton.setTitle("Record")
        
        // Send data to iPhone
        statusLabel.setHidden(true)
        let session = WCSession.defaultSession()
        
        if session.reachable {
            let dataValues = ["data": tremorSamples]
            statusLabel.setText("Sending data...")
            
            session.sendMessage(dataValues,
                replyHandler: { reply in
                    self.statusLabel.setHidden(false)
                    self.statusLabel.setText(reply["status"] as? String)
                }, errorHandler: { error in
                    self.statusLabel.setText("Error: \(error)")
            })
        }
    }
    
    
    // MARK: - Motion manager
    
    
    func startMotionManager() {
        if motionManager.accelerometerAvailable {
            
            let queue = NSOperationQueue()
            motionManager.startDeviceMotionUpdatesToQueue(queue,
                withHandler: { (motion: CMDeviceMotion?, error: NSError?) in
                    self.collectTremorSamples(motion, error: error)
            })
            
        } else {
            print("Accelerometer is not available.")
        }
    }
    
    
    func stopMotionManager() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    
    
    // MARK: - Tremor samples
    
    
    func collectTremorSamples(motion: CMDeviceMotion!, error: NSError!)  {
        if (error != nil) {
            print(error)
        }
        
        let attitude: CMAttitude = motion.attitude
        let attRoll = attitude.roll
        let attYaw = attitude.yaw
        let attPitch = attitude.pitch
        
        let rotation: CMRotationRate = motion.rotationRate
        let rotX = rotation.x
        let rotY = rotation.y
        let rotZ = rotation.z
        
        let acceleration: CMAcceleration = motion.userAcceleration
        let accX = acceleration.x
        let accY = acceleration.y
        let accZ = acceleration.z
        
        let gravity: CMAcceleration = motion.gravity
        let gravX = CGFloat(gravity.x)
        let gravY = CGFloat(gravity.y)
        let gravZ = CGFloat(gravity.z)
        
        let timeStamp = motion.timestamp
        let timeStampSince2001 = timeIntervalAtLastBoot + timeStamp
        let timeStampSince2001Milliseconds = timeStampSince2001 * 1000
        
        let sample = TremorSample(roll: attRoll, yaw: attYaw, pitch: attPitch, rotX: rotX, rotY: rotY, rotZ: rotZ, accX: accX, accY: accY, accZ: accZ, gravX: gravX, gravY: gravY, gravZ: gravZ, datetime: timeStampSince2001Milliseconds)
        
        tremorSamples.append(sample)
        
    }

}
