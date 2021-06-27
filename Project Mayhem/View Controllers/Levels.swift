//
//  Levels.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 12/22/20.
//

import UIKit
import Speech
import AVFoundation
import StoreKit
import Firebase


let game = UserDefaults.standard

class Levels: UIViewController {
    
    @IBOutlet weak var chap15: CustomButtonOutline!
    @IBOutlet weak var chap14: CustomButtonOutline!
    @IBOutlet weak var chap13: CustomButtonOutline!
    @IBOutlet weak var chap12: CustomButtonOutline!
    @IBOutlet weak var chap11: CustomButtonOutline!
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
    @IBOutlet weak var scrollView: UIScrollView!
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
    @IBOutlet weak var chap11Center: NSLayoutConstraint!
    @IBOutlet weak var chap12Center: NSLayoutConstraint!
    @IBOutlet weak var chap13Center: NSLayoutConstraint!
    @IBOutlet weak var chap14Center: NSLayoutConstraint!
    @IBOutlet weak var chap15Center: NSLayoutConstraint!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var messagesIcon: MIBadgeButton!
    
    
    var del = 0.5
    
    var notificationTimer:Timer?
    
    var hasNotification:notificationInfo = notificationInfo()
    
    class notificationInfo {
        var shows:Bool
        var arr:[String]
        
        init() {
            shows = false
            arr = []
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        del = 0.5
        
        //reset()
        //loadAll()
        MusicPlayer.shared.volumeControl(factor: 0.4)
        
        if (!videosCurrentlyDownloading && !game.bool(forKey: "downloaded")) || weekTimer() {
            //uploadVideos()
            downloadVideos()
        }
        
        notificationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.checkNotification()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.backTapped(gesture:)))
        logo.addGestureRecognizer(tapGesture)
        logo.isUserInteractionEnabled = true
        
        notificationListener(type: .childAdded)
        notificationListener(type: .childChanged)
        
