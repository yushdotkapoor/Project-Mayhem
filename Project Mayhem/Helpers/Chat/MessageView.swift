//
//  MessageView.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 4/29/21.
//

import UIKit
import Firebase
import AudioToolbox

var rList:Dictionary<String, messageStruct> = [:]

struct messageStruct {
    var date:Double
    var notification:Bool
    var user:String
    var preview:String
    
    init() {
        user = ""
        date = 0.0
        notification = false
        preview = ""
    }
}


class MessageView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myTable: UITableView!
    
    var actualList:[String] = []
    var actualStruct:[messageStruct] = []
    
    let myKey = game.string(forKey: "key")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationListener()
        
        myTable.register(UITableViewCell.self, forCellReuseIdentifier: "shell")
        myTable.delegate = self
        myTable.dataSource = self
        myTable.estimatedRowHeight = 70
        
        if !CheckInternet.Connection() {
            self.alert(title: "Uh-Oh", message: "Please check your internet connection! You will not be able to send or recieve messages without internet.".localized(), actionTitle: "Okay".localized())
        }
        
        self.navigationController?.navigationBar.backgroundColor = UIColor.black
    }
    
    
    func getCurrentMessage(threadID:String) {
        ref.child("users/\(myKey!)/threads/\(threadID)/messages").queryLimited(toLast: 1).observe(.childAdded, with: { (snapshot) in
            let messages = snapshot.value as! NSDictionary
            let data = messages["data"] as? String
            let type = messages["type"] as? String
            let dat = messages["date"] as? String ?? ""
            if type == "text" {
                rList[threadID]?.preview = data ?? ""
            } else if type == "photo" {
                rList[threadID]?.preview = "Photo Message".localized()
            } else if type == "video" {
                rList[threadID]?.preview = "Video Message".localized()
            } else if type == "linkPreview" {
                rList[threadID]?.preview = "URL Message".localized()
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss' 'Z"
            let convertedDate = dateFormatter.date(from: dat)
            
            let newDate = convertedDate?.betterDate()
            rList[threadID]?.date = Double(newDate ?? "00")!
            self.sortReload()
        })
    }
    
    func checkToRender(g: NSEnumerator, messages: NSDictionary) -> Bool {
        for s in g {
            let dat = messages[s] as? [String:String]
            if dat?["sender"] != self.myKey && dat?["sender"] != nil {
                return true
            }
        }
        return false
    }
    
    func notificationListener() {
        ref.child("users/\(myKey!)/threads").observe(.childChanged, with: { (snapshot) in
            let value = snapshot.value as! NSDictionary
            let threadID = snapshot.key
            print("JAHH \(threadID)")
            let read = value["recipients"] as? [String:String] ?? [:]
            let messages = value["messages"] as! NSDictionary
            
            let g = messages.keyEnumerator()
            let render = self.checkToRender(g: g, messages: messages)

            if render {
                
                var count = 0
                
                for n in read {
                    let ke = n.key
                    let val = n.value
                    count += 1
                    
                    if ke == self.myKey && threadID != "0"  {
                        if isView(selfView: self, checkView: MessageView.self) {
                            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                        }
                        rList[threadID]?.notification = false;
                        if val == "Y" {
                            rList[threadID]?.notification = true;
                        }
                    }
                    
                    if count == 2 {
                        self.getCurrentMessage(threadID: threadID)
                        //self.sortReload()
                    }
                }
                
            }
        })
    }
    
    func initialize() {
        rList.removeAll()
        let key = game.string(forKey: "key")
        ref.child("users/\(key!)/threads").observe(.childAdded, with: { (snapshot) in
            let value = snapshot.value as! NSDictionary
            let threadID = snapshot.key
            let read = value["recipients"] as? [String:String] ?? [:]
            let messages = value["messages"] as! NSDictionary
            
            let g = messages.keyEnumerator()
            let render = self.checkToRender(g: g, messages: messages)

            if render {
                self.getCurrentMessage(threadID: threadID)
                
                var temp:messageStruct = messageStruct()
                
                if threadID != "0" {
                    let noteVal = read["\(key!)"]!
                    if noteVal == "Y" {
                        temp.notification = true;
                    }
                    for n in read {
                        let ke = n.key
                        if threadID != "0" {
                            if ke != key {
                                temp.user = ke
                            }
                        }
                    }
                    if temp.user == "" {
                        self.alert(title: "Error", message: "Something is wrong with the message structure and could potentially result in messages not being sent or recieved. ThreadID: \(threadID)", actionTitle: "OK")
                    }
                    rList[threadID] = temp
                }
            }
            
        })
    }
    
    func sortReload() {
        actualList.removeAll()
        actualStruct.removeAll()
        let sortedByValueDictionary = rList.sorted{$0.1.date > $1.1.date}
        
        for n in sortedByValueDictionary {
            actualList.append(n.key)
            actualStruct.append(n.value)
        }
        
        myTable.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (rList.count == 0) {
            initialize()
        }
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actualList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MessageViewCell
        
        let messStruct = actualStruct[indexPath.row]
        
        cell.label.text = messStruct.user
        cell.contentLbl.text = messStruct.preview
        
        if messStruct.notification {
            cell.img.image = UIImage(systemName: "circle.fill")
        }
        else {
            cell.img.image = nil
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isView(selfView: self, checkView: MessageView.self) {
        if !CheckInternet.Connection() {
            self.alert(title: "Error".localized(), message: "Please check your internet connection! You will not be able to send, recieve, or view messages without internet.".localized(), actionTitle: "Okay".localized())
            return
        }
        
        let thread = actualList[indexPath.row]
        let user = actualStruct[indexPath.row].user
        
        let vc = ChatViewController()
        vc.title = user
        game.setValue(user, forKey: "selectedUser")
        game.setValue(thread, forKey: "chatID")
        print("JAHH \(thread)")
        navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
}


