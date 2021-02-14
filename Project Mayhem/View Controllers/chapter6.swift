//
//  chapter6.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 1/30/21.
//

import UIKit
import AVFoundation

var chap6Timer = false

class chapter6: UIViewController {
    @IBOutlet weak var nextChap: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var heder: UILabel!
    @IBOutlet weak var hint: UIButton!
    @IBOutlet weak var toolbar: UIStackView!
    
    let customAlert = HintAlert()
    
    var window:UIWindow?
    
    let short: Double = 0.2
    let long: Double = 0.6

    var sequenceOfFlashes: [Double] = []
    var actionArray: [String] = []
    var vibrateShouldStop = false
    
    let morseString = "Neuschwanstein"
    
    var index: Int = 0

    weak var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        game.setValue("chap6", forKey: "active")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.label.fadeIn()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if game.string(forKey: "active") == "chap6" {
                    self.setupMorseFlashesSequence()
                }
            }
        }
        sequenceOfFlashes.removeAll()
        actionArray.removeAll()
        index = 0
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        label.alpha = 0.0
        nextChap.alpha = 0.0
        nextChap.isUserInteractionEnabled = false
    }

    func setupMorseFlashesSequence() {
        var translatedArray = morseString.stringToMorse()
        
        translatedArray.append("   ")
        
        for i in translatedArray {
            switch i {
            case ".":
                sequenceOfFlashes.append(short)
                sequenceOfFlashes.append(short)
                actionArray.append(".")
                actionArray.append("/")
            case "-":
                sequenceOfFlashes.append(long)
                sequenceOfFlashes.append(short)
                actionArray.append("-")
                actionArray.append("/")
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
                impact()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    self.vibrateShouldStop = true
                }
                turnFlashlight(on: true)
            }
            else if act == "." {
                impact()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    self.vibrateShouldStop = true
                }
                turnFlashlight(on: true)
            }
            scheduleTimer()
        }
        index += 1
    }
    
    func impact() {
        let vibrate = UIImpactFeedbackGenerator(style: .medium)
        if vibrateShouldStop {
            vibrateShouldStop = false
            return
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                vibrate.impactOccurred()
                self.impact()
            }
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if game.string(forKey: "active") == "chap6" {
                self.restart()
            }
        }
    }

    deinit {
        stop()
    }
    
    @IBAction func submit(_ sender: Any) {
        if textField.text?.lowercased() == morseString.lowercased() {
            doneClicked()
            heder.flickerIn()
            stop()
            complete()
        }
        else if textField.text != "" {
            textField.shake()
            textField.text = ""
        }
    }
    
    
    func turnFlashlight(on: Bool) {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        guard device.hasTorch else { print("Torch isn't available"); return }

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
            print("Torch can't be used")
        }
    }
    
    func complete() {
        NotificationCenter.default.removeObserver(self)
        game.setValue(true, forKey: "chap6")
        nextChap.isUserInteractionEnabled = true
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
            hint.rotate(rotation: 0.49999, duration: 0.5)
            UIView.animate(withDuration: 0.5) {
                self.hint.tintColor = UIColor.lightGray
            }
            customAlert.showAlert(message: "Seems like this is a coded message!", viewController: self, hintButton: hint)
            view.bringSubviewToFront(toolbar)
        }
        
    }
    
    func dismissAlert() {
        customAlert.dismissAlert()
    }


}
