//
//  subChapter1.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 2/17/21.
//

import UIKit
import AVKit
import LocalAuthentication

class subChapter1: UIViewController {
    @IBOutlet var playerView: PlayerView!
    @IBOutlet weak var toolbar: UIStackView!
    @IBOutlet weak var nextChap: UIButton!
    @IBOutlet weak var hint: UIButton!
    @IBOutlet weak var doubleTapInstructions: UILabel!
    
    let pauseArray:[Double] = [37.85]
    var timeStamp:Double = 0.0
    
    var vidName:String = "Chap1Intro"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
                    if let error = error {
                        print("Request Authorization Failed (\(error), \(error.localizedDescription))")
                    }
                    else{
                        print("User accepted notifications")
                    }
                }
        
        toolbar.add3DMotionShadow()
        
        doubleTapInstructions.text = "Double Tap to Skip".localized()
        
        
        let b = game.string(forKey: "active")
        if b != "chap1.1"{
            game.setValue("subChap1", forKey: "active")
            funcToPass = self.nextChapter
            godThread = self
            
            video = VideoPlayer(urlAsset: vidName, view: playerView, arr: pauseArray, startTime: timeStamp, volume: 0.3)
            
            flashInstructions()
            
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self, selector: #selector(background), name: UIApplication.didEnterBackgroundNotification, object: nil)
            notificationCenter.addObserver(self, selector: #selector(reenter), name: UIApplication.willEnterForegroundNotification, object: nil)
            
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
            doubleTap.numberOfTapsRequired = 2
            view.addGestureRecognizer(doubleTap)
        }
        else {
            game.setValue("chap1.1", forKey: "active")
            wait {
                self.performSegue(withIdentifier: "subChap1ToChap1", sender: nil)
            }
        }
        
    }
    
    func nextChapter() {
        DispatchQueue.main.async { [self] in
            game.setValue(true, forKey: "chap1IntroWatched")
            video?.cleanUp()
            NotificationCenter.default.removeObserver(godThread!)
            godThread?.performSegue(withIdentifier: "subChap1ToChap1", sender: self)
        }
    }
    
    func flashInstructions() {
        let t = game.bool(forKey: "chap1IntroWatched")
        video?.startFlash(lbl: doubleTapInstructions, chap: ["subChap1"], willFlash: t)
    }
    
    @objc func doubleTapped() {
        let t = game.bool(forKey: "chap1IntroWatched")
        video?.viewDidDoubleTap(willPass: t)
    }
    
    @objc func background() {
        timeStamp = video!.currentTime
        video?.cleanUp()
    }
    
    @objc func reenter() {
        if timeStamp - 2 < 0 {
            timeStamp = 2
        }
        video = VideoPlayer(urlAsset: vidName, view: playerView, arr: pauseArray, startTime: timeStamp - 2, volume: 0.3)
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
        performSegue(withIdentifier: "subChap1ToHome", sender: self)
    }
    
    
    
    
}
