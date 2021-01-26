//
//  keyboardTemplate.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 12/24/20.
//

import Foundation


import UIKit

class keyboardTemplate: UIViewController {
    
    override func viewDidLoad() {
           super.viewDidLoad()
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneClicked))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
       // nameField.inputAccessoryView = toolBar
        
    }
    
    @objc func doneClicked() {
        view.endEditing(true)
    }
    
}
