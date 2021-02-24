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
    
    let customAlert = HintAlert()
    
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
        hintText = "Battery, battery, battery. It bugs me that the battery isn't completely full"
        
        one = false
        two = false
        three = false
        
        UIDevice.current.isBatteryMonitoringEnabled = true

        NotificationCenter.default.addObserver(self, selector: #selector(batteryStateDidChange), name: UIDevice.batteryStateDidChangeNotification, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nextChap.alpha = 0.0
        nextChap.isUserInteractionEnabled = false
    }
    
    @objc func batteryStateDidChange() {
        let state = UIDevice.current.batteryState.rawValue
        
        if state == 2 {
            batteryImg.fadeOut()
            backView.fadeIn()
            p2Stack.fadeIn()
            hintText = "Roses are red, violets are blue, i'm pretty sure that this is a date"
            NotificationCenter.default.addObserver(self, selector: #selector(timeChanged), name:UIApplication.significantTimeChangeNotification, object: nil)
        }
    }
    
    @objc func timeChanged() {
        let date = Date().timeIntervalSince1970 * 1000
        let timezoneOffset =  TimeZone.current.secondsFromGMT() * 1000
        let currentDate = Int(date) + Int(timezoneOffset)
        
        let may29 = 1022630400000
        let may30 = 1022716799999
        
        if currentDate > may29 && currentDate < may30 {
            backView.fadeOut()
            aStack.fadeIn()
            hintText = "Is there a way to change the size of text?"
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
        nextChap.isUserInteractionEnabled = true
        nextChap.fadeIn()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func goBack(_ sender: Any) {
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
            customAlert.showAlert(message: hintText, viewController: self, hintButton: hint)
            view.bringSubviewToFront(toolbar)
        }
        
    }
    
    func dismissAlert() {
        customAlert.dismissAlert()
    }

}

