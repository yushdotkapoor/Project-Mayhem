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
    
    @IBOutlet weak var progress: UILabel!
    @IBOutlet weak var centerStack: UIStackView!
    
    var notificationTimer:Timer?
    var noPacketsTimer:Timer?
    var networkAlert = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        game.setValue(0.0, forKey: "Chap1IntroDownloadProgress")
        progress.text = "0.00%"
        
        circleView.createCircularPath(radius: 120)
        
        label.text = "Downloading Content".localized()
        minutes.text = "This may take a few minutes".localized()
        
        noPacketsTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: false) { timer in
            self.checkNoIncomingPackets()
        }
        
        notificationTimer = Timer.scheduledTimer(withTimeInterval: 1.1, repeats: true) { timer in
            self.checkNotification()
        }
        let xFactor = validateVideos()
        if !xFactor.contains("Chap1Intro") {
            game.setValue(1.0, forKey: "Chap1IntroDownloadProgress")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        notificationTimer?.invalidate()
        noPacketsTimer?.invalidate()
    }
    
    func checkForInternet() {
        if !CheckInternet.Connection() {
            networkAlert = true
            alert(title: "Error".localized(), message: "It seems that you do not have stable network connection for downloading this game's content. To proceed, please connect to an internet network.".localized(), actionTitle: "Okay".localized())
        }
    }
    
    @objc func checkNoIncomingPackets() {
        let prog = game.double(forKey: "Chap1IntroDownloadProgress")
        if prog == 0.0 && CheckInternet.Connection() {
            alert(title: "Error".localized(), message: "It seems that you have a poor internet connection. Try reseting your connection or change your connection to a faster one.".localized(), actionTitle: "Okay".localized())
        }
        
    }
    
    
    @objc func checkNotification() {
        let prog = game.double(forKey: "Chap1IntroDownloadProgress")
        if !networkAlert && prog != 1.0 {
            checkForInternet()
        }
        if centerStack.alpha == 0 {
            centerStack.fadeIn()
        } else {
            centerStack.fadeOut()
        }
        
        if prog == 1.0 {
            game.setValue(true, forKey: "introViewed")
            wait {
                let v = validateVideos()
                downloadVideos(vidNames: v)
                self.performSegue(withIdentifier: "DownloadToMain", sender: nil)
            }
        }
        
        
        let dist:Double = prog
        let dur = 0.5
        
        
        progress.text = "\(String(format: "%.2f", (dist*100)))%"
        
        circleView.grow(distance: dist, duration: dur)
        
    }
    
    
}
