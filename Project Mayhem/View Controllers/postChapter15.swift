//
//  postChapter15.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 2/23/21.
//

import UIKit
import AVKit

class postChapter15: UIViewController {
    @IBOutlet weak var nextChap: UIButton!
    @IBOutlet weak var hint: UIButton!
    @IBOutlet weak var toolbar: UIStackView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var stack: UIStackView!
    @IBOutlet weak var stackToBottom: NSLayoutConstraint!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var wellDone: UILabel!
    @IBOutlet weak var thanks: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var sysReset: UILabel!
    @IBOutlet weak var Q: UILabel!
    @IBOutlet weak var blckView: UIView!
    
    var customAlert = HintAlert()
    
    let buzzTypes:[UIImpactFeedbackGenerator.FeedbackStyle] = [.heavy, .light, .medium, .soft, .rigid]
    
    var keyboardAdded: CGFloat = 0.0
    var open = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneClicked))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        textField.inputAccessoryView = toolBar
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(gesture:)))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        game.setValue("postChap15", forKey: "active")
        flickerStart()
    }
    
    func flickerStart() {
        let active = game.string(forKey: "active")
        if active == "postChap15" {
            mainLabel.flickerIn(iterations: 30)
            wait(time: 3) {
                self.flickerStart()
            }
        }
    }
    
    @objc func doneClicked() {
        view.endEditing(true)
    }
    
    @objc func viewTapped(gesture: UIGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if open {
            return
        }
        let bounds = UIScreen.main.bounds
        let deviceHeight = bounds.size.height
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            let labelHeight = deviceHeight - stack.frame.origin.y
            let add = keyboardHeight - labelHeight
            keyboardAdded = add
            stackToBottom.constant -= add
            open = true
        }
    }
    
    @objc func keyboardWillHide() {
        stackToBottom.constant += keyboardAdded
        open = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nextChap.alpha = 0.0
        nextChap.isUserInteractionEnabled = false
        wellDone.alpha = 0.0
        thanks.alpha = 0.0
        sysReset.alpha = 0.0
        Q.alpha = 0.0
    }
    
    
    func complete() {
        game.setValue(true, forKey: "postChap15")
        game.setValue("none", forKey: "active")
        NotificationCenter.default.removeObserver(self)
        nextChap.isUserInteractionEnabled = true
        nextChap.fadeIn()
    }
    
    @IBAction func submit(_ sender: Any) {
        let text = textField.text
        
        if text == "" {
            return
        }
        
        if text?.lowercased() == "statue of liberty" {
            game.setValue("postChap15.1", forKey: "active")
            view.endEditing(true)
            backButton.isUserInteractionEnabled = false
            backButton.tintColor = .red
            UIView.animate(withDuration: 1, animations: {
                self.mainLabel.textColor = .red
            }, completion: {_ in
                self.randomBuzz()
                self.pulsate()
                self.wellDone.flickerIn()
                wait {
                    self.thanks.flickerIn()
                    self.Q.flickerIn()
                    wait {
                        self.mainLabel.text = "Have fun living with what you just did ;)"
                        self.mainLabel.textColor = .systemBlue
                        self.mainLabel.textAlignment = .center
                        wait(time: 3, actions: {
                            self.sysReset.fadeIn()
                            self.sysReset.text = "System Reset in 3"
                            wait {
                                self.sysReset.text = "System Reset in 2"
                                wait {
                                    self.sysReset.text = "System Reset in 1"
                                    wait {
                                        self.sysReset.text = "System Reset in 0"
                                        wait {
                                            self.sysReset.text = "Happy death day"
                                            wait(time: 2, actions: {
                                                game.setValue("none", forKey: "active")
                                                game.setValue(true, forKey: "apocalypse")
                                                game.setValue(true, forKey: "chap15")
                                                self.view.bringSubviewToFront(self.blckView)
                                                MusicPlayer.shared.playGlitch()
                                                
                                                wait(time:4, actions: {
                                                    MusicPlayer.shared.startBackgroundMusic()
                                                    self.performSegue(withIdentifier: "postChap15ToMain", sender: nil)
                                                })
                                            })
                                        }
                                    }
                                }
                            }
                        })
                    }
                }
            })
        }
        else {
            textField.shake()
            textField.text = ""
            impact(style: .light)
        }
    }
    
    func randomBuzz() {
        let active = game.string(forKey: "active")
        let sensitive = game.bool(forKey: "photosensitive")
        if active == "postChap15.1" {
            let randType = Int.random(in: 0...4)
            let randDuration = Float.random(in: 0...0.4)
            let randDuration2 = Float.random(in: 0...0.4)
            
            impact(style: buzzTypes[randType])
            
            if !sensitive {
                wait(time: randDuration2) {
                    self.view.backgroundColor = .white
                    wait(time: 0.1) {
                        self.view.backgroundColor = UIColor.systemIndigo
                    }
                }
            }
            
            wait(time: randDuration) {
                self.randomBuzz()
            }
        }
    }
    
    func pulsate() {
        let active = game.string(forKey: "active")
        if active == "postChap15.1" {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            wait {
                self.pulsate()
            }
        }
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        game.setValue("none", forKey: "active")
        NotificationCenter.default.removeObserver(self)
        self.performSegue(withIdentifier: "postChap15ToHome", sender: nil)
    }
    
    @IBAction func goNext(_ sender: Any) {
        // self.performSegue(withIdentifier: "chap1ToChap2", sender: nil)
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
            customAlert = HintAlert()
            customAlert.showAlert(message: "15.2", viewController: self, hintButton: hint, toolbar: toolbar)
        }
        
    }
    
    func dismissAlert() {
        customAlert.dismissAlert()
    }
    
    
}
