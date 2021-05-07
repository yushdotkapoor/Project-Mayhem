//
//  CustomButtonOutline.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 12/22/20.
//

import UIKit

class CustomButtonOutline: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame:frame)
    }
    
    required init?(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func setupButton() {
        let height = frame.size.height
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
        layer.cornerRadius = height/2
        addHaptic()
    }
    
    func setupButton(color: UIColor) {
       setupButtonWithoutHaptic(color: color)
        addHaptic()
    }
    
    func setupButtonWithoutHaptic(color: UIColor) {
        let height = frame.size.height
        
        layer.borderWidth = 1
        layer.borderColor = color.cgColor
        layer.cornerRadius = height/2
    }
    
    func setupButton(color: UIColor, textColor: UIColor) {
        let height = frame.size.height
        
        layer.borderWidth = 1
        layer.borderColor = color.cgColor
        layer.cornerRadius = height/2
        addHaptic()
    }
    
    func addHaptic() {
        addAction(UIAction(handler: {_ in
            impact(style: .medium)
        }), for: .touchDown)
    }
    
}

