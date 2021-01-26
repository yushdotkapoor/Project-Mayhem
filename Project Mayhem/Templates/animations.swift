//
//  animations.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 12/30/20.
//

import UIKit

extension UIView {
  func blurView(style: UIBlurEffect.Style) {
    var blurEffectView = UIVisualEffectView()
    let blurEffect = UIBlurEffect(style: style)
    blurEffectView = UIVisualEffectView(effect: blurEffect)
    blurEffectView.frame = bounds
    addSubview(blurEffectView)
  }
  
  func removeBlur() {
    for view in self.subviews {
      if let view = view as? UIVisualEffectView {
        view.removeFromSuperview()
      }
    }
  }
    
    func fadeIn() {
        UIView.animate(withDuration: 1.0) {
            self.alpha = 1.0
            }
    }

    func fadeOut() {
        UIView.animate(withDuration: 1.0) {
            self.alpha = 0.0
            }
    }
    
    
}


