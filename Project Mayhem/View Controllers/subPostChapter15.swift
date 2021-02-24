//
//  subPostChapter15.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 2/24/21.
//

import UIKit
import AVKit

class subPostChapter15: UIViewController {
    @IBOutlet var playerView: PlayerView!
    @IBOutlet weak var toolbar: UIStackView!
    @IBOutlet weak var nextChap: UIButton!
    @IBOutlet weak var hint: UIButton!
    @IBOutlet weak var doubleTapInstructions: UILabel!
    
    //subPostChap15ToPostChap15
    
    let pauseArray:[Double] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        game.setValue("subPostChap15", forKey: "active")
        //video = playLocalVideo(name: "Chap1Intro", type: "mov", playView: playerView, array: pauseArray)
        godThread = self
        
        flashInstructions()
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        
    }
    
    func flashInstructions() {
        let alpha = doubleTapInstructions.alpha
        let active = game.string(forKey: "active")
        
        let passed = game.bool(forKey: "chap15")
        if passed {
            if (active == "subPostChap15") {
                if alpha == 0.0 {
                    doubleTapInstructions.fadeIn()
                }
                else {
                    doubleTapInstructions.fadeOut()
                }
            }
            else {
                wait {
                    self.flashInstructions()
                }
            }
        }
         
    }
    
    @objc func doubleTapped() {
        for pauseTime in pauseArray {
            var time = 0.0
            if let player = video?.assetPlayer {
                time = CMTimeGetSeconds(player.currentTime())
            }
            
            if pauseTime > time {
                if pauseTime > time + 3 && video!.isPlaying(){
                    video?.seekToPosition(seconds: pauseTime - 3)
                }
                else {
                    impact(style: .light)
                }
                break
            }
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
        game.setValue("none", forKey: "active")
        performSegue(withIdentifier: "subPostChap15ToHome", sender: self)
    }
    
}
