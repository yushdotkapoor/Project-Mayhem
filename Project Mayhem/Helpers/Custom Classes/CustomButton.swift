//
//  CustomButton.swift
//  Key Club
//
//  Created by Yush Raj Kapoor on 7/28/20.
//  Copyright © 2020 Yush Raj Kapoor. All rights reserved.
//

import UIKit
import AudioToolbox

class CustomButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setupButton()
    }
    
    required init?(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    
    func setupButton() {
        let height = frame.size.height
        if #available(iOS 11.0, *) {
            if isSpringLoaded {
                backgroundColor = UIColor.gray
            }
            else {
                backgroundColor = UIColor.white
            }
        } else {
            backgroundColor = UIColor.white
        }
        layer.cornerRadius = height/2
        addHaptic()
    }
    
    func setupButton(color: UIColor, pressColor: UIColor) {
        let height = frame.size.height
        if #available(iOS 11.0, *) {
            if isSpringLoaded {
                backgroundColor = pressColor
            }
            else {
                backgroundColor = color
            }
        } else {
            backgroundColor = color
        }
        layer.cornerRadius = height/2
        addHaptic()
    }
    
    func addOutline(color: CGColor) {
        layer.borderWidth = 2
        layer.borderColor = color
    }
    
    func addHaptic() {
        addAction(UIAction(handler: {_ in
            impact(style: .medium)
        }), for: .touchDown)
        
        addAction(UIAction(handler: {_ in
            impact(style: .light)
        }), for: .touchUpInside)
    }
    
    
}
