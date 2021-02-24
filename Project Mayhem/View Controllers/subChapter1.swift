//
//  subChapter1.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 2/17/21.
//

import UIKit
import AVKit
import LocalAuthentication

var video:VideoPlayer?
var godThread:UIViewController?

class subChapter1: UIViewController {
    @IBOutlet var playerView: PlayerView!
    @IBOutlet weak var toolbar: UIStackView!
    @IBOutlet weak var nextChap: UIButton!
    @IBOutlet weak var hint: UIButton!
    @IBOutlet weak var doubleTapInstructions: UILabel!
    
    var stopFlash = false
    
    let pauseArray:[Double] = [31.4, 37.85]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        game.setValue("subChap1", forKey: "active")
        video = playLocalVideo(name: "Chap1Intro", type: "mov", playView: playerView, array: pauseArray)
        godThread = self
        
        flashInstructions()
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapped))
        singleTap.numberOfTapsRequired = 1
        view.addGestureRecognizer(singleTap)
        
    }
    
    func flashInstructions() {
        let alpha = doubleTapInstructions.alpha
        let active = game.string(forKey: "active")
        let passed = game.bool(forKey: "chap1")
        if passed && !stopFlash {
            if (active == "subChap1" || active == "subChap1.05") {
                if alpha == 0.0 {
                    doubleTapInstructions.fadeIn()
                }
                else {
                    doubleTapInstructions.fadeOut()
                }
            }
            else {
                doubleTapInstructions.alpha = 0.0
            }
            wait {
                self.flashInstructions()
            }
        }
    }
    
    func unlock() {
        let context = LAContext()
        var error: NSError?
        print(self)
        game.setValue("subChap1.05", forKey: "active")
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Unlock Phone shown in video"
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {
                success, authenticationError in
                
                DispatchQueue.main.async {
                    if success {
                        self.impact(style: .rigid)
                        game.setValue("subChap1.1", forKey: "active")
                        video?.play()
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
            stopFlash = true
            godThread?.performSegue(withIdentifier: "subChap1ToChap1", sender: self)
        }
    }
    
    @objc func doubleTapped() {
        for pauseTime in pauseArray {
            var time = 0.0
            if let player = video?.assetPlayer {
                time = CMTimeGetSeconds(player.currentTime())
            }
            
            if pauseTime > time {
                if pauseTime > time + 2 && video!.isPlaying(){
                    video?.seekToPosition(seconds: pauseTime - 2)
                }
                else {
                    impact(style: .light)
                }
                break
            }
        }
    }
    
    @objc func singleTapped() {
        let active = game.string(forKey: "active")
        if active == "subChap1.05" {
            unlock()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nextChap.alpha = 0.0
        nextChap.isUserInteractionEnabled = false
        hint.alpha = 0.0
        hint.isUserInteractionEnabled = false
    }
    
    @IBAction func back(_ sender: Any) {
        video?.cleanUp()
        godThread = nil
        stopFlash = true
        game.setValue("none", forKey: "active")
        performSegue(withIdentifier: "subChap1ToHome", sender: self)
    }
    
    
    
    
}
