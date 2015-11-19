//
//  TremorViewController.swift
//  TremorDBS
//
//  Created by Pieter Kubben on 20-05-15.
//  Copyright (c) 2015 DigitalNeurosurgeon.com. All rights reserved.
//
//

import UIKit
import CoreMotion
import MessageUI

class TremorViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var recordingIndicator: UIActivityIndicatorView!

    lazy var motionManager = CMMotionManager()
    lazy var tremorSamples = [TremorSample]()
    var timeIntervalAtLastBoot = NSTimeInterval()
    var samplingStarted = false
    var notificationForResearchOnlyPresented = false
    
    
    // MARK: - Base functions
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Calculate offset for CMDeviceMotion timestamps
        let secondsSinceReferenceDate = NSDate().timeIntervalSinceReferenceDate
        let secondsSinceLastBoot = NSProcessInfo().systemUptime
        timeIntervalAtLastBoot = secondsSinceReferenceDate - secondsSinceLastBoot
        
        // Initialize empty sample
        _ = TremorSample()
    }

    
    override func viewDidAppear(animated: Bool) {
        if !notificationForResearchOnlyPresented {
            showNotificationForResearchOnly()
        }
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        stopMotionManager()
    }
    
    
    override func didReceiveMemoryWarning() {
        startStopSampling(self)
        showNotificationAfterRecording("Memory warning", messageText: "Continuing measurements may result in loss of data or crashing the app. What do you want to do?")
    }
    
    
    // MARK: - Motion manager
    
    
    func startMotionManager() {
        if motionManager.accelerometerAvailable {
            
            let queue = NSOperationQueue()
            
            motionManager.startDeviceMotionUpdatesToQueue(queue, 
            /*motionManager.startDeviceMotionUpdatesUsingReferenceFrame(CMAttitudeReferenceFrame.XMagneticNorthZVertical, toQueue: queue,*/
                withHandler: { (motion: CMDeviceMotion?, error: NSError?) in
                    self.collectTremorSamples(motion, error: error)

                // Use code below if interaction with UI is required 
                // (UI code needs to run on main thread)
                /* dispatch_sync(dispatch_get_main_queue()) {
                    self.collectTremorSamples(motion, error: error)
                } */
                
            })
            
        } else {
            print("Accelerometer is not available.")
        }
    }
    
    
    func stopMotionManager() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    
    @IBAction func startStopSampling(sender: AnyObject) {
        
        if !samplingStarted {
            startMotionManager()
            startStopButton.setTitle("Stop", forState: .Normal)
            samplingStarted = true
            recordingIndicator.startAnimating()
        } else {
            stopMotionManager()
            startStopButton.setTitle("Record", forState: .Normal)
            samplingStarted = false
            recordingIndicator.stopAnimating()
            showNotificationAfterRecording("Question", messageText: "What do you want to do?")
        }
        
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
        
//        let magneticField: CMCalibratedMagneticField = motion.magneticField
//        let magX = magneticField.field.x
//        let magY = magneticField.field.y
//        let magZ = magneticField.field.z
//        
//        let magneticFieldCalibrationAccuracy: CMMagneticFieldCalibrationAccuracy = magneticField.accuracy
//        let magneticFieldCalibrationAccuracyValue = magneticFieldCalibrationAccuracy.value
        
        let timeStamp = motion.timestamp
        let timeStampSince2001 = timeIntervalAtLastBoot + timeStamp
        let timeStampSince2001Milliseconds = timeStampSince2001 * 1000
        
        let sample = TremorSample(roll: attRoll, yaw: attYaw, pitch: attPitch, rotX: rotX, rotY: rotY, rotZ: rotZ, accX: accX, accY: accY, accZ: accZ, gravX: gravX, gravY: gravY, gravZ: gravZ, datetime: timeStampSince2001Milliseconds)
        
        tremorSamples.append(sample)
        
    }
    
    
    @IBAction func resetSamples(sender: AnyObject) {
        let alertController = UIAlertController(title: "Please confirm", message: "Are you sure you want to delete the samples?", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive) { (action) -> Void in
            self.tremorSamples = [TremorSample]()
        }
        alertController.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: - Export data
    
    
    @IBAction func exportSamples(sender: AnyObject) {
        // Create output
        var csvText = "timestamp2001_ms,roll,pitch,yaw,rotX,rotY,rotZ,accX,accY,accZ,gravX,gravY,gravZ\n"
        for sample in tremorSamples {
            csvText += sample.exportAsCommaSeparatedValues()
        }
        
        // Save output to file
        let dirPaths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let docsDir = dirPaths[0] 
        let csvFileName = "tremor_samples.csv"
        let csvFilePath = docsDir.stringByAppendingString("/" + csvFileName)
        do {
            try csvText.writeToFile(csvFilePath, atomically: true, encoding: NSUTF8StringEncoding)
        } catch let error as NSError {
            print("File creation failed with error: \(error.localizedDescription)")
        }
        
        // Create email form
        let email = MFMailComposeViewController()
        email.mailComposeDelegate = self
        email.setSubject("TREMOR12 samples as CSV file")
        email.setMessageBody("Optional comments: \n\n", isHTML: false)
        let csvData = NSData(contentsOfFile: csvFilePath)
        email.addAttachmentData(csvData!, mimeType: "text/csv", fileName: csvFileName)
        presentViewController(email, animated: true, completion: nil)
    }
    
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - Notifications
    
    
    func showNotificationForResearchOnly() {
        let warningMessage = "This tool is only meant for research and not for direct patient treatment."
        let warningController = UIAlertController(title: "Warning", message: warningMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let confirmAction = UIAlertAction(title: "I understand", style: UIAlertActionStyle.Default, handler: nil)
        warningController.addAction(confirmAction)
        presentViewController(warningController, animated: true, completion: nil)
        
        notificationForResearchOnlyPresented = true
    }
    
    
    func showNotificationAfterRecording(titleText: String, messageText: String) {
        
        let controller = UIAlertController(title: titleText, message: messageText, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let continueAction = UIAlertAction(title: "Continue measurements", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.startStopSampling(self)
        }
        controller.addAction(continueAction)
        
        let exportAction = UIAlertAction(title: "Export data", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.exportSamples(self)
        }
        controller.addAction(exportAction)
        
        let deleteAction = UIAlertAction(title: "Delete data", style: UIAlertActionStyle.Destructive) { (action) -> Void in
            self.resetSamples(self)
        }
        controller.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        controller.addAction(cancelAction)
        
        presentViewController(controller, animated: true, completion: nil)
    }
    
}
