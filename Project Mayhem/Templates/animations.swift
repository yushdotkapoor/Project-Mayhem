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
    
    func flickerIn(iterations:Int) {
        var i = iterations + 10
        if i > 10 {
            self.alpha = 0.0
            let last = 1.0 / (2.0 * Double(i))
            let dur = Double.random(in: 0..<last)
            DispatchQueue.main.asyncAfter(deadline: .now() + dur) {
                self.alpha = 1.0
                i -= 11
                DispatchQueue.main.asyncAfter(deadline: .now() + dur) {
                    self.flickerIn(iterations: i)
                }
            }
        }
    }
    
    func flickerIn() {
        let i = 10
        flickerIn(iterations: i)
    }
    
    
    func flickerOut(iterations:Int) {
        var i = iterations + 10
        if i > 0 {
            self.alpha = 1.0
            let last = 1.0 / (2.0 * Double(i))
            let dur = Double.random(in: 0..<last)
            DispatchQueue.main.asyncAfter(deadline: .now() + dur) {
                self.alpha = 0.0
                i -= 11
                DispatchQueue.main.asyncAfter(deadline: .now() + dur) {
                    self.flickerOut(iterations: i)
                }
            }
        }
    }
    
    
    func flickerOut() {
        let i = 10
        flickerOut(iterations: i)
    }
    
    
    
    func rotate(rotation: CGFloat, duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            
            let radians:Float = atan2f(Float(self.transform.b), Float(self.transform.a))
            let angle:CGFloat = CGFloat(radians) + (CGFloat.pi * rotation * 2)
            self.transform = CGAffineTransform(rotationAngle: angle)
        }
    }
    
    func rotate(rotation: CGFloat) {
        rotate(rotation: rotation, duration: 0.75)
    }
    
    func setRotation(gizmo: CGFloat) {
        rotate(rotation: gizmo, duration: 0.0)
    }
    
}

