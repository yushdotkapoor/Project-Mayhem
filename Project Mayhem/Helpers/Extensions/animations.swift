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
            wait(time: Float(dur), actions: {
                self.alpha = 1.0
                i -= 11
                wait(time: Float(dur), actions: {
                    self.flickerIn(iterations: i)
                })
            })
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
            wait(time: Float(dur), actions: {
                self.alpha = 0.0
                i -= 11
                wait(time: Float(dur), actions: {
                    self.flickerOut(iterations: i)
                })
            })
        }
    }
    
    func flickerOut() {
        let i = 10
        flickerOut(iterations: i)
    }
    
    func rotate(rotation: CGFloat, duration: TimeInterval, option: UIView.AnimationOptions) {
        UIView.animate(withDuration: duration, delay: 0.0, options: option) {
            let radians:Float = atan2f(Float(self.transform.b), Float(self.transform.a))
            let angle:CGFloat = CGFloat(radians) + (CGFloat.pi * rotation * 2)
            self.transform = CGAffineTransform(rotationAngle: angle)
        }
    }
    
    func rotate(rotation: CGFloat) {
        rotate(rotation: rotation, duration: 0.75, option: [])
    }
    
    func setRotation(gizmo: CGFloat) {
        rotate(rotation: gizmo, duration: 0.0, option: [])
    }
    
    
    func rippleChap11(thisView:UIView) {
        let shapePosition = CGPoint(x: UIScreen.main.bounds.size.width / 2, y: UIScreen.main.bounds.size.height / 2)
        ripple(view: thisView, position: shapePosition)
    }
    
    func ripple() {
        let shapePosition = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        ripple(view: self, position: shapePosition)
    }
    
    func ripple(view:UIView, position: CGPoint) {
        let path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height))
        
        let rippleShape = CAShapeLayer()
        rippleShape.bounds = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
        rippleShape.path = path.cgPath
        rippleShape.lineWidth = 2
        rippleShape.fillColor = UIColor.clear.cgColor
        rippleShape.strokeColor = UIColor.white.cgColor
        rippleShape.opacity = 0
        rippleShape.position = position
        
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
    
    func add3DMotionShadow(maxOffset: CGFloat, color: CGColor, opacity: Float, offsetY: CGFloat, offsetX: CGFloat) {
        let mot = game.bool(forKey: "reduceMotion")
        if mot {
            return
        }
        layer.shadowOffset = CGSize(width: offsetX, height: offsetY)
        layer.shadowColor = color
        layer.shadowOpacity = opacity
        
        clipsToBounds = false
        let horizontalEffect = UIInterpolatingMotionEffect(
            keyPath: "layer.shadowOffset.width",
            type: .tiltAlongHorizontalAxis)
        horizontalEffect.minimumRelativeValue = maxOffset
        horizontalEffect.maximumRelativeValue = -maxOffset
        
        let verticalEffect = UIInterpolatingMotionEffect(
            keyPath: "layer.shadowOffset.height",
            type: .tiltAlongVerticalAxis)
        verticalEffect.minimumRelativeValue = maxOffset
        verticalEffect.maximumRelativeValue = -maxOffset
        
        let effectGroup = UIMotionEffectGroup()
        effectGroup.motionEffects = [ horizontalEffect,
                                      verticalEffect ]
        
        addMotionEffect(effectGroup)
    }
    
    func add3DMotionShadow(maxOffset: CGFloat, color: CGColor, opacity: Float) {
        add3DMotionShadow(maxOffset: maxOffset, color: color, opacity: opacity, offsetY: 0, offsetX: 0)
    }
    
    func add3DMotionShadow(maxOffset: CGFloat) {
        add3DMotionShadow(maxOffset: maxOffset, color: UIColor.lightGray.cgColor, opacity: 0.5, offsetY: -4, offsetX: 7)
    }
    
    func add3DMotionShadow(maxOffset: CGFloat, offsetY: CGFloat, offsetX: CGFloat) {
        add3DMotionShadow(maxOffset: maxOffset, color: UIColor.black.cgColor, opacity: 0.7, offsetY: offsetY, offsetX: offsetX)
    }
    
    func add3DMotionShadow() {
        add3DMotionShadow(maxOffset: 10)
    }
    
    
    func add3DTileMotion() {
        let mot = game.bool(forKey: "reduceMotion")
        if mot {
            return
        }
        var identity = CATransform3DIdentity
        identity.m34 = -1 / 500.0
        
        let factor = 30 - ((frame.height - 120)/23.0)
        print(factor)
        
        
        let vmaximum = CATransform3DRotate(identity, (factor * .pi) / 180.0, 1.0, 0.0, 0.0)
        let vminimum = CATransform3DRotate(identity, ((365 - factor) * .pi) / 180.0, 1.0, 0.0, 0.0)
        let hmaximum = CATransform3DRotate(identity, (330 * .pi) / 180.0, 0.0, 1.0, 0.0)
        let hminimum = CATransform3DRotate(identity, (30 * .pi) / 180.0, 0.0, 1.0, 0.0)
        
        
        layer.transform = identity
        let horizontalEffect = UIInterpolatingMotionEffect(
            keyPath: "layer.transform",
            type: .tiltAlongHorizontalAxis)
        horizontalEffect.minimumRelativeValue = hminimum
        horizontalEffect.maximumRelativeValue = hmaximum
        
        let verticalEffect = UIInterpolatingMotionEffect(
            keyPath: "layer.transform",
            type: .tiltAlongVerticalAxis)
        verticalEffect.minimumRelativeValue = vminimum
        verticalEffect.maximumRelativeValue = vmaximum
        
        let effectGroup = UIMotionEffectGroup()
        effectGroup.motionEffects = [ horizontalEffect,
                                      verticalEffect ]
        
        addMotionEffect(effectGroup)
    }
    
    
    func startPulse() {
        if !isUserInteractionEnabled || !menuState {
        UIView.animate(withDuration: 0.15, animations: {
            self.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        }, completion: {_ in
            UIView.animate(withDuration: 0.85, delay: 0.15, animations: {
                self.transform = CGAffineTransform(scaleX: 1/1.15, y: 1/1.15)
            }, completion: {_ in
                self.startPulse()
            })
        })
        }
    }
    
    func stopPulse() {
        isUserInteractionEnabled = true
    }
}


