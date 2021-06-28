//
//  chapter12.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 02/02/21.
//

import UIKit

class chapter12: UIViewController {
    @IBOutlet weak var nextChap: UIButton!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet weak var batteryImg: UIImageView!
    @IBOutlet weak var p2Stack: UIStackView!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var aStack: UIStackView!
    @IBOutlet weak var a1: UIImageView!
    @IBOutlet weak var a2: UIImageView!
    @IBOutlet weak var a3: UIImageView!
    @IBOutlet weak var hint: UIButton!
    @IBOutlet weak var toolbar: UIStackView!
    @IBOutlet weak var gemini: UIImageView!
    
    var customAlert = HintAlert()
    
    var hintText = ""
    
    
    var one = false
    var two = false
    var three = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backView.alpha = 0
        p2Stack.alpha = 0
        aStack.alpha = 0
        year.text = year.text?.stringToBinary()
        //12.1
        hintText = "12.1"
        
        one = false
        two = false
        three = false
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(batteryStateDidChange), name: UIDevice.batteryStateDidChangeNotification, object: nil)
        
        gemini.layer.cornerRadius = gemini.frame.size.height / 2
        
        toolbar.add3DMotionShadow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nextChap.alpha = 0.0
        nextChap.isUserInteractionEnabled = false
    }
    
    @objc func batteryStateDidChange() {
        let state = UIDevice.current.batteryState
        print(state.rawValue)
        
        if state == .charging || state == .full {
            batteryImg.fadeOut()
            backView.fadeIn()
            p2Stack.fadeIn()
            view.bringSubviewToFront(toolbar)
            //12.2
            hintText = "12.2"
            NotificationCenter.default.addObserver(self, selector: #selector(timeChanged), name:UIApplication.significantTimeChangeNotification, object: nil)
        }
    }
    
    @objc func timeChanged() {
        let date = Date().timeIntervalSince1970 * 1000
        let timezoneOffset =  TimeZone.current.secondsFromGMT() * 1000
        let currentDate = Int(date) + Int(timezoneOffset)
        
        let jun29 = 1025308800000
        let jun30 = 1025395200000
        
        if currentDate > jun29 && currentDate < jun30 {
            backView.fadeOut()
            aStack.fadeIn()
            hintText = "12.3"
            NotificationCenter.default.addObserver(self, selector: #selector(sizeChanged), name:UIContentSizeCategory.didChangeNotification, object: nil)
            
        }
    }
    
    @objc func sizeChanged() {
        let size = UIApplication.shared.preferredContentSizeCategory
        switch size {
        case UIContentSizeCategory.extraSmall, UIContentSizeCategory.small:
            a1.tintColor = UIColor.green
            one = true
            break
        case UIContentSizeCategory.medium, UIContentSizeCategory.large, UIContentSizeCategory.extraLarge:
            a2.tintColor = UIColor.green
            two = true
            break
        case UIContentSizeCategory.extraExtraLarge, UIContentSizeCategory.extraExtraExtraLarge:
            a3.tintColor = UIColor.green
            three = true
            break
        default:
            break
        }
        
        if one && two && three {
            a1.tintColor = UIColor.systemTeal
            a2.tintColor = UIColor.systemTeal
            a3.tintColor = UIColor.systemTeal
            wait {
                self.complete()
            }
        }
        
    }
    
    func complete() {
        game.setValue(true, forKey: "chap12")
        game.setValue("none", forKey: "active")
        NotificationCenter.default.removeObserver(self)
        nextChap.isUserInteractionEnabled = true
        impact(style: .success)
        nextChap.fadeIn()
    }
    
    @IBAction func goBack(_ sender: Any) {
        NotificationCenter.default.removeObserver(self)
        self.performSegue(withIdentifier: "chap12ToHome", sender: nil)
    }
    
    @IBAction func goNext(_ sender: Any) {
        self.performSegue(withIdentifier: "chap12ToChap13", sender: nil)
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
            customAlert.showAlert(message: hintText, viewController: self, hintButton: hint, toolbar: toolbar)
        }
        
    }
    
    func dismissAlert() {
        customAlert.dismissAlert()
    }
    
}

