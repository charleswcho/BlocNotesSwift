//
//  Colors.swift
//  BlocNotes
//
//  Created by Charles Wesley Cho on 8/4/15.
//  Copyright (c) 2015 Charles Wesley Cho. All rights reserved.
//

import UIKit

class Colors: NSObject {
   
    let colorTop = UIColor(red: 0.0/255.0, green: 128.0/255.0, blue: 255.0/255.0, alpha: 1.0).CGColor
    let colorBottom = UIColor(red: 153.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0).CGColor
    
    let gl: CAGradientLayer
    
    override init() {
        gl = CAGradientLayer()
        gl.colors = [ colorTop, colorBottom]
        gl.locations = [ 0.0, 1.0]
    }
}