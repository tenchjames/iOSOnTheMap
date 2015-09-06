//
//  BackgroundView.swift
//  OnTheMap
//
//  Created by James Tench on 8/29/15.
//  Copyright (c) 2015 James Tench. All rights reserved.
//

import UIKit

class BackgroundView: UIView {
    
    // An orange gradient background
    override func drawRect(rect: CGRect) {
        let lightOrange: UIColor = UIColor(red: 1.0, green: 0.717, blue: 0.419, alpha: 1.0)
        let darkerOrange: UIColor = UIColor(red: 1.0, green: 0.498, blue: 0.016, alpha: 1.0)
        
        let context = UIGraphicsGetCurrentContext()
        let orangeGradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), [lightOrange.CGColor, darkerOrange.CGColor], [0,1])
        
        let backgroundPath = UIBezierPath(rect: CGRectMake(0, 0, self.frame.width, self.frame.height))
        CGContextSaveGState(context)
        backgroundPath.addClip()
        CGContextDrawLinearGradient(context, orangeGradient, CGPointMake(160, 0), CGPointMake(160, 568),UInt32(kCGGradientDrawsBeforeStartLocation) | UInt32(kCGGradientDrawsAfterEndLocation))
        CGContextRestoreGState(context)
    }
    

}
