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
    var topViewController: UIViewController? {
        return self.topViewController(currentViewController: self)
    }
    
    private func topViewController(currentViewController: UIViewController) -> UIViewController {
        if let tabBarController = currentViewController as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return self.topViewController(currentViewController: selectedViewController)
        } else if let navigationController = currentViewController as? UINavigationController,
                  let visibleViewController = navigationController.visibleViewController {
            return self.topViewController(currentViewController: visibleViewController)
        } else if let presentedViewController = currentViewController.presentedViewController {
            return self.topViewController(currentViewController: presentedViewController)
        } else {
            return currentViewController
        }
    }
    
}
