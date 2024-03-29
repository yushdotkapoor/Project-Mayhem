//
//  chapter6.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 1/30/21.
//

import UIKit
import AVFoundation
import StoreKit

var chap6Timer = false

class chapter6: UIViewController {
    @IBOutlet weak var nextChap: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var heder: UILabel!
    @IBOutlet weak var hint: UIButton!
    @IBOutlet weak var toolbar: UIStackView!
    @IBOutlet weak var textStack: UIStackView!
    @IBOutlet weak var back: UIButton!
    @IBOutlet weak var circleView: CircularProgressBarView!
    @IBOutlet weak var titl: UILabel!
    
    var customAlert = HintAlert()
    
    var window:UIWindow?
    
    let short: Double = 0.2
    let long: Double = 0.7
    
    var sequenceOfFlashes: [Double] = []
    var actionArray: [String] = []
    var vibrateShouldStop = false
    
    let morseString = "Neuschwanstein"
    
    var index: Int = 0
    
    weak var timer: Timer?
    
    var pad: Bool = false
    
    var motherCount:Double = 0
    
    let circleViewProgress:TimeInterval = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        titl.text = "From the darkness, comes the light".localized()
        
        game.setValue("chap6", forKey: "active")
        wait {
            self.label.fadeIn()
            wait(time: 0.5, actions: {
                if game.string(forKey: "active") == "chap6" {
                    self.setupMorseFlashesSequence()
                }
            })
        }
        sequenceOfFlashes.removeAll()
        actionArray.removeAll()
        index = 0
        motherCount = 0
        vibrateShouldStop = false
        chap6Timer = false
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
        notificationCenter.addObserver(self, selector: #selector(stop), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(cameBack), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneClicked))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        textField.inputAccessoryView = toolBar
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(gesture:)))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        
        //to check if iPad or other device, this will cause the back button to flash in morse
        // rather than vibrate and flash
        
        let sensitive = game.bool(forKey: "photosensitive")
        if (UIDevice.current.model != "iPhone" && UIDevice.current.model != "iPod") || sensitive {
            pad = true
        }
        
        circleView.createCircularPath(radius: 10)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        label.alpha = 0.0
        nextChap.alpha = 0.0
        nextChap.isUserInteractionEnabled = false
    }
    
    func setupMorseFlashesSequence() {
        circleView.progressAnimation(duration: circleViewProgress)
        var translatedArray = morseString.stringToMorse()
        
        translatedArray.append("   ")
        
        for i in translatedArray {
            switch i {
            case "·":
                sequenceOfFlashes.append(short)
                sequenceOfFlashes.append(short)
                actionArray.append("·")
                actionArray.append("/")
                motherCount += 1
            case "-":
                sequenceOfFlashes.append(long)
                sequenceOfFlashes.append(short)
                actionArray.append("-")
                actionArray.append("/")
                motherCount += 1
            case " ":
                sequenceOfFlashes.append(long)
                actionArray.append(" ")
            default:
                break
            }
        }
        
        if !chap6Timer {
            chap6Timer = true
            scheduleTimer()
        }
    }
    
    @objc func scheduleTimer() {
        if index == 1000 || !chap6Timer {
            return
        }
        
        game.setValue("chap6", forKey: "active")
        timer = Timer.scheduledTimer(timeInterval: sequenceOfFlashes[index], target: self, selector: #selector(timerTick), userInfo: nil, repeats: false)
    }
    
    @objc func timerTick() {
        if index == 1000 || !chap6Timer {
            return
        }
        if index == sequenceOfFlashes.count {
            chap6Timer = false
            restart()
            return
        }
        else {
            let act = actionArray[index]
            if act == " " {
                turnFlashlight(on: false)
            }
            else if act == "/" {
                turnFlashlight(on: false)
            }
            else if act == "-" {
                turnFlashlight(on: true)
                impactInside()
                if pad {
                    back.tintColor = .white
                }
                wait(time: 0.35, actions: {
                    self.vibrateShouldStop = true
                })
            }
            else if act == "·" {
                turnFlashlight(on: true)
                impactInside()
                if pad {
                    back.tintColor = .white
                }
                wait(time: 0.15, actions: {
                    self.vibrateShouldStop = true
                })
            }
            scheduleTimer()
        }
        index += 1
    }
    
    func impactInside() {
        if vibrateShouldStop {
            vibrateShouldStop = false
            back.tintColor = .darkGray
            return
        }
        else {
            wait(time: 0.01, actions: {
                impact(style: .medium)
                self.impactInside()
            })
        }
    }
    
    func checkArrayFilled() {
        if sequenceOfFlashes.count == 0 {
            sequenceOfFlashes.removeAll()
            actionArray.removeAll()
            setupMorseFlashesSequence()
        }
    }
    
    func restart() {
        if game.string(forKey: "active") == "chap6" && !chap6Timer {
            chap6Timer = true
            checkArrayFilled()
            index = 0
            scheduleTimer()
            
            circleView.progressAnimation(duration: circleViewProgress)
        }
    }
    
    @objc func stop() {
        game.setValue("none", forKey: "active")
        timer?.invalidate()
        chap6Timer = false
        turnFlashlight(on: false)
        index = 1000
    }
    
    @objc func cameBack() {
        game.setValue("chap6", forKey: "active")
        wait {
            if game.string(forKey: "active") == "chap6" {
                self.restart()
            }
        }
    }
    
    @IBAction func submit(_ sender: Any) {
        let text = textField.text?.removeLastSpace().lowercased()
        if text == morseString.lowercased() {
            view.endEditing(true)
            heder.flickerIn()
            stop()
            circleView.stopAnimation()
            textStack.isUserInteractionEnabled = false
            wait {
                self.alert.showAlert(title: "\(messageFrom) Victoria Lambson", message: "This is quite interesting. What does Neuschwanstein castle have to do with Project Mayhem? This was never reported in our security reports.".localized(), viewController: self, buttonPush: #selector(self.dismissMessageAlert))
            }
        }
        else if text!.contains("bitch") || text!.contains("fuck") || text!.contains("shit") {
            view.endEditing(true)
            alert(title: "Dammnnnn", message: "Those are some inappropriate words you dumb fuck, go rinse your mouth with some soap.", actionTitle: "lmao don't hurt me")
        }
        else if text != "" {
            textField.shake()
            textField.text = ""
        }
    }
    
    // defines alert
    let alert = MessageAlert()
    
    //function that gets called to dismiss the alertView
    @objc func dismissMessageAlert() {
        alert.dismissAlert()
        complete()
    }
    
    
    func turnFlashlight(on: Bool) {
        let sensitive = game.bool(forKey: "photosensitive")
        if !sensitive {
            guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
            guard device.hasTorch else {
                pad = true
                print("Torch isn't available")
                return
            }
            
            do {
                try device.lockForConfiguration()
                
                if on {
                    device.torchMode = .on
                    try device.setTorchModeOn(level: 0.5)
                }
                else {
                    device.torchMode = .off
                }
                
                device.unlockForConfiguration()
            } catch {
                pad = true
                print("Torch can't be used")
            }
        }
    }
    
    func complete() {
        NotificationCenter.default.removeObserver(self)
        let pre = game.bool(forKey: "chap6")
        game.setValue(true, forKey: "chap6")
        if !pre {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
        nextChap.isUserInteractionEnabled = true
        impact(style: .success)
        nextChap.fadeIn()
    }
    
    @objc func doneClicked() {
        view.endEditing(true)
    }
    
    @objc func viewTapped(gesture: UIGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func goBack(_ sender: Any) {
        stop()
        NotificationCenter.default.removeObserver(self)
        self.performSegue(withIdentifier: "chap6ToHome", sender: nil)
    }
    
    @IBAction func goNext(_ sender: Any) {
        self.performSegue(withIdentifier: "chap6ToChap7", sender: nil)
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
            customAlert.showAlert(message: "6", viewController: self, hintButton: hint, toolbar: toolbar)
        }
        
    }
    
    func dismissAlert() {
        customAlert.dismissAlert()
    }
    
    
}
