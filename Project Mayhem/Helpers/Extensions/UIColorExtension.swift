//
//  UIColorExtension.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 2/16/21.
//

import Foundation
import UIKit

extension UIColor {
    
    func inverted() -> UIColor {
        let rgbColorNext = CIColor(color: self)
        let red:CGFloat = 255 - rgbColorNext.red * 255
        let green:CGFloat = 255 - rgbColorNext.green * 255
        let blue:CGFloat = 255 - rgbColorNext.blue * 255
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1.0)
    }
}
