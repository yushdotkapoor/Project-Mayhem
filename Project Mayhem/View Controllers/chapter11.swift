//
//  chapter11.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 02/02/21.
//

import UIKit
import Speech

class chapter11: UIViewController, SFSpeechRecognizerDelegate {
    @IBOutlet weak var nextChap: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var rippleCircle: UIImageView!
    @IBOutlet weak var morseText: UILabel!
    @IBOutlet weak var binaryText: UILabel!
    @IBOutlet weak var pigpenCipherText: UILabel!
    @IBOutlet weak var hint: UIButton!
    @IBOutlet weak var toolbar: UIStackView!
    
    let customAlert = HintAlert()
    
    var resetInProgress = false
    var currentString = ""
    
    override func viewDidLoad() {
           super.viewDidLoad()
        resetInProgress = false
        currentString = ""
        label.alpha = 0.0
        binaryText.text = binaryText.text?.stringToBinary()
        morseText.text = morseText.text?.stringToMorse()
        game.setValue("chap11", forKey: "active")
        godThread = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nextChap.alpha = 0.0
        nextChap.isUserInteractionEnabled = false
    }
    
    func complete() {
        game.setValue(true, forKey: "chap11")
        game.setValue("none", forKey: "active")
        nextChap.isUserInteractionEnabled = true
        nextChap.fadeIn()
    }

    @IBAction func goBack(_ sender: Any) {
        talk?.stopRecording()
        game.setValue("none", forKey: "active")
        self.performSegue(withIdentifier: "chap11ToHome", sender: nil)
    }
    
    @IBAction func goNext(_ sender: Any) {
        self.performSegue(withIdentifier: "chap11ToChap12", sender: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        alert.showAlert(title: "Message from Victoria Lambson", message: "I don’t remember there being a CEO before Yush, and there is also no historical record of this \"boss\" ever existing", viewController: self, buttonPush: #selector(dismissMessageAlert))
        view.bringSubviewToFront(toolbar)
    }
    
    // defines alert
    let alert = MessageAlert()
    
    //function that gets called to dismiss the alertView
    @objc func dismissMessageAlert() {
        alert.dismissAlert()
        talk = speechModule(activeCode: game.string(forKey: "active")!, rippleView: rippleCircle)
        funcToPass = didComeBack
        talk?.startRecording(target: ["william shakespeare"])
    }
    
    func didComeBack() {
        talk?.stopRecording()
        self.label.text = "William Shakespeare"
        self.pigpenCipherText.fadeOut()
        self.morseText.fadeOut()
        self.binaryText.fadeOut()
        self.label.fadeIn()
        talk?.stopRecording()
        game.setValue("none", forKey: "active")
        wait {
            self.complete()
        }
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
            customAlert.showAlert(message: "All the world’s a stage, and all the men and women merely players. They have their exits and their entrances; And one man in his time plays many parts.\n\nThis sure does sound like iambic pentameter! I wonder who LOVED iambic pentameter?", viewController: self, hintButton: hint)
            view.bringSubviewToFront(toolbar)
        }
        
    }
    
    func dismissAlert() {
        customAlert.dismissAlert()
    }
    
    
    
    
}
