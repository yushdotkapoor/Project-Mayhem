//
//  chapter1.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 12/22/20.
//

import UIKit

var menuState = false

class chapter1: UIViewController, UNUserNotificationCenterDelegate {
    @IBOutlet weak var leave: UILabel!
    @IBOutlet weak var now: UILabel!
    @IBOutlet weak var good: UILabel!
    @IBOutlet weak var glad: UILabel!
    @IBOutlet weak var nameStack: UIStackView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var ScrollView: UIScrollView!
    @IBOutlet weak var welcome: UILabel!
    @IBOutlet weak var nextChap: UIButton!
    @IBOutlet weak var hint: UIButton!
    @IBOutlet weak var toolbar: UIStackView!
    
    let notificationCenter = NotificationCenter.default
    
    override func viewDidLoad() {
           super.viewDidLoad()
        menuState = false
        
            notificationCenter.addObserver(self, selector: #selector(foreground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
            notificationCenter.addObserver(self, selector: #selector(background), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneClicked))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        nameField.inputAccessoryView = toolBar
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let active = game.string(forKey: "active")
        switch active! {
            case "chap1":
                part1()
                break
            case "chap1.1":
                part2()
                break
            default:
                break
        }
    }
    
    func part1() {
        leave.fadeIn()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.now.fadeIn()
        }
    }
    
    func part2() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.leave.fadeOut()
            self.now.fadeOut()
            
            game.setValue("chap1.2", forKey: "active")
            self.good.fadeIn()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.glad.fadeIn()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.nameStack.fadeIn()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let active = game.string(forKey: "active") ?? "none"
        switch active {
            case "none":
                game.setValue("chap1", forKey: "active")
                leave.alpha = 0.0
                now.alpha = 0.0
                good.alpha = 0.0
                glad.alpha = 0.0
                nameStack.alpha = 0.0
                break
            case "chap1.1":
                leave.alpha = 1.0
                now.alpha = 1.0
                good.alpha = 0.0
                glad.alpha = 0.0
                nameStack.alpha = 0.0
                break
            case "chap1.2":
                leave.alpha = 0.0
                now.alpha = 0.0
                good.alpha = 1.0
                glad.alpha = 1.0
                nameStack.alpha = 1.0
                break
            default:
                game.setValue("none", forKey: "active")
                viewWillAppear(true)
                break
        }
 
        welcome.alpha = 0.0
        nextChap.alpha = 0.0
        nextChap.isUserInteractionEnabled = false
    }
    
    @IBAction func submitName(_ sender: Any) {
        let name = nameField.text
        if name != "" {
            nextChap.alpha = 0.0
            game.setValue(name, forKey: "name")
            game.setValue(true, forKey: "chap1")
            game.setValue("none", forKey: "active")
            view.endEditing(true)
            nameField.text = ""
            welcome.text = "Welcome to Project Mayhem, \(name!)"
            welcome.fadeIn()
            nextChap.isUserInteractionEnabled = true
            nextChap.fadeIn()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.nameStack.fadeOut()
                self.good.fadeOut()
                self.glad.fadeOut()
            }
        }
        else {
            //alert the user that the field cannot be blank
            alert(title: "Error", message: "You must enter your name in the provided field. Otherwise, I cannot trust you.", actionTitle: "OK")
        }
    }
   
    
    @IBAction func goNext(_ sender: Any) {
        notificationCenter.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        self.performSegue(withIdentifier: "chap1ToChap2", sender: nil)
    }
    
    @IBAction func goBack(_ sender: Any) {
        notificationCenter.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        self.performSegue(withIdentifier: "chap1ToHome", sender: nil)
    }
    
    
    
    @objc func foreground() {
        notificationCenter.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        UIApplication.shared.applicationIconBadgeNumber = 0
        viewWillAppear(true)
        viewDidAppear(true)
    }
    
    @objc func background() {
        notificationCenter.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        let cont = UNMutableNotificationContent()
        cont.title = "Project Mayhem"
        cont.body = "Now Come Back"
        cont.badge = NSNumber(value: 1)
        cont.sound = UNNotificationSound.default

        // show this notification one second from now
        let trig = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: cont, trigger: trig)

        // add our notification request
        UNUserNotificationCenter.current().add(request)
        
        game.setValue("chap1.1", forKey: "active")
    }
    
    let customAlert = HintAlert()
    
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
            customAlert.showAlert(message: "Leave what?", viewController: self, hintButton: hint)
            view.bringSubviewToFront(toolbar)
        }
        
    }
    
    func dismissAlert() {
        customAlert.dismissAlert()
    }
    
    @objc func doneClicked() {
        view.endEditing(true)
    }
   
}