        messagesIcon.setImage(UIImage(systemName: "message.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
        messagesIcon.badgeEdgeInsets = UIEdgeInsets(top: 13, left: 0, bottom: 0, right: 0)
        messagesIcon.badge = ""
        removeNotification()
        
        ref.child("users/\(game.string(forKey: "key")!)/token").setValue(game.string(forKey: "token"))
    }
    
    func notificationListener(type: DataEventType) {
        let key = game.string(forKey: "key")
        var count = 0
        
        ref.child("users/\(key!)/threads").observe(type, with: { (snapshot) in
            let value = snapshot.value as! NSDictionary
            let threadID = snapshot.key
            let read = value["recipients"] as? [String:String] ?? [:]
            for n in read {
                let ke = n.key
                let val = n.value
                
                count += 1
                
                if ke == key! && threadID != "0"  {
                    if isView(selfView: self, checkView: MessageView.self) {
                        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    }
                    self.hasNotification.arr.append(val)
                }
            }
        })
    }
    
    @objc func checkNotification() {
        if hasNotification.shows {
            UIApplication.shared.applicationIconBadgeNumber = 1
        } else {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        
        if hasNotification.arr.isNotEmpty {
            if hasNotification.arr.contains("Y") && !hasNotification.shows {
                addNotification()
            } else if hasNotification.shows && !hasNotification.arr.contains("Y") {
                removeNotification()
            }
        }
    }
    
    func addNotification() {
        hasNotification.arr = []
        hasNotification.shows = true
        messagesIcon.tintColor = .white
        messagesIcon.alpha = 1
        messagesIcon.reactivateBadge()
    }
    
    func removeNotification() {
        hasNotification.arr = []
        hasNotification.shows = false
        messagesIcon.tintColor = UIColor(named: "MayhemGray")
        messagesIcon.alpha = 0.5
        messagesIcon.removeBadge()
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        notificationTimer?.invalidate()
    }
    
    @objc func backTapped(gesture: UIGestureRecognizer) {
        performSegue(withIdentifier: "levelsToMain", sender: nil)
    }
    
    func reset() {
        let reset = getData(string: "Bypass") as! [String]
        
        for r in reset {
            game.setValue(false, forKey: r)
        }
        game.setValue(false, forKey: "postApocalypse")
        game.setValue(false, forKey: "apocalypse")
    }
    
    func loadAll() {
        let reset = getData(string: "Bypass") as! [String]
        
        for r in reset {
            game.setValue(true, forKey: r)
        }
        game.setValue(true, forKey: "postApocalypse")
        game.setValue(false, forKey: "apocalypse")
    }
    
    func getData(string: String) -> [Any] {
        if string == "Center" {
            return [chap1Center, chap2Center, chap3Center, chap4Center, chap5Center, chap6Center, chap7Center, chap8Center, chap9Center, chap10Center, chap11Center, chap12Center, chap13Center, chap14Center, chap15Center] as [NSLayoutConstraint]
        }
        else if string == "String" {
            return ["chap1", "chap2", "chap3", "chap4", "chap5", "chap6", "chap7", "chap8", "chap9", "chap10", "chap11", "chap12", "chap13", "chap14", "chap15"] as [String]
        }
        else if string == "Bypass" {
            return ["chap1IntroWatched", "chap1", "chap2", "chap3", "chap4", "chap5", "chap6","chap7IntroWatched", "chap7", "chap7OutroWatched","chap8", "chap9", "chap10", "chap11", "chap12", "chap13", "chap14", "preChap15", "subPostChapter15Watched", "chap15"] as [String]
        }
        else {
            return [chap1, chap2, chap3, chap4, chap5, chap6, chap7, chap8, chap9, chap10, chap11, chap12, chap13, chap14, chap15] as [CustomButtonOutline]
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
        
        arrayButtons[0].setupButton(color: UIColor.white)
        
        for chapter in array {
            let completion = game.bool(forKey: chapter)
            if completion {
                arrayButtons[i].setupButton(color: UIColor.green)
                arrayButtons[i].isEnabled = true
                if arrayButtons.count != i + 1 {
                    arrayButtons[i+1].setupButton(color: UIColor.white)
                    arrayButtons[i+1].isEnabled = true
                }
            }
            else {
                //scroll down to newest level
            }
            i += 1
        }
    }
    
    @objc func visionTrailer() {
        game.setValue(false, forKey: "apocalypse")
        game.setValue(true, forKey: "postApocalypse")
        performSegue(withIdentifier: "LevelsToProjectVenom", sender: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let apocalypse = game.bool(forKey: "apocalypse")
        let postApocalypse = game.bool(forKey: "postApocalypse")
        
        if apocalypse {
            let button = CustomButtonOutline(frame: CGRect(x: -view.bounds.width, y: 200, width: 300, height: 40))
            button.setupButton(color: UIColor.white)
            button.setTitle("PROJECT VENOM", for: .normal)
            button.setTitleColor(.link, for: .normal)
            button.addTarget(self, action: #selector(visionTrailer), for: .touchUpInside)
            button.titleLabel?.font = UIFont(name: "Adonay", size: 25.0)
            view.addSubview(button)
            UIView.animate(withDuration: 0.5, delay: 1) {
                button.frame.origin.x = (UIScreen.main.bounds.width - 300) / 2
                self.view.layoutIfNeeded()
            }
            
        }
        else {
            if postApocalypse {
                let complete = game.bool(forKey: "projectVenom")
                let button = CustomButtonOutline(frame: CGRect(x: -view.bounds.width, y: chap15.frame.origin.y + 60, width: 300, height: 40))
                if complete {
                    button.setupButton(color: UIColor.green)
                }
                else {
                    button.setupButton()
                }
                button.setTitle("PROJECT VENOM", for: .normal)
                button.setTitleColor(.link, for: .normal)
                button.addTarget(self, action: #selector(visionTrailer), for: .touchUpInside)
                button.titleLabel?.font = UIFont(name: "Adonay", size: 25.0)
                scrollView.addSubview(button)
                UIView.animate(withDuration: 0.5, delay: 1.2) {
                    button.frame.origin.x = (UIScreen.main.bounds.width - 300) / 2
                    self.view.layoutIfNeeded()
                }
            }
            colorize()
            let centers = getData(string: "Center")
            
            for button in centers {
                animate(constraint: button as! NSLayoutConstraint)
            }
        }
        
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
            self.logoWidth.constant *= 0.25
            self.view.layoutIfNeeded()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let centers = getData(string: "Center")
        
        for button in centers {
            let b = button as! NSLayoutConstraint
            b.constant -= view.bounds.width
        }
        
    }
    
    
    @IBAction func chapter5PurchaseBlock(_ sender: Any) {
        performSegue(withIdentifier: "levelsToChap5", sender: nil)
    }
    
    
    
    func animate(constraint: NSLayoutConstraint) {
        UIView.animate(withDuration: 0.5, delay: del, options: .curveEaseOut, animations: {
            constraint.constant += self.view.bounds.width
            self.view.layoutIfNeeded()
        })
        del += 0.05
    }
    
    
    @IBAction func chat(_ sender: Any) {
        rList.removeAll()
        
        var selectNavigation = "MessagesNavigation"
        
        if (game.string(forKey: "key") == "ADMIN") {
            selectNavigation = "AdminNavigation"
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: selectNavigation)
        self.present(controller, animated: true, completion: nil)
        
    }
    
    
}



