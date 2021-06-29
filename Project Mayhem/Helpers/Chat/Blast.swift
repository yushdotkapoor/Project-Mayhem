//
//  Blast.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 6/28/21.
//

import Foundation
import UIKit

class Blast: UIViewController {
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var submit: CustomButton!
    
    var otherUsers:[String:[String]] = [:]
    var allowedToSend = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        submit.setupButton()
        
        ref.child("users/ADMIN/threads").observeSingleEvent(of: .value, with: { (snapshot) in
            let thing = snapshot.value as? NSDictionary
            
            let f = thing?.keyEnumerator()
            for i in f! {
                let values = thing?[i] as? NSDictionary
                let r = values?["recipients"] as? [String:String]
                for n in r!.keys {
                    if n != "ADMIN" {
                        ref.child("users/\(n)/token").observeSingleEvent(of: .value, with: { (snapshot) in
                            let val = snapshot.value as? String ?? ""
                            self.otherUsers[n] = ["\(i)", val]
                            if self.otherUsers.count == thing?.count {
                                print(self.otherUsers)
                                print(self.otherUsers.count)
                                
                                self.allowedToSend = true
                            }
                        })
                    }
                }
                
            }
        })
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneClicked))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        textField.inputAccessoryView = toolBar
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(gesture:)))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        
    }
    
    @objc func viewTapped(gesture: UIGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func doneClicked() {
        view.endEditing(true)
    }
    
    
    @IBAction func send(_ sender: Any) {
        submit.isEnabled = false
        let t = textField.text
        if t == "" {
            reset()
            alert(title: "Error", message: "You have to add text!", actionTitle: "Okay")
            return
        }
        if !allowedToSend {
            reset()
            alert(title: "Error", message: "Please wait some more time until I have imported all the users", actionTitle: "Okay")
            return
        }
        
        let alertController = UIAlertController(title: "Please Confirm", message: "Are you sure you would like to send the following message to all users?\n\n\(t!)", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes".localized(), style: .default, handler: { action in
            self.send2(t: t!)
        })
        let no = UIAlertAction(title: "No".localized(), style: .cancel, handler: nil)
        
        alertController.addAction(yes)
        alertController.addAction(no)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func reset() {
        textField.text = ""
        submit.isEnabled = true
    }
    
    func send2(t: String) {
        
        let myKey = game.string(forKey: "key")!
        let sender = Sender(senderId: myKey, displayName: myKey)
        
        let now = Date()
        let newDate = now.betterDate()
        
        let message = Message(sender: sender, messageId: "\(newDate)-\(UUID().uuidString)", sentDate: Date(), kind: .text("\(t)"), data: t)
        
        let mess: [String: Any] = [
            "data": message.data,
            "id": message.messageId,
            "sender": message.sender.senderId,
            "type": "text",
            "date": "\(message.sentDate)"
        ]
        
        
        for (i, s) in otherUsers.keys.enumerated() {
            let otraKey = s
            let entry = otherUsers[s]
            let thread = entry?.first!
            let token = entry?.last! ?? ""
            
            
            
            for key in [myKey, otraKey] {
                ref.child("users/\(key)/threads/\(thread!)/messages/\(message.messageId)").setValue(mess)
            }
             
            ref.child("users/\(otraKey)/threads/\(thread!)/last").setValue("\(message.sentDate)")
            ref.child("users/\(otraKey)/threads/\(thread!)/recipients/\(otraKey)").setValue("Y")
            
            
            let titl = "\(messageFrom) Yush"
            let body = "\(message.data)"
            
            
            notification.sendPushNotification(to: token, title: titl, body: body)
            
            
            if i == otherUsers.count - 1 {
                reset()
                alert(title: "Success", message: "Message Sent!", actionTitle: "Okay")
            }
            
        }
    }
    
}
