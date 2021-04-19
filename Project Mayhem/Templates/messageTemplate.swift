//
//  messageTemplate.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 2/16/21.
//

import UIKit

class messageTemplate: UIViewController {
    
    //DO NOT COPY
    let toolbar:UIButton = UIButton()
    
    
    func REMOVEME() {
        
        alert.showAlert(title: "", message: "", viewController: self, buttonPush: #selector(dismissMessageAlert))
        
    }
    
    // defines alert
    let alert = MessageAlert()
    
    //function that gets called to dismiss the alertView
    @objc func dismissMessageAlert() {
        alert.dismissAlert()
        //add code if needed
    }
    
}
