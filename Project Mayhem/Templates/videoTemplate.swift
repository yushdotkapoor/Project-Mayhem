//
//  videoTemplate.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 2/24/21.
//

import Foundation
import UIKit
import AVKit

class videoTemplate: UIViewController {
    @IBOutlet var playerView: PlayerView!
    @IBOutlet weak var toolbar: UIStackView!
    @IBOutlet weak var nextChap: UIButton!
    @IBOutlet weak var hint: UIButton!
    @IBOutlet weak var doubleTapInstructions: UILabel!
    
    let pauseArray:[Double] = []
    
    var timeStamp:Double = 0.0
    
    //var vidName:String = "ProjectVenomTrailer"
    
    //NOTE: When exiting the viewController, the following must be called
    //NotificationCenter.default.removeObserver(godThread!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //game.setValue("subChap1", forKey: "active")
        godThread = self
        //video = playLocalVideo(name: "Chap1Intro", type: "mov", playView: playerView, array: pauseArray, startAt: Timestamp)
        
        flashInstructions()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(background), name: UIApplication.didEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(reenter), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        
    }
    
    func flashInstructions() {
        //chap1 is the next main level
       //let t = game.bool(forKey: "chap1")
        //chap represents all the active states that need flash instructions
       //video?.startFlash(lbl: doubleTapInstructions, chap: ["subChap1", "subChap1.05"], willFlash: t)
    }
    
    @objc func doubleTapped() {
         //chap1 is the next main level
        //let t = game.bool(forKey: "chap1")
        //video?.viewDidDoubleTap(willPass: t)
    }
    
    @objc func background() {
        timeStamp = video!.currentTime
        stop()
    }
    
    @objc func reenter() {
        if timeStamp - 2 < 0 {
            timeStamp = 2
        }
       // video = playLocalVideo(name: vidName, type: "mov", playView: playerView, array: pauseArray, startAt: timeStamp - 2)
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
        //performSegue(withIdentifier: "subChap1ToHome", sender: self)
    }
    
    
}
