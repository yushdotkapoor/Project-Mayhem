//
//  ProjectVenomTrailer.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 2/24/21.
//

import UIKit
import AVKit

class ProjectVenomTrailer: UIViewController {
    @IBOutlet var playerView: PlayerView!
    @IBOutlet weak var toolbar: UIStackView!
    @IBOutlet weak var nextChap: UIButton!
    @IBOutlet weak var hint: UIButton!
    @IBOutlet weak var doubleTapInstructions: UILabel!
    
    let pauseArray:[Double] = [45.4]
    
    var player:AVPlayer!
    
    var timeStamp:Double = 0.0
    
    var vidName:String = "ProjectVenomTrailer"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doubleTapInstructions.text = "Double Tap to Skip".localized()
        
        game.setValue("projectVenomTrailer", forKey: "active")
        funcToPass = self.ended
        godThread = self
        video = VideoPlayer(urlAsset: vidName, view: playerView, arr: pauseArray, startTime: timeStamp, volume: 0.15)
        
        
        flashInstructions()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(background), name: UIApplication.didEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(reenter), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        view.bringSubviewToFront(toolbar)
        
        toolbar.add3DMotionShadow()
    }
    
    
    func ended() {
        video?.cleanUp()
        NotificationCenter.default.removeObserver(godThread!)
        game.setValue(true, forKey: "ProjectVenomTrailerWatched")
        game.setValue("none", forKey: "active")
        godThread?.performSegue(withIdentifier: "venomToPreview", sender: nil)
    }
    
    func flashInstructions() {
        let t = game.bool(forKey: "ProjectVenomTrailerWatched")
        video?.startFlash(lbl: doubleTapInstructions, chap: ["projectVenomTrailer"], willFlash: t)
    }
    
    @objc func doubleTapped() {
        let t = game.bool(forKey: "ProjectVenomTrailerWatched")
        video?.viewDidDoubleTap(willPass: t)
    }
    
    @objc func background() {
        timeStamp = video!.currentTime
        video?.cleanUp()
    }
    
    @objc func reenter() {
        game.setValue("projectVenomTrailer", forKey: "active")
        if timeStamp - 2 < 0 {
            timeStamp = 2
        }
        video = VideoPlayer(urlAsset: vidName, view: playerView, arr: pauseArray, startTime: timeStamp - 2, volume: 0.15)
        godThread = self
        flashInstructions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nextChap.alpha = 0.0
        nextChap.isUserInteractionEnabled = false
        hint.alpha = 0.0
        hint.isUserInteractionEnabled = false
        doubleTapInstructions.alpha = 0.0
    }
    
    func stop() {
        video?.cleanUp()
        godThread = nil
        game.setValue("none", forKey: "active")
    }
    
    @IBAction func back(_ sender: Any) {
        stop()
        NotificationCenter.default.removeObserver(self)
        performSegue(withIdentifier: "ProjectVenomToHome", sender: self)
    }
    
}
