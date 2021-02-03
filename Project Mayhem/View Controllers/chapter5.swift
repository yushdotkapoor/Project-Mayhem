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
    
    let microphone = Listen()
    var progressVal:Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        microphone.start()
        Hz.text = ""
        progressVal = 0
        
        recurse()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(background), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(reenter), name: UIApplication.didBecomeActiveNotification, object: nil)
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
        else {
            self.progressVal = 0
            self.changeProgress()
        }
    }
    
    func changeProgress() {
        progress.setProgress(progressVal/50, animated: true)
        if progressVal < 50 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.recurse()
            }
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
        self.performSegue(withIdentifier: "chap5ToHome", sender: nil)
    }
    
    @IBAction func goNext(_ sender: Any) {
        self.performSegue(withIdentifier: "chap5ToChap6", sender: nil)
    }


}
