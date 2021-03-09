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
    @IBOutlet weak var hint: UIButton!
    @IBOutlet weak var toolbar: UIStackView!
    
    let customAlert = HintAlert()
    
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
        if isOnPhoneCall() {
            let alertController = UIAlertController(title: "Error", message: "Functionality of the application will not work if you are in a call, please disconnect the call to continue playing", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else {
        begin.fadeIn()
        game.setValue("chap2.1", forKey: "active")
        }
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
        audioSession.addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.new, context: nil)
        audioLevel = audioSession.outputVolume
    }
   
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
         if keyPath == "outputVolume"{
              let audioSession = AVAudioSession.sharedInstance()
            
              audioLevel = audioSession.outputVolume
              
            viewHeight.constant = view.frame.size.height * CGFloat(audioLevel)
            if audioLevel == 1.0 {
                let name = game.string(forKey: "name")
                alert.showAlert(title: "Message from Defender Command", message: "\(name!), I have an assignment for you. I know you’ve heard of Vision Consolidated’s new Intelligence Enhancement and Cognitive Treatment (INTELLECT). Internal sources say that the development of the service has been very shady. In fact, they called it ‘Project Mayhem’. Sounds pretty sinister to me. We need you to investigate the company and see if there is anything to worry about. This could be your biggest case as a Defender, if Vision Consolidated is not what we think it is. You’ve been given employee access to their facilities, but make sure to stay under the radar. Good luck, Brainchild.", viewController: self, buttonPush: #selector(dismissMessageAlert))
                view.bringSubviewToFront(toolbar)
            }
         }
    }
    
    func complete() {
        game.setValue("none", forKey: "active")
        game.setValue(true, forKey: "chap2")
        nextChap.isUserInteractionEnabled = true
        nextChap.fadeIn()
    }

    // defines alert
    let alert = MessageAlert()

    //function that gets called to dismiss the alertView
    @objc func dismissMessageAlert() {
        alert.dismissAlert()
        complete()
    }
    
    @IBAction func hint(_ sender: Any) {
        if menuState {
            //if menu open and want to close
            dismissAlert()
        }
        else {
            menuState = true
            //if menu closed and want to open
            hint.rotate(rotation: 0.49999, duration: 0.5, option: [])
            UIView.animate(withDuration: 0.5) {
                self.hint.tintColor = UIColor.lightGray
            }
            customAlert.showAlert(message: "How could you make sure that you can hear everything?", viewController: self, hintButton: hint)
            view.bringSubviewToFront(toolbar)
        }
        
    }
    
    func dismissAlert() {
        customAlert.dismissAlert()
    }
    
    
    
}

