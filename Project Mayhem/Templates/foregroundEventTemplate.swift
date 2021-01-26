//
//  foregroundEventTemplate.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 12/24/20.
//

import UIKit

class foregroundEventTemplate: UIViewController {
    
    override func viewDidLoad() {
           super.viewDidLoad()
        let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self, selector: #selector(foreground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func foreground() {
        //runs when app comes back into foreground
    }
    
}
