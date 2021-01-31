//
//  UIViewControllerExtensions.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 1/29/21.
//

import UIKit


extension UIViewController {

    func alert(title: String, message: String, actionTitle: String) {
        
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: actionTitle, style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
    }
    
    func alert(title: String, message: String, actionTitle: String, actions: @escaping () -> Void) {
        
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: actionTitle, style: .cancel, handler: { action in actions()})
        
        alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
    }
    
    
}
