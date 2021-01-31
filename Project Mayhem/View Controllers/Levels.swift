//
//  Levels.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 12/22/20.
//

import UIKit

let game = UserDefaults.standard

class Levels: UIViewController {
    
    @IBOutlet weak var chap10: CustomButtonOutline!
    @IBOutlet weak var chap9: CustomButtonOutline!
    @IBOutlet weak var chap8: CustomButtonOutline!
    @IBOutlet weak var chap7: CustomButtonOutline!
    @IBOutlet weak var chap6: CustomButtonOutline!
    @IBOutlet weak var chap5: CustomButtonOutline!
    @IBOutlet weak var chap4: CustomButtonOutline!
    @IBOutlet weak var chap3: CustomButtonOutline!
    @IBOutlet weak var chap2: CustomButtonOutline!
    @IBOutlet weak var chap1: CustomButtonOutline!
    @IBOutlet weak var logoWidth: NSLayoutConstraint!
    @IBOutlet weak var chap1Center: NSLayoutConstraint!
    @IBOutlet weak var chap2Center: NSLayoutConstraint!
    @IBOutlet weak var chap3Center: NSLayoutConstraint!
    @IBOutlet weak var chap4Center: NSLayoutConstraint!
    @IBOutlet weak var chap5Center: NSLayoutConstraint!
    @IBOutlet weak var chap6Center: NSLayoutConstraint!
    @IBOutlet weak var chap7Center: NSLayoutConstraint!
    @IBOutlet weak var chap8Center: NSLayoutConstraint!
    @IBOutlet weak var chap9Center: NSLayoutConstraint!
    @IBOutlet weak var chap10Center: NSLayoutConstraint!
    
    var del = 0.5
    
    override func viewDidLoad() {
           super.viewDidLoad()
        del = 0.5
        requestNotificationAuthorization()
        
        let controllers = getData(string: "ViewController") as! [UIViewController]
        
        for c in controllers {
            NotificationCenter.default.removeObserver(c)
        }
        
        //reset()
    }
    
    func reset() {
        let reset = getData(string: "String") as! [String]
        
        for r in reset {
            game.setValue(false, forKey: r)
        }
    }
    
    func getData(string: String) -> [Any] {
        if string == "Center" {
        return [chap1Center, chap2Center, chap3Center, chap4Center, chap5Center, chap6Center, chap7Center, chap8Center, chap9Center, chap10Center] as [NSLayoutConstraint]
        }
        else if string == "String" {
            return ["chap1", "chap2", "chap3", "chap4", "chap5", "chap6", "chap7", "chap8", "chap9", "chap10"] as [String]
        }
        else if string == "ViewController" {
            return [chapter1(), chapter2(), chapter3(), chapter4(), chapter5(), chapter6(), chapter7(), chapter8(), chapter9(), chapter10()] as [UIViewController]
        }
        else {
            return [chap1, chap2, chap3, chap4, chap5, chap6, chap7, chap8, chap9, chap10] as [CustomButtonOutline]
        }
    }
    
    func colorize() {
        let array = getData(string: "String") as! [String]
        
        let arrayButtons = getData(string: "Buttons") as! [CustomButtonOutline]
        var i = 0
        
        for button in arrayButtons {
            if button != chap1 {
                button.setupButton(color: UIColor.darkGray)
                button.isEnabled = false
            }
        }
        
        for chapter in array {
            let completion = game.bool(forKey: chapter)
            if completion {
                arrayButtons[i].setupButton(color: UIColor.green)
                arrayButtons[i].isEnabled = true
                arrayButtons[i+1].setupButton(color: UIColor.white)
                arrayButtons[i+1].isEnabled = true
            }
            i += 1
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        colorize()
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
            self.logoWidth.constant *= 0.5
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        let centers = getData(string: "Center")
        
        for button in centers {
            animate(constraint: button as! NSLayoutConstraint)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let centers = getData(string: "Center")
        
        for button in centers {
            let b = button as! NSLayoutConstraint
            b.constant -= view.bounds.width
        }
    }
    
    @IBAction func chap1(_ sender: Any) {
        let current = UNUserNotificationCenter.current()
        
        current.getNotificationSettings(completionHandler: { (settings) in
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                DispatchQueue.main.async {
                self.performSegue(withIdentifier: "LevelsToChap1", sender: nil)
                }
                break
            case .denied, .notDetermined:
                DispatchQueue.main.async {
                    self.alert(title: "Error", message: "You must agree to receive notifications from this app to continue. Go to Settings > Project Mayhem > Notifications > Turn on 'Allow Notifications'", actionTitle: "OK", actions: {
                        UIApplication.shared.open(URL(string:"App-Prefs:root=NOTIFICATIONS_ID")!, options: [:], completionHandler: nil)
                        })
                    game.setValue("none", forKey: "active")
                }
                break
            case .ephemeral:
                DispatchQueue.main.async {
                    self.alert(title: "Error", message: "Make sure you can receive notifications from this app at all times", actionTitle: "OK", actions: {
                    UIApplication.shared.open(URL(string:"App-Prefs:root=NOTIFICATIONS_ID")!, options: [:], completionHandler: nil)
                    })
                    game.setValue("none", forKey: "active")
                }
                break
            @unknown default:
                DispatchQueue.main.async {
                self.performSegue(withIdentifier: "LevelsToChap1", sender: nil)
                }
                break
            }
        })
    }
    
    func animate(constraint: NSLayoutConstraint) {
        UIView.animate(withDuration: 0.5, delay: del, options: .curveEaseOut, animations: {
            constraint.constant += self.view.bounds.width
            self.view.layoutIfNeeded()
        }, completion: nil)
        del += 0.1
    }
}

func requestNotificationAuthorization() {
    let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
    UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (success, error) in
        if let error = error {
            print(error.localizedDescription)
        }
    }
}



