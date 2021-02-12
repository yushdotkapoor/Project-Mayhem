//
//  keyboardTemplate.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 12/24/20.
//

import Foundation


import UIKit

class keyboardTemplate: UIViewController {
    
    var keyboardAdded: CGFloat = 0.0
    var open = false
    
    override func viewDidLoad() {
           super.viewDidLoad()
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneClicked))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
       // nameField.inputAccessoryView = toolBar
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(gesture:)))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func doneClicked() {
        view.endEditing(true)
    }
    
    @objc func viewTapped(gesture: UIGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if open {
            return
        }
        let bounds = UIScreen.main.bounds
        let deviceHeight = bounds.size.height
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                let keyboardHeight = keyboardSize.height
            let labelHeight = deviceHeight //- LABELORSTACK.frame.origin.y
            let add = keyboardHeight - labelHeight + 70
            keyboardAdded = add
           // CONSTRAINT.constant -= add
            open = true
            }
    }
    
    @objc func keyboardWillHide() {
        //CONSTRAINT.constant += keyboardAdded
        open = false
    }
    
}
