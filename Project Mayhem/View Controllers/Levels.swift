//
//  Levels.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 12/22/20.
//

import UIKit

let game = UserDefaults.standard

class Levels: UIViewController {
    
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
    
    var del = 0.5
    
    override func viewDidLoad() {
           super.viewDidLoad()
        del = 0.5
        requestNotificationAuthorization()
    }
    
    func colorize() {
        let array = ["chap1", "chap2", "chap3", "chap4", "chap5", "chap6"]
        let arrayButtons = [chap1, chap2, chap3, chap4, chap5, chap6]
        var i = 0
        
        for button in arrayButtons {
            if button != chap1 {
            button?.setupButton(color: UIColor.darkGray)
            button?.isEnabled = false
            }
        }
        
        for chapter in array {
            let completion = game.bool(forKey: chapter)
            if completion {
                arrayButtons[i]?.setupButton(color: UIColor.green)
                arrayButtons[i]?.isEnabled = true
                arrayButtons[i+1]?.setupButton(color: UIColor.white)
                arrayButtons[i+1]?.isEnabled = true
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
        
        animate(constraint: chap1Center)
        animate(constraint: chap2Center)
        animate(constraint: chap3Center)
        animate(constraint: chap4Center)
        animate(constraint: chap5Center)
        animate(constraint: chap6Center)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chap1Center.constant -= view.bounds.width
        chap2Center.constant -= view.bounds.width
        chap3Center.constant -= view.bounds.width
        chap4Center.constant -= view.bounds.width
        chap5Center.constant -= view.bounds.width
        chap6Center.constant -= view.bounds.width
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
            print(self.chap1.bounds)
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

extension UIViewController {
    func alert(title: String, message: String, actionTitle: String) {
        
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: actionTitle, style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
    }
    
    func alert(title: String, message: String, actionTitle: String, actions: @escaping () -> Void) {
        
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: actionTitle, style: .cancel, handler: { action in actions()})
        
        alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
    }
    
    
}

