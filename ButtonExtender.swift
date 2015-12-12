//
//  ButtonExtender.swift
//  RunnerApp
//
//  Created by Prescott | Neshagaran on 11/12/15.
//  Copyright © 2015 Prescott | Neshagaran. All rights reserved.
//

import Foundation
import UIKit


class ButtonExtender: UIButton {
    @IBInspectable var borderColor: UIColor = UIColor.whiteColor() {
        didSet {
            layer.borderColor = borderColor.CGColor
        }
    }
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var shadowColor: UIColor = UIColor.whiteColor() {
        didSet {
            layer.shadowColor = shadowColor.CGColor
        }
    }
    @IBInspectable var shadowOpacity: Float = 0 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
    @IBInspectable var shadowRadius: CGFloat = 0 {
        didSet {
            layer.shadowRadius = shadowRadius
            layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
            layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 12.0).CGPath
        }
    }
    
    

}