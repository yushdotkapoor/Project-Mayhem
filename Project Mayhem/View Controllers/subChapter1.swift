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
    
    
    let pauseArray:[Double] = [31.4, 37.85]
    
    var timeStamp:Double = 0.0
    
    var vidName:String = "Chap1Intro"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        game.setValue("subChap1", forKey: "active")
        funcToPass = unlock
        godThread = self
        
        video = VideoPlayer(urlAsset: vidName, view: playerView, arr: pauseArray, startTime: timeStamp, volume: 0.3)
        
        
        flashInstructions()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(background), name: UIApplication.didEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(reenter), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapped))
        singleTap.numberOfTapsRequired = 1
        view.addGestureRecognizer(singleTap)
        
    }
    
    func unlock() {
        let context = LAContext()
        var error: NSError?
        game.setValue("subChap1.05", forKey: "active")
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Unlock Phone shown in video"
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {
                success, authenticationError in
                
                DispatchQueue.main.async {
                    if success {
                        impact(style: .rigid)
                        game.setValue("subChap1.1", forKey: "active")
                        funcToPass = self.nextChapter
                        video?.functionCalled = false
                        video?.play()
                        game.setValue(true, forKey: "chap1IntroWatched")
                    } else {
                        // error
                    }
                }
            }
        } else {
            game.setValue("subChap1.1", forKey: "active")
            video?.play()
        }
        
    }
    
    func nextChapter() {
        DispatchQueue.main.async { [self] in
            video?.cleanUp()
            NotificationCenter.default.removeObserver(godThread!)
            godThread?.performSegue(withIdentifier: "subChap1ToChap1", sender: self)
        }
    }
    
    func flashInstructions() {
        let t = game.bool(forKey: "chap1IntroWatched")
        video?.startFlash(lbl: doubleTapInstructions, chap: ["subChap1", "subChap1.05"], willFlash: t)
    }
    
    @objc func doubleTapped() {
        let t = game.bool(forKey: "chap1IntroWatched")
        video?.viewDidDoubleTap(willPass: t)
    }
    
    @objc func singleTapped() {
        let active = game.string(forKey: "active")
        if active == "subChap1.05" {
            unlock()
        }
    }
    
    @objc func background() {
        timeStamp = video!.currentTime
        stop()
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
