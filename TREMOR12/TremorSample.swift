//
//  Coordinate.swift
//  TremorDBS
//
//  Created by Pieter Kubben on 20-05-15.
//  Copyright (c) 2015 DigitalNeurosurgeon.com. All rights reserved.
//

import UIKit

class TremorSample{
    
    let roll, yaw, pitch: Double
    let rotX, rotY, rotZ: Double
    let accX, accY, accZ: Double
    let gravX, gravY, gravZ: CGFloat
    let datetime: NSTimeInterval
    
    
    var description: String {
        let output =    "Roll: \(roll)   Yaw: \(yaw)   Pitch: \(pitch) \n" +
                        "RotX: \(rotX)   RotY: \(rotY)   RotZ: \(rotZ) \n" +
                        "AccX: \(accX)   AccY: \(accY)   AccZ: \(accZ) \n" +
                        "GravX: \(gravX)   GravY: \(gravY)   GravZ: \(gravZ)" +
                        "Datetime: \(datetime) \n\n"
        
        return output
    }
    
    
    init(roll: Double = 0.0, yaw: Double = 0.0, pitch: Double = 0.0,
         rotX: Double = 0.0, rotY: Double = 0.0, rotZ: Double = 0.0,
         accX: Double = 0.0, accY: Double = 0.0, accZ: Double = 0.0,
         gravX: CGFloat = 0.0, gravY: CGFloat = 0.0, gravZ: CGFloat = 0.0,
         datetime: NSTimeInterval = NSDate().timeIntervalSinceReferenceDate) {
        
        self.roll = roll; self.yaw = yaw; self.pitch = pitch
        self.rotX = rotX; self.rotY = rotY; self.rotZ = rotZ
        self.accX = accX; self.accY = accY; self.accZ = accZ
        self.gravX = gravX; self.gravY = gravY; self.gravZ = gravZ
        self.datetime = datetime
    }
    
    
    func exportAsCommaSeparatedValues() -> String {
        let csv = "\(datetime),\(roll),\(yaw),\(pitch),\(rotX),\(rotY),\(rotZ),\(accX),\(accY),\(accZ),\(gravX),\(gravY),\(gravZ)\n"
        
        return csv
    }
    
}