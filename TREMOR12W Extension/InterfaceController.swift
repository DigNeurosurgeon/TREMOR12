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
    let motionManager = CMMotionManager()
    lazy var tremorSamples = [TremorSample]()
    var timeIntervalAtLastBoot = NSTimeInterval()
    var isRecording = false
    var accX = [Double]()
    var accY = [Double]()
    var accZ = [Double]()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        statusLabel.setText("")
        
        // Calculate offset for CMDeviceMotion timestamps
        let secondsSinceReferenceDate = NSDate().timeIntervalSinceReferenceDate
        let secondsSinceLastBoot = NSProcessInfo().systemUptime
        timeIntervalAtLastBoot = secondsSinceReferenceDate - secondsSinceLastBoot
    }
    
    
    override func didDeactivate() {
        super.didDeactivate()
        stopMotionManager()
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
        statusLabel.setText("Recording...")
        statusLabel.setHidden(false)
    }
    
    func stopRecording() {
        stopMotionManager()
        isRecording = false
        recordButton.setTitle("Record")
        statusLabel.setHidden(true)
        
        // Send data to iPhone
        let session = WCSession.defaultSession()
        
        if session.reachable {
            let dataValues = ["accX": accX, "accY": accY, "accZ": accZ]
            statusLabel.setText("Sending data...")
            self.statusLabel.setHidden(false)
            
            session.sendMessage(dataValues,
                replyHandler: { reply in
                    self.statusLabel.setText(reply["status"] as? String)
                    self.resetWatchSamples()
                }, errorHandler: { error in
                    self.statusLabel.setText("Error: \(error)")
                    print("Session error after recording: \(error)")
            })
        } else {
            print("WCSession on Watch not reachable")
        }
    }
    
    private func resetWatchSamples() {
        accX = [Double]()
        accY = [Double]()
        accZ = [Double]()
    }
    
    
    // MARK: - Motion manager
    
    
    func startMotionManager() {
        
        if motionManager.accelerometerAvailable {
//            motionManager.accelerometerUpdateInterval = 0.1
            let handler:CMAccelerometerHandler = {(data: CMAccelerometerData?, error: NSError?) -> Void in
                let acceleration = data!.acceleration
                self.accX.append(acceleration.x)
                self.accY.append(acceleration.y)
                self.accZ.append(acceleration.z)
            }
            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: handler)
        }
        
//        Functionality below not yet available in watchOS2 (last update: Jan 10, 2016)
        
//        if motionManager.gyroAvailable {
//            motionManager.gyroUpdateInterval = 0.1
//            let gyroHandler: CMGyroHandler = {(gyroData: CMGyroData?, error: NSError?) -> Void in
//                let rotXValue = gyroData!.rotationRate.x
//                rotXString = String(format: "%.2f", rotXValue)
//                self.statusLabel.setText("rotX: \(rotXString)")
//                self.rotX.append(rotXValue)
//            }
//            motionManager.startGyroUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: gyroHandler)
//        }
        
//        motionManager.deviceMotionUpdateInterval = 0.1
//        if motionManager.deviceMotionAvailable {
//            let handler:CMDeviceMotionHandler = {(motion: CMDeviceMotion?, error: NSError?) -> Void in
//                let acceleration: CMAcceleration = motion!.userAcceleration
//                let accXString = String(format: "%.2f", acceleration.x)
//                self.accX.append(acceleration.x)
//                
//                let rotationRate: CMRotationRate = motion!.rotationRate
//                let rotXString = String(format: "%.2f", rotationRate.x)
//                self.rotX.append(rotationRate.x)
//                
//                self.statusLabel.setText("accX: \(accXString) \n\rotX: \(rotXString)")
//            }
//            motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: handler)
//            
//        } else {
//            self.statusLabel.setText("CMDeviceMotion unavailable")
//        }

    }
    
    
    func stopMotionManager() {
        //motionManager.stopDeviceMotionUpdates()
        motionManager.stopAccelerometerUpdates()
    }
    
    
    // MARK: - Tremor samples
    
    /*
    // Not possible yet (last update: Jan 10, 2016)
    
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
        print(sample.description)
    }
    */

}
