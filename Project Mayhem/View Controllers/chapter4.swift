//
//  chapter4.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 12/30/20.
//

import UIKit
import CoreMotion

class chapter4: UIViewController {
    @IBOutlet weak var nextChap: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var one: UILabel!
    @IBOutlet weak var hint: UIButton!
    @IBOutlet weak var toolbar: UIStackView!
    @IBOutlet weak var imageBottom: NSLayoutConstraint!
    
    var customAlert = HintAlert()
    
    let motionManager = CMMotionManager()
    
    var posX:Double = 0.0
    var posY:Double = 0.0
    
    var completion:[Bool] = [false, false, false, false, false, false]
    var compareArr1:[String] = [">", "<", ">", "<", ">", "<"]
    var compareArr2:[String] = [">", "", "<", "<", "", ">"]
    var new = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    func startLevel() {
        if motionManager.isAccelerometerAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1;
            motionManager.startDeviceMotionUpdates()
            
            motionManager.accelerometerUpdateInterval = 0.1
            guard let currentQueue = OperationQueue.current else { return }
            motionManager.startAccelerometerUpdates(to: currentQueue) { (data, error) in
                
                if let position = data?.acceleration {
                    self.posX = position.x
                    self.posY = position.y
                }
                if error != nil {
                    print(error!)
                }
            }
        }
        self.oneCheck(first: compareArr1[0], second: compareArr2[0])
    }
    
    
    // defines alert
    let alert = MessageAlert()
    
    //function that gets called to dismiss the alertView
    @objc func dismissMessageAlert() {
        alert.dismissAlert()
        startLevel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(background), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(reenter), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        alert.showAlert(title: "\(messageFrom) Victoria Lambson", message: "Great work getting access within Vision! My name is Vickie and I am also a Defender. I will try to guide you through Vision’s systems to aid in your investigation. Vision has better security than most U.S. government agencies, but we have insider knowledge on how to bypass those hurdles. The director has briefed me on who you are and I must say, I'm quite a fan of yours, Brainchild. Anyway, I’ll let you get back to your mission. Just know that I will be monitoring you all the way through!".localized(), viewController: self, buttonPush: #selector(dismissMessageAlert))
    }
    
    func oneCheck(first: String, second: String) {
        if posX == 10000 {
            return
        }
        else if comp(comp: first, pos: posX) && comp(comp: second, pos: posY) {
            checkpt()
        }
        else {
            wait(time: 0.1, actions: {
                self.oneCheck(first: first, second: second)
            })
        }
    }
    
    func comp(comp: String, pos: Double) -> Bool {
        if comp == ">" {
            return pos > 0.5
        }
        else if comp == "<" {
            return pos < -0.5
        }
        else {
            return true
        }
    }
    
    func checkpt() {
        new += 1
        for (i, boo) in completion.enumerated() {
            if !boo {
                completion[i] = true
                update()
                if i < 5 {
                    wait(time: 0.75, actions: {
                        self.oneCheck(first: self.compareArr1[i + 1], second: self.compareArr2[i + 1])
                    })
                }
                else {
                    finish()
                }
                return
            }
        }
    }
    
    func update() {
        impact(style: .rigid)
        imageView.image = UIImage(named: "lvl4_\(new)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nextChap.alpha = 0.0
        nextChap.isUserInteractionEnabled = false
    }
    
    
    func complete() {
        game.setValue(true, forKey: "chap4")
        game.setValue("none", forKey: "active")
        NotificationCenter.default.removeObserver(self)
        nextChap.isUserInteractionEnabled = true
        impact(style: .success)
        nextChap.fadeIn()
    }
    
    func finish() {
        motionStop()
        self.one.fadeOut()
        wait {
            self.complete()
        }
    }
    
    @objc func background() {
        motionStop()
    }
    
    @objc func reenter() {
        posX = 0.0
        startLevel()
    }
    
    func motionStop() {
        posX = 10000
        motionManager.stopAccelerometerUpdates()
        motionManager.stopDeviceMotionUpdates()
    }
    
    @IBAction func goBack(_ sender: Any) {
        motionStop()
        NotificationCenter.default.removeObserver(self)
        self.performSegue(withIdentifier: "chap4ToHome", sender: nil)
    }
    
    @IBAction func goNext(_ sender: Any) {
        performSegue(withIdentifier: "chap4ToChap5", sender: nil)
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
            customAlert.showAlert(message: "4", viewController: self, hintButton: hint, toolbar: toolbar)
        }
        
    }
    
    func dismissAlert() {
        customAlert.dismissAlert()
    }
    
}


