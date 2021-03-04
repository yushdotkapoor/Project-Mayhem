//
//  UIViewControllerExtensions.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 1/29/21.
//

import UIKit
import AVKit

extension UIViewController {
    
    func alert(title: String, message: String, actionTitle: String) {
        
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: actionTitle, style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
    }

    func alert(title: String, message: String, actionTitle: String, actions: @escaping () -> Void) {
        
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: actionTitle, style: .cancel, handler: { action in actions()})
        
        alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
    }
    
    func vibrate(count: Int) {
        if count != 0 {
            impact(style: .medium)
            wait(time: 0.1, actions: {
                self.vibrate(count: count - 1)
            })
        }
    }
    
    func vidToURL(name: String, type: String) -> NSURL {
        if let filePath = Bundle.main.path(forResource: name, ofType: type) {
            let fileURL = NSURL(fileURLWithPath: filePath)
            return fileURL
        }
        return NSURL()
    }
    
    
}
