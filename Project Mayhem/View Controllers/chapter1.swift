//
//  chapter1.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 12/22/20.
//

import UIKit
import AVFoundation



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
    @IBOutlet weak var clickTheRick: UIButton!
    @IBOutlet weak var submissionButton: UIButton!
    @IBOutlet weak var enterName: UILabel!
    
    var skipVal = ["chap1", "chap2", "chap3", "chap4", "chap5", "chap6", "chap7", "chap8", "chap9", "chap10", "chap11", "chap12", "chap13", "chap14", "preChap15"]
    var skippable = ["medulla", "frontalCortex", "cerebellum", "occipitalLobe", "opticChiasm", "lateralGeniculateNucleus", "supramarginalGyrus", "HerschlsGyrus", "amygdala", "thalamus", "hippocampus", "fusiformGyrus", "corpusCallosum", "lateralVentricle", "duraMater"]
    var skippableFree = ["medulla", "frontalCortex", "cerebellum", "occipitalLobe"]
    
    let notificationCenter = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuState = false
        welcome.text = "Welcome".localized()
        leave.text = "Leave".localized().uppercased()
        good.text = "good".localized()
        glad.text = "i'm glad you can follow commands".localized()
        enterName.text = "now enter your name below".localized()
        clickTheRick.setTitle("Click here if you dare".localized(), for: .normal)
        submissionButton.setTitle("Submit".localized(), for: .normal)
        
        notificationCenter.addObserver(self, selector: #selector(foreground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(background), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .denied, .ephemeral, .notDetermined:
                    self.now.text = "Come back ASAP".localized()
                    break
                case .authorized, .provisional:
                    self.now.text = "Don't come back until I tell you to".localized()
                    break
                @unknown default:
                    break
                }
            }
        })
        
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneClicked))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        nameField.inputAccessoryView = toolBar
        
        view.bringSubviewToFront(toolbar)
        
        toolbar.add3DMotionShadow()
        
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
        wait {
            self.now.fadeIn()
        }
    }
    
    func part2() {
        wait(time: 0.3, actions: {
            self.leave.fadeOut()
            self.now.fadeOut()
            
            game.setValue("chap1.2", forKey: "active")
            self.good.fadeIn()
            wait {
                self.glad.fadeIn()
            }
            wait(time: 3, actions: {
                self.clickTheRick.fadeIn()
            })
            wait(time: 5, actions: {
                self.nameStack.fadeIn()
            })
        })
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
            clickTheRick.alpha = 0.0
            break
        case "chap1.1":
            leave.alpha = 1.0
            now.alpha = 1.0
            good.alpha = 0.0
            glad.alpha = 0.0
            nameStack.alpha = 0.0
            clickTheRick.alpha = 0.0
            break
        case "chap1.2":
            leave.alpha = 0.0
            now.alpha = 0.0
            good.alpha = 1.0
            glad.alpha = 1.0
            nameStack.alpha = 1.0
            clickTheRick.alpha = 1.0
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
        let name = nameField.text?.removeLastSpace()
        if !skip() {
            let gameName = game.string(forKey: "name")
            if name == "" {
                //alert the user that the field cannot be blank
                alert(title: "Error".localized(), message: "You must enter your name in the provided field. Otherwise, I cannot trust you.".localized(), actionTitle: "Okay".localized())
            } else if gameName != name && gameName != nil {
                let l1 = "This name conflicts with the name you gave before:".localized()
                let l2 = "Would you like to change your name from".localized()
                let l3 = "to".localized()
                
                let alertController = UIAlertController(title: "Please advise".localized(), message: "\(l1) \(gameName!). \(l2) \(gameName!) \(l3) \(name!)?", preferredStyle: .alert)
                let yes = UIAlertAction(title: "Yes".localized(), style: .default, handler: { action in
                    self.setName(name: name!)
                })
                let no = UIAlertAction(title: "No".localized(), style: .cancel, handler: nil)
                
                alertController.addAction(yes)
                alertController.addAction(no)
                self.present(alertController, animated: true, completion: nil)
            }
            else {
                setName(name: name!)
            }
        }
    }
    
    func setName(name: String) {
        nextChap.alpha = 0.0
        game.setValue(name, forKey: "name")
        game.setValue(true, forKey: "chap1")
        game.setValue("none", forKey: "active")
        view.endEditing(true)
        nameField.text = ""
        let m1 = "Welcome to Project Mayhem,".localized()
        welcome.text = "\(m1) \(name)"
        welcome.fadeIn()
        wait {
            self.nameStack.fadeOut()
            self.good.fadeOut()
            self.glad.fadeOut()
            self.clickTheRick.fadeOut()
            wait {
                self.welcome.flickerIn(iterations: 10)
                self.welcome.text = "\(m1) Branechild"
                self.welcome.textColor = .red
                self.vibrate(count: 5)
                wait(time: 0.75, actions: {
                    self.vibrate(count: 5)
                    self.welcome.flickerIn(iterations: 10)
                    self.welcome.text = "\(m1) Brainchild"
                    self.welcome.textColor = .black
                    self.nextChap.isUserInteractionEnabled = true
                    impact(style: .success)
                    self.nextChap.fadeIn()
                })
            }
        }
        
    }
    
    func skip() -> Bool {
        let arr:[String] = skippable
        
        for (index,val) in arr.enumerated() {
            print(val.lowercased())
            if (val.lowercased() == nameField.text?.removeLastSpace().lowercased()) {
                game.setValue(true, forKey: skipVal[index])
                alert(title: "Level Skip Notification".localized(), message: "level code " + skipVal[index] + " has been skipped", actionTitle: "thx")
                return true
            }
        }
        return false
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
        cont.body = "Now Come Back".localized()
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
    
    @IBAction func rickyLink(_ sender: Any) {
        ref.child("users/\(game.string(forKey: "key")!)/RickRolled").setValue("Y")
        openLink(st: "https://www.youtube.com/watch?v=oHg5SJYRHA0")
    }
    
    var customAlert = HintAlert()
    
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
            customAlert.showAlert(message: "1", viewController: self, hintButton: hint, toolbar: toolbar)
        }
    }
    
    func dismissAlert() {
        customAlert.dismissAlert()
    }
    
    @objc func doneClicked() {
        view.endEditing(true)
    }
    
}

