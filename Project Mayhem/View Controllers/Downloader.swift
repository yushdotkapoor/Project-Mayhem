//
//  Downloader.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 6/9/21.
//

import Foundation
import UIKit

class Downloader: UIViewController {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var circleView: CircularProgressBarView!
    
    var notificationTimer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        circleView.createCircularPath(radius: 120)
        
        label.text = "Downloading Content".localized()
        
        notificationTimer = Timer.scheduledTimer(withTimeInterval: 1.1, repeats: true) { timer in
            self.checkNotification()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        notificationTimer?.invalidate()
    }
    
    
    @objc func checkNotification() {
        if label.alpha == 0 {
            label.fadeIn()
        } else {
            label.fadeOut()
        }
        if game.bool(forKey: "downloaded") {
            wait {
                self.performSegue(withIdentifier: "DownloadToMain", sender: nil)
            }
        }
        var dist:Double = Double(mediaCount) / Double(vidArr.count)
        var dur = dist * 0.5
        if dist == 0 {
            dist = 1 / 15
            dur = Double(1 / vidArr.count) * 0.5
        }
        
        circleView.grow(distance: dist, duration: dur)
    }
    
    
}
