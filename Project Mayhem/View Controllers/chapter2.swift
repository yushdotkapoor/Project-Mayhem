//
//  chapter2.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 12/24/20.
//

import UIKit
import MediaPlayer
import AVFoundation

class chapter2: UIViewController {
    @IBOutlet weak var nextChap: UIButton!
    
    @IBOutlet weak var begin: UIStackView!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var volumeView: UIView!
    
    private var audioLevel : Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let active = game.string(forKey: "active")
        
        switch active! {
        case "chap2":
            part1()
            break
        default:
            break
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listenVolumeButton()
        viewHeight.constant = view.frame.size.height * CGFloat(audioLevel)
        
        let active = game.string(forKey: "active")
        
        switch active! {
        case "none":
            game.setValue("chap2", forKey: "active")
            begin.alpha = 0.0
            break
        default:
            game.setValue("none", forKey: "active")
            viewWillAppear(true)
            break
        }
        volumeView.alpha = 0.5
        nextChap.alpha = 0.0
        nextChap.isUserInteractionEnabled = false
        
    }
    
    func part1() {
        begin.fadeIn()
        game.setValue("chap2.1", forKey: "active")
    }
   
    
    @IBAction func goBack(_ sender: Any) {
        AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: "outputVolume")
    self.performSegue(withIdentifier: "chap2ToHome", sender: nil)
    }
    
    @IBAction func goNext(_ sender: Any) {
        AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: "outputVolume")
    self.performSegue(withIdentifier: "chap2ToChap3", sender: nil)
    }
    
    func listenVolumeButton() {
         let audioSession = AVAudioSession.sharedInstance()
         do {
              try audioSession.setActive(true, options: [])
         audioSession.addObserver(self, forKeyPath: "outputVolume",
                                  options: NSKeyValueObservingOptions.new, context: nil)
              audioLevel = audioSession.outputVolume
         } catch {
              print("Error")
         }
    }
   
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
         if keyPath == "outputVolume"{
              let audioSession = AVAudioSession.sharedInstance()
            
              audioLevel = audioSession.outputVolume
              
            viewHeight.constant = view.frame.size.height * CGFloat(audioLevel)
            if audioLevel == 0.0 {
                complete()
            }
         }
    }
    
    func complete() {
        game.setValue("none", forKey: "active")
        game.setValue(true, forKey: "chap2")
        nextChap.isUserInteractionEnabled = true
        nextChap.fadeIn()
        
    }
    
}

