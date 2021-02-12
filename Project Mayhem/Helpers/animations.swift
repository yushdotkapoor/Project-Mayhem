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
    
    
    func ripple(view: UIView) {
        let path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height))
        
        let shapePosition = CGPoint(x: UIScreen.main.bounds.size.width / 2, y: UIScreen.main.bounds.size.height / 2)
        let rippleShape = CAShapeLayer()
        rippleShape.bounds = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
        rippleShape.path = path.cgPath
        rippleShape.lineWidth = 2
        rippleShape.fillColor = UIColor.clear.cgColor
        rippleShape.strokeColor = UIColor.white.cgColor
        rippleShape.opacity = 0
        rippleShape.position = shapePosition
        
        view.layer.addSublayer(rippleShape)
        
        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
        scaleAnim.toValue = NSValue(caTransform3D: CATransform3DMakeScale(2, 2, 1))
        
        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fromValue = 1
        opacityAnim.toValue = nil
        
        let animation = CAAnimationGroup()
        animation.animations = [scaleAnim, opacityAnim]
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.duration = CFTimeInterval(0.7)
        animation.isRemovedOnCompletion = true
        
        rippleShape.add(animation, forKey: "rippleEffect")
    }
    
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.75
        animation.values = [-20.0, 20.0, -15.0, 15.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        layer.add(animation, forKey: "shake")
    }
    
    
    
}
