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
        guard let targetView = viewController.view else {
            return
        }
        
        hint = hintButton
        
        backgroundView.frame = targetView.bounds
        targetView.addSubview(backgroundView)
        
        targetView.addSubview(alertView)
        
        alertView.isUserInteractionEnabled = true
        alertView.frame = CGRect(x: 0, y: 0, width: targetView.frame.size.width-80, height: 280)
        alertView.center = targetView.center
        let gradient = CAGradientLayer()
        gradient.frame = alertView.bounds
        gradient.colors = [UIColor(named: "MayhemBlue")!.cgColor, UIColor(named: "MayhemGray")!.cgColor]
        alertView.layer.addSublayer(gradient)
        alertView.isHidden = true
        alertView.alpha = 0.0
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: alertView.frame.size.width, height: 50))
        titleLabel.text = "Hint"
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        alertView.addSubview(titleLabel)
        
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 50, width: alertView.frame.size.width, height: 170))
        messageLabel.numberOfLines = 0
        messageLabel.text = message
        messageLabel.textAlignment = .center
        messageLabel.textColor = .white
        alertView.addSubview(messageLabel)
        
        let button = CustomButtonOutline()
        button.frame = CGRect(x: alertView.frame.size.width / 2 - 37.5, y: alertView.frame.size.height - 36.5, width: 75, height: 25)
        button.setupButton()
        button.setTitle("Close", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
        alertView.addSubview(button)
        
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

