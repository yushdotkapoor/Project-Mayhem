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
    @IBOutlet weak var minutes: UILabel!
    var networkAlert = false
    
    var notificationTimer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        circleView.createCircularPath(radius: 120)
        
        label.text = "Downloading Content".localized()
        minutes.text = "This may take a few minutes".localized()
        
        notificationTimer = Timer.scheduledTimer(withTimeInterval: 1.1, repeats: true) { timer in
            self.checkNotification()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        notificationTimer?.invalidate()
    }
    
    func checkForInternet() {
        if !CheckInternet.Connection() {
            networkAlert = true
            alert(title: "Error".localized(), message: "It seems that you do not have stable network connection for downloading this game's content. To proceed, please connect to an internet network.".localized(), actionTitle: "Okay".localized())
        }
    }
    
    
    @objc func checkNotification() {
        if !networkAlert && !game.bool(forKey: "downloaded") {
            checkForInternet()
        }
        if label.alpha == 0 {
            label.fadeIn()
        } else {
            label.fadeOut()
        }
        if game.bool(forKey: "downloaded") {
            game.setValue(true, forKey: "introViewed")
            wait {
                let v = validateVideos()
                downloadVideos(vidNames: v)
                self.performSegue(withIdentifier: "DownloadToMain", sender: nil)
            }
        }
        
        
        //var dist:Double = Double(mediaCount) / Double(vidArr.count)
        var dist:Double = Double(mediaCount)
        var dur = dist * 0.5
        if dist == 0 {
            dist = 1 / 15
            //dur = Double(1 / vidArr.count) * 0.5
            dur = 0.5
        }
        
        circleView.grow(distance: dist, duration: dur)
    }
    
    
}
