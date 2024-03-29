//
//  MainScreen.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 12/21/20.
//

import UIKit
import Firebase
import CoreMotion

let ref = Database.database().reference()

class MainScreen: UIViewController {
    
    @IBOutlet weak var enter: CustomButton!
    @IBOutlet weak var logoCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var enterCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var tearDrop: CustomButton!
    @IBOutlet weak var dropTop: NSLayoutConstraint!
    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var logo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let c = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0)
        tearDrop.setupButton(color: c, pressColor: UIColor.black)
        enter.setupButton(color: c, pressColor: UIColor.black)
        enter.setTitle("Enter".localized().uppercased(), for: .normal)
        
        //COMMENT LINE BELOW BEFORE DEPLOYMENT
        //game.setValue(true, forKey: "isAdmin")
        
        setupChat()
        
        enter.addOutline(color: UIColor.gray.cgColor)
        tearDrop.addOutline(color: UIColor.gray.cgColor)
        
        lbl.add3DMotionShadow(maxOffset: 20, color: UIColor.white.cgColor, opacity: 0.5)
        enter.add3DMotionShadow(maxOffset: 20, color: UIColor.gray.cgColor, opacity: 0.5)
        tearDrop.add3DMotionShadow(maxOffset: 20, color: UIColor.gray.cgColor, opacity: 0.5)
        logo.add3DMotionShadow(maxOffset: 20, color: UIColor.gray.cgColor, opacity: 0.75)
    }
    
    
    
    func setupChat() {
        let key = UIDevice.current.identifierForVendor?.uuidString
        let admin = "ADMIN"
        let isAdmin = game.bool(forKey: "isAdmin")
        
        game.setValue("\(Messaging.messaging().fcmToken ?? "")", forKey: "token")
        let token = game.string(forKey: "token")
        
        
        if isAdmin {
            game.setValue(admin, forKey: "key")
        } else {
            game.setValue(key, forKey: "key")
            game.setValue(admin, forKey: "selectedUser")
        }
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss' 'Z"
        let convertedDate = dateFormatter.string(from: date)
        
        let chatPgViewed = game.bool(forKey: "chatPageViewed")
        if chatPgViewed == false {
            
            let id = "\(key!) - \(admin)"
            game.setValue(id, forKey: "chatID")
            let array = ["recipients":[admin: "N", key: "Y"], "messages":["01": ["type":"text", "sender":"ADMIN", "date":"\(convertedDate)", "data":"Comments? Questions? Message me here!".localized(), "id":"01"], "02": ["type":"text", "sender":"ADMIN", "date":"\(convertedDate)", "data":"Make sure you have push notifications enabled to get notifications for replies!".localized(), "id":"02"]], "last":"\(convertedDate)"] as [String : Any]
            let data = ["key": key!, "threads":["\(id)":array], "token":"\(token ?? "")", "Q": "Y"] as [String : Any]
            
            ref.child("users/\(key!)").setValue(data)
            
            //create thread for admin
            ref.child("users/\(admin)/threads/\(id)").setValue(array)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let intro = game.bool(forKey: "introViewed")
        if intro == false {
            performSegue(withIdentifier: "mainToIntroduction", sender: self)
        } else {
            let v = validateVideos()
            let vL = validateLocalizationFiles()
            let wt = weekTimer()
            
            
            if (!videosCurrentlyDownloading && !game.bool(forKey: "downloaded")) || wt {
                //uploadVideos()
                if !CheckInternet.Connection() {
                    alert(title: "Error".localized(), message: "Game content for this application needs to be downloaded! It seems that you are not connected to the Internet. Please connect to the Internet to continue.".localized(), actionTitle: "Okay".localized())
                } else if notAbleToUseCellular() {
                    alert(title: "Error".localized(), message: "Game content for this application needs to be downloaded! It seems that you have decided to not use cellular data to download content. Please find another Internet source or enable cellular data through the game settings.".localized(), actionTitle: "Okay".localized(), actions: {
                        self.performSegue(withIdentifier: "mainToCredits", sender: nil)
                    })
                } else {
                    if v.count != 0 {
                        downloadVideos(vidNames: v)
                    } else {
                        downloadVideos()
                    }
                }
            }
            
            if wt || vL.count != 0 {
                if notAbleToUseCellular() {} else {
                    downloadLocaleFiles()
                }
            }
        }
        
        lbl.fadeIn()
        
        UIView.animate(withDuration: 1.5, delay: 0.5, options: .curveEaseOut, animations: {
            self.enterCenterConstraint.constant -= self.view.bounds.width
            self.logoCenterConstraint.constant += self.view.bounds.width
            self.dropTop.constant -= self.view.bounds.height - self.tearDrop.bounds.origin.y + 30
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enterCenterConstraint.constant += view.bounds.width
        logoCenterConstraint.constant -= view.bounds.width
        dropTop.constant += view.bounds.height - tearDrop.bounds.origin.y + 30
        lbl.alpha = 0.0
    }
    
    @IBAction func Credits(_ sender: Any) {
        self.performSegue(withIdentifier: "mainToCredits", sender: nil)
    }
    
    @IBAction func enter(_ sender: Any) {
        self.performSegue(withIdentifier: "MainScreenToLevels", sender: nil)
    }
}

