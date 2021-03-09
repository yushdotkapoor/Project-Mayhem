//
//  chapter5.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 01/37/21.
//

import UIKit
import AudioKit

class chapter5: UIViewController {
    @IBOutlet weak var nextChap: UIButton!
    @IBOutlet weak var Hz: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var A: UILabel!
    @IBOutlet weak var hint: UIButton!
    @IBOutlet weak var toolbar: UIStackView!
    
    let customAlert = HintAlert()
    
    let microphone = Listen()
    var progressVal:Float = 0.0
    var eggVal:Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isOnPhoneCall() {
            let alertController = UIAlertController(title: "Error", message: "Functionality of the application will not work if you are in a call, please disconnect the call to continue playing", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else {
        microphone.start()
        Hz.text = ""
        progressVal = 0
        
        recurse()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(background), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(reenter), name: UIApplication.didBecomeActiveNotification, object: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nextChap.alpha = 0.0
        nextChap.isUserInteractionEnabled = false
    }
    
    func complete() {
        NotificationCenter.default.removeObserver(self)
        game.setValue(true, forKey: "chap5")
        game.setValue("none", forKey: "active")
        nextChap.isUserInteractionEnabled = true
        nextChap.fadeIn()
    }
   
    func recurse() {
        let pitch = Int(microphone.fq)
        self.Hz.text = "\(pitch)"
        if (pitch > 7035 && pitch < 7045) || (pitch > 3515 && pitch < 3525) || (pitch > 1765 && pitch < 1775) || (pitch > 875 && pitch < 885) || (pitch > 435 && pitch < 445) || (pitch > 215 && pitch < 225) || (pitch > 105 && pitch < 115) || (pitch > 50 && pitch < 60) {
            self.progressVal += 1
            self.changeProgress()
        }
        else if pitch >= 6968 && pitch <= 6970 {
            self.eggVal += 1
            self.eggProgress()
        }
        else {
            self.progressVal = 0
            self.eggVal = 0
            self.changeProgress()
        }
        
    }
    
    func eggProgress() {
        if eggVal > 20 {
            alert(title: "Nice!", message: "You've found an easter egg! It's totally useless, just like me!", actionTitle: "Yay!",actions: {
                self.recurse()
            })
        }
        else {
            wait(time: 0.1, actions: {
                self.recurse()
            })
        }
    }
    
    func changeProgress() {
        progress.setProgress(progressVal/50, animated: true)
        if progressVal < 50 {
            wait(time: 0.1, actions: {
                self.recurse()
            })
        }
        else {
            let blue = UIColor.systemBlue
            progress.progressTintColor = blue
            Hz.textColor = blue
            A.textColor = blue
            background()
            complete()
        }
    }
    
    @objc func background() {
        microphone.stop()
    }
        
    @objc func reenter() {
        microphone.start()
    }
    
    @IBAction func goBack(_ sender: Any) {
        background()
        NotificationCenter.default.removeObserver(self)
        self.performSegue(withIdentifier: "chap5ToHome", sender: nil)
    }
    
    @IBAction func goNext(_ sender: Any) {
        self.performSegue(withIdentifier: "chap5ToChap6", sender: nil)
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
                self.hint.tintColor = UIColor.darkGray
            }
            customAlert.showAlert(message: "do re mi fa so laaaaaaaaaaaaaaaaaaaaaaaaaaaaa\n\nNice!", viewController: self, hintButton: hint)
            view.bringSubviewToFront(toolbar)
        }
        
    }
    
    func dismissAlert() {
        customAlert.dismissAlert()
    }


}
