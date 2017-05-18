//
//  ExtensionFunctions.swift
//  DarkSpaceRPG
//
//  Created by James Tran on 5/17/17.
//  Copyright © 2017 James Tran. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import CoreMotion

let playerLaserCategory:UInt32 =  0x1 << 1
let enemyShipCategory:UInt32 =  0x1 << 2
let floorCategory:UInt32 = 0x1 << 3
let roofCategory:UInt32 = 0x1 << 4
let playerCategory:UInt32 = 0x1 << 5
let playerShieldCategory:UInt32 = 0x1 << 6
let enemyLaserCategory:UInt32 = 0x1 << 7


func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

func > (left: CGVector, right: CGVector) -> Bool {
    if left.length() > right.length() {
        return true
    } else {
        return false
    }
}

func < (left: CGVector, right: CGVector) -> Bool {
    if left.length() < right.length() {
        return true
    } else {
        return false
    }
}

extension CGVector {
    func length() -> Float {
        return sqrt(Float(dx*dx + dy*dy))
    }
}

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}
