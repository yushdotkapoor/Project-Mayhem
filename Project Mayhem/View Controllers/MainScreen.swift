//
//  MainScreen.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 12/21/20.
//

import UIKit
import OneSignal
import Firebase

let ref = Database.database().reference()

class MainScreen: UIViewController {
    
    @IBOutlet weak var enter: CustomButton!
    @IBOutlet weak var logoCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var enterCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var tearDrop: CustomButton!
    @IBOutlet weak var dropTop: NSLayoutConstraint!
    @IBOutlet weak var lbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let c = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0)
        tearDrop.setupButton(color: c, pressColor: UIColor.black)
        enter.setupButton(color: c, pressColor: UIColor.black)
        
        if !videosCurrentlyDownloading && urlDict.isEmpty {
            if !game.bool(forKey: "useCellular") && game.bool(forKey: "onCellular")  {
                return
            }
            else {
                //uploadVideos()
                downloadVideos()
            }
        }
        Auth.auth().signInAnonymously()
        setupChat()
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
        
        let chatPgViewed = game.bool(forKey: "chatViewed")
        if chatPgViewed == false {
            
        let id = "\(key!) - \(admin)"
            game.setValue(id, forKey: "chatID")
            let array = ["recipients":[admin: "D", key: "Y"], "messages":["01": ["type":"text", "sender":"ADMIN", "date":"\(convertedDate)", "data":"Comments? Questions? Message me here!", "id":"01"]], "last":"\(convertedDate)"] as [String : Any]
            let data = ["key": key!, "threads":["\(id)":array], "token":"\(token ?? "")", "Q": "Y"] as [String : Any]
            
            ref.child("users/\(key!)").setValue(data)
            
            //create thread for admin
            ref.child("users/\(admin)/threads/\(id)").setValue(array)
        }
        
        ref.child("users/\(key!)/token").setValue(token)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let intro = game.bool(forKey: "introViewed")
        if intro == false {
            performSegue(withIdentifier: "mainToIntroduction", sender: self)
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

