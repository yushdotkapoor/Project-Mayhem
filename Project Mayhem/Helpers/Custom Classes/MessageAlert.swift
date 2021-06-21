//
//  MessageAlert.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 2/16/21.
//

import UIKit

class MessageAlert: NSObject {
    
    private let backgroundView:UIView = UIView()
    
    private let alertView: UIView = {
        let alert = UIView()
        alert.backgroundColor = .darkGray
        alert.clipsToBounds = true
        alert.layer.masksToBounds = true
        alert.layer.cornerRadius = 15
        return alert
    }()
    
    
    @objc func tapExit(touch: CustomTapGestureRecognizer) {
        let touchPoint = touch.location(in: backgroundView)
        let location:CGPoint = CGPoint(x: touchPoint.x, y: touchPoint.y)
        
        if !alertView.frame.contains(location) {
            cancel()
            touch.button?.sendActions(for: .touchUpInside)
        }
    }
    
    func cancel() {
        backgroundView.gestureRecognizers?.forEach(backgroundView.removeGestureRecognizer)
    }
    
    func getGradientBasedOnTitle(title: String) -> CAGradientLayer {
        let grad = CAGradientLayer()
        
        switch title {
        case "\(messageFrom) Vision Consolidated":
            //purple gradient
            grad.colors = [UIColor(red: 128/255, green: 0, blue: 128/255, alpha: 1.0).cgColor, UIColor(red: 216/255, green: 191/255, blue: 216/255, alpha: 1.0).cgColor]
            break
        case "\(messageFrom) Victoria Lambson":
            //red
            grad.colors = [UIColor(red: 220/255, green: 28/255, blue: 19/255, alpha: 1.0).cgColor, UIColor(red: 246/255, green: 189/255, blue: 192/255, alpha: 1.0).cgColor]
            break
        case "\(messageFrom) Yush Raj Kapoor":
            //green
            grad.colors = [UIColor(red: 0, green: 86/255, blue: 62/255, alpha: 1.0).cgColor, UIColor(red: 0, green: 180/255, blue: 134/255, alpha: 1.0).cgColor]
            break
        case "\(messageFrom) Defender Command":
            //orange
            grad.colors = [UIColor(red: 255/255, green: 128/255, blue: 0/255, alpha: 1.0).cgColor, UIColor(red: 249/255, green: 192/255, blue: 136/255, alpha: 1.0).cgColor]
            break
        default:
            break
        }
        
        return grad
        
    }
    
    func showAlert(title: String, message: String, viewController: UIViewController, buttonPush: Selector) {
        guard let targetView = viewController.view else {
            return
        }
        backgroundView.frame = targetView.frame
        targetView.addSubview(backgroundView)
        
        alertView.isUserInteractionEnabled = true
        
        var width = UIScreen.main.bounds.width-40
        if width > 500 {
            width = 500
        }
        
        
        alertView.frame = CGRect(x: 0, y: 0, width: width, height: 100)
        let gradient = getGradientBasedOnTitle(title: title)
        alertView.isHidden = true
        alertView.alpha = 0.0
        
        let alertViewFrame = alertView.frame.size
        
        
        let titleLabelHeight = heightForView(text: title, font: UIFont(name: "Helvetica", size: 25.0)!, width: alertViewFrame.width - 10)
        //create a title label
        let titleLabel = UILabel(frame: CGRect(x: 10, y: 0, width: alertViewFrame.width - 20, height: titleLabelHeight))
        titleLabel.numberOfLines = 0
        titleLabel.text = title
        titleLabel.font = titleLabel.font.withSize(25)
        titleLabel.textAlignment = .center
        let titleFrame = titleLabel.frame
        titleLabel.textColor = .white
        
        var msgbtn = messageAndButton(message: message, viewController: viewController, buttonPush: buttonPush, titleHeight: titleLabelHeight, smallFont: false)
        
        //resize alertView
        alertView.frame = CGRect(x: 0, y: 0, width: width, height: msgbtn.messageLabel.frame.size.height + titleFrame.height + 60)
        
        if (alertView.frame.size.height > UIScreen.main.bounds.height-210) {
            msgbtn = messageAndButton(message: message, viewController: viewController, buttonPush: buttonPush, titleHeight: titleLabelHeight, smallFont: true)
            
            alertView.frame = CGRect(x: 0, y: 0, width: width, height: msgbtn.messageLabel.frame.size.height + titleFrame.height + 60)
        }
        
        alertView.center = targetView.center
        gradient.frame = alertView.bounds
        alertView.layer.addSublayer(gradient)
        targetView.addSubview(alertView)
        alertView.addSubview(titleLabel)
        alertView.addSubview(msgbtn.messageLabel)
        alertView.addSubview(msgbtn.button)
        
        //animate alertView in
        UIView.animate(withDuration: 0.5, animations: {
            self.alertView.isHidden = false
            self.alertView.alpha = 1.0
        })
        
        let tap = CustomTapGestureRecognizer(target: self, action: #selector(tapExit))
        tap.button = msgbtn.button
        backgroundView.addGestureRecognizer(tap)
    }
    
    
    func messageAndButton(message: String, viewController: UIViewController, buttonPush: Selector, titleHeight: CGFloat, smallFont: Bool) -> (messageLabel: UILabel, button: UIButton) {
        var msgFontSize:CGFloat = 16
        if smallFont {
            msgFontSize = 13
        }
        
        
        let messageLabelHeight = heightForView(text: message, font: UIFont(name: "Helvetica", size: msgFontSize)!, width: alertView.frame.size.width - 10)
        //create the message label
        let messageLabel = UILabel(frame: CGRect(x: 5, y: titleHeight + 10, width: alertView.frame.size.width - 10, height: messageLabelHeight))
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.font = messageLabel.font.withSize(msgFontSize)
        messageLabel.textAlignment = .center
        messageLabel.textColor = .white
        
        //create Button with outline to close the alert
        let button = CustomButtonOutline()
        button.frame = CGRect(x: alertView.frame.size.width / 2 - 37.5, y: messageLabel.frame.size.height + titleHeight + 20, width: 75, height: 25)
        button.setupButton()
        button.setTitle("Close".localized(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(viewController, action: buttonPush, for: .touchUpInside)
        
        return (messageLabel, button)
    }
    
    
    func dismissAlert() {
        UIView.animate(withDuration: 0.5, animations: {
            self.alertView.alpha = 0.0
        }, completion: { done in
            if done {
                self.alertView.removeFromSuperview()
                self.backgroundView.removeFromSuperview()
            }
        })
    }
}


class CustomTapGestureRecognizer: UITapGestureRecognizer {
   var button: UIButton?
}

