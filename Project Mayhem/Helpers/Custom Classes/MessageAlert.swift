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
    
    func showAlert(title: String, message: String, viewController: UIViewController, buttonPush: Selector) {
        guard let targetView = viewController.view else {
            return
        }
        
        backgroundView.frame = targetView.bounds
        targetView.addSubview(backgroundView)
        
        alertView.isUserInteractionEnabled = true
        alertView.frame = CGRect(x: 0, y: 0, width: targetView.frame.size.width-80, height: 100)
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor(red: 128/255, green: 0, blue: 128/255, alpha: 1.0).cgColor, UIColor(red: 216/255, green: 191/255, blue: 216/255, alpha: 1.0).cgColor]
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
        
        
        let messageLabelHeight = heightForView(text: message, font: UIFont(name: "Helvetica", size: 16.0)!, width: alertViewFrame.width - 10)
        //create the message label
        let messageLabel = UILabel(frame: CGRect(x: 5, y: titleFrame.size.height + 10, width: alertViewFrame.width - 10, height: messageLabelHeight))
        messageLabel.numberOfLines = 0
        messageLabel.text = message
        messageLabel.font = messageLabel.font.withSize(16)
        messageLabel.textAlignment = .center
        messageLabel.textColor = .white
        
        //create Button with outline to close the alert
        let button = CustomButtonOutline()
        button.frame = CGRect(x: alertView.frame.size.width / 2 - 37.5, y: messageLabel.frame.size.height + titleLabel.frame.size.height + 30, width: 75, height: 25)
        button.setupButton()
        button.setTitle("Close", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(viewController, action: buttonPush, for: .touchUpInside)
        
        
        //resize alertView
        alertView.frame = CGRect(x: 0, y: 0, width: targetView.frame.size.width-80, height: messageLabel.frame.size.height + titleFrame.height + 70)
        alertView.center = targetView.center
        gradient.frame = alertView.bounds
        alertView.layer.addSublayer(gradient)
        targetView.addSubview(alertView)
        alertView.addSubview(titleLabel)
        alertView.addSubview(messageLabel)
        alertView.addSubview(button)
        
        //animate alertView in
        UIView.animate(withDuration: 0.5, animations: {
            self.alertView.isHidden = false
            self.alertView.alpha = 1.0
        })
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

