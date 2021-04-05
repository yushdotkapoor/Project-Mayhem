//
//  chapter14.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 02/02/21.
//

import UIKit

class chapter14: UIViewController {
    @IBOutlet weak var nextChap: UIButton!
    @IBOutlet weak var hint: UIButton!
    @IBOutlet weak var toolbar: UIStackView!
    @IBOutlet weak var bypassImg: UIImageView!
    @IBOutlet weak var foregroundView: UIView!
    @IBOutlet weak var tap: CustomButtonOutline!
    @IBOutlet weak var morseLabel: UILabel!
    @IBOutlet weak var short: UILabel!
    @IBOutlet weak var long: UILabel!
    @IBOutlet weak var slash: CustomButtonOutline!
    @IBOutlet weak var rightBypass: NSLayoutConstraint!
    @IBOutlet weak var leftBypass: NSLayoutConstraint!
    
    var customAlert = HintAlert()
    
    var translated = CGPoint.zero
    var bounceDown = false
    var bounceUp = false
    var progressVal = 0.0
    var dontSpace = true
    
    var levelCodeString = "-···/-·--/·--·/·-/···/···"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor(red: 5/255, green: 70/255, blue: 5/255, alpha: 1.0).cgColor, UIColor(red: 5/255, green: 25/255, blue: 70/255, alpha: 1.0).cgColor]
        
        makeBorder(lbl: short)
        makeBorder(lbl: long)
        view.layer.addSublayer(gradient)
        view.bringSubviewToFront(bypassImg)
        view.bringSubviewToFront(foregroundView)
        view.bringSubviewToFront(toolbar)
        game.setValue("chap14", forKey: "active")
        tap.setupButton(color: .link)
        slash.setupButton(color: .link)
        self.startRotation()
        
        foregroundView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture)))
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (tapped))  //tapped function will call when user tap on button
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress))  //longPress function will call when user long press on button.
        tapGesture.numberOfTapsRequired = 1
        tap.addGestureRecognizer(tapGesture)
        tap.addGestureRecognizer(longGesture)
        
        bypassImg.alpha = 0.5
        
        foregroundView.isUserInteractionEnabled = false
    }
    
    func makeBorder(lbl:UILabel) {
        lbl.clipsToBounds = true
        lbl.layer.masksToBounds = true
        lbl.layer.cornerRadius = 15
    }

// defines alert
let alert = MessageAlert()

//function that gets called to dismiss the alertView
@objc func dismissMessageAlert() {
    alert.dismissAlert()
    foregroundView.isUserInteractionEnabled = true
}
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        alert.showAlert(title: "Message from Defender Command", message: "Good work, Brainchild. You look to be very close to gaining access to Project Mayhem’s private servers. When you do, make sure to upload everything to a secure cloud. Victoria tells me you noticed a secret message in a meeting transcript. Murder? What does it mean? Did you notice anything else related to this?", viewController: self, buttonPush: #selector(dismissMessageAlert))
        view.bringSubviewToFront(toolbar)
    }
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.view)
        switch gesture.state {
        case .began:
            break
        case .changed:
            foregroundView.transform = CGAffineTransform(translationX: 0, y: translation.y + translated.y)
            break
        case .ended:
            let DHeight = UIScreen.main.bounds.height
            translated.y += translation.y
            if translated.y < -DHeight + 75 {
                translated.y = -DHeight + 75
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                    self.foregroundView.transform = CGAffineTransform(translationX: 0, y: -DHeight + 75)
                })
                
            }
            if translated.y > DHeight - 150 {
                translated.y = DHeight - 150
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                    self.foregroundView.transform = CGAffineTransform(translationX: 0, y: DHeight - 150)
                })
            }
            if translated.y > -50 && translated.y < 50 {
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                    self.foregroundView.transform = CGAffineTransform(translationX: 0, y: 0)
                })
            }
            break
        default:
            break
        }
    }
    
    func startRotation() {
        if game.string(forKey: "active") != "chap14" {
            return
        }
        bypassImg.rotate(rotation: 0.43, duration: 0.05, option: [.curveLinear])
        wait(time: 0.05, actions: {
            self.startRotation()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nextChap.alpha = 0.0
        nextChap.isUserInteractionEnabled = false
    }
    
    func complete() {
        game.setValue(true, forKey: "chap14")
        nextChap.isUserInteractionEnabled = true
        nextChap.fadeIn()
    }
    
    @IBAction func goBack(_ sender: Any) {
        game.setValue("none", forKey: "active")
        self.performSegue(withIdentifier: "chap14ToHome", sender: nil)
    }
    
    @IBAction func goNext(_ sender: Any) {
        game.setValue("none", forKey: "active")
        self.performSegue(withIdentifier: "chap14ToChap15", sender: nil)
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
            customAlert.showAlert(message: "14", viewController: self, hintButton: hint, toolbar: toolbar)
        }
        
    }
    
    func dismissAlert() {
        customAlert.dismissAlert()
    }
    
    @objc func tapped(gesture: UILongPressGestureRecognizer) {
        short.backgroundColor = .systemGreen
        morseLabel.text?.append("·")
        impact(style: .medium)
        checkForCompletion()
        wait(time: 0.25, actions: {
            self.short.backgroundColor = .clear
        })
    }
    
    @objc func longPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            long.backgroundColor = .systemGreen
            morseLabel.text?.append("-")
            impact(style: .medium)
            checkForCompletion()
            wait(time: 0.25, actions: {
                self.long.backgroundColor = .clear
            })
        }
    }
    
  
    
    func checkForCompletion() {
        var labelString = morseLabel.text
        if labelString?.first == "/" {
            labelString?.removeFirst()
        }
        if levelCodeString == labelString {
            tap.isUserInteractionEnabled = false
            foregroundView.fadeOut()
            wait {
                self.bypassImg.fadeOut()
                wait {
                    self.complete()
                }
            }
        }
    }
    
    @IBAction func addSlash(_ sender: Any) {
        if tap.isUserInteractionEnabled {
            impact(style: .medium)
            morseLabel.text?.append("/")
        }
    }
    
    @IBAction func backspace(_ sender: Any) {
        if morseLabel.text != "" && tap.isUserInteractionEnabled {
            impact(style: .medium)
            morseLabel.text?.removeLast()
        }
    }
    
    
}

