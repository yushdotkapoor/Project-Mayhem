//
//  HintAlert.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 2/13/21.
//

import UIKit

class HintAlert: NSObject {
    
    private let backgroundView:UIView = UIView()
    
    private var hint:UIButton?
    
    private let alertView: UIView = {
        let alert = UIView()
        alert.backgroundColor = .darkGray
        alert.clipsToBounds = true
        alert.layer.masksToBounds = true
        alert.layer.cornerRadius = 15
        return alert
    }()
    
    func showAlert(message: String, viewController: UIViewController, hintButton: UIButton) {
        hint = hintButton
        let alertController = UIAlertController(title: "Are you sure?", message: "Are you sure you would like to see a hint?", preferredStyle: .alert)
        let no = UIAlertAction(title: "No", style: .default, handler: {_ in
            self.dismissAlert()
        })
        let yes = UIAlertAction(title: "Yes", style: .default, handler: {_ in
            self.okActuallyShowTheHint(message: message, viewController: viewController, hintButton: hintButton)
        })
        alertController.addAction(no)
        alertController.addAction(yes)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    func okActuallyShowTheHint(message: String, viewController: UIViewController, hintButton: UIButton) {
        guard let targetView = viewController.view else {
            return
        }
        
        backgroundView.frame = targetView.bounds
        targetView.addSubview(backgroundView)
        
        alertView.isUserInteractionEnabled = true
        alertView.frame = CGRect(x: 0, y: 0, width: targetView.frame.size.width-80, height: 100)
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor(named: "MayhemBlue")!.cgColor, UIColor(named: "MayhemGray")!.cgColor]
        alertView.isHidden = true
        alertView.alpha = 0.0
        
        let alertViewFrame = alertView.frame.size
        
        
        let titleLabelHeight = heightForView(text: "Hint", font: UIFont(name: "Helvetica", size: 25.0)!, width: alertViewFrame.width - 10)
        //create a title label
        let titleLabel = UILabel(frame: CGRect(x: 5, y: 0, width: alertViewFrame.width - 10, height: titleLabelHeight))
        titleLabel.numberOfLines = 0
        titleLabel.text = "Hint"
        titleLabel.font = titleLabel.font.withSize(25)
        titleLabel.textAlignment = .center
        let titleFrame = titleLabel.frame
        titleLabel.textColor = .white
        
        
        let messageLabelHeight = heightForView(text: message, font: UIFont(name: "Helvetica", size: 16.0)!, width: alertViewFrame.width - 10)
        //create the message label
        let messageLabel = UILabel(frame: CGRect(x: 5, y: titleFrame.size.height, width: alertViewFrame.width - 10, height: messageLabelHeight))
        messageLabel.numberOfLines = 0
        messageLabel.text = message
        messageLabel.font = messageLabel.font.withSize(16)
        messageLabel.textAlignment = .center
        messageLabel.textColor = .white
        
        //create Button with outline to close the alert
        let button = CustomButtonOutline()
        button.frame = CGRect(x: alertView.frame.size.width / 2 - 37.5, y: messageLabel.frame.size.height + titleLabel.frame.size.height + 10, width: 75, height: 25)
        button.setupButton()
        button.setTitle("Close", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
        
        
        //resize alertView
        alertView.frame = CGRect(x: 0, y: 0, width: targetView.frame.size.width-80, height: messageLabel.frame.size.height + titleFrame.height + 50)
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
    
    @objc func dismissAlert() {
        menuState = false
        guard let hintButt = hint else {
            return
        }
        
        hintButt.rotate(rotation: -0.49999, duration: 0.5, option: [])
        UIView.animate(withDuration: 0.5, animations: {
            self.alertView.alpha = 0.0
            hintButt.tintColor = UIColor.systemYellow
            
        }, completion: { done in
            if done {
                self.alertView.removeFromSuperview()
                self.backgroundView.removeFromSuperview()
            }
        })
    }
    
    
}

