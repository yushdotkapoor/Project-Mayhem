//
//  ChatViewController.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 4/29/21.
//

import UIKit
import Firebase
import MessageKit
import InputBarAccessoryView
import SDWebImage
import AVFoundation
import AVKit
import Photos

struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    var data: String
}

struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

struct Link: LinkItem {
    var text: String?
    var attributedText: NSAttributedString?
    var url: URL
    var title: String?
    var teaser: String
    var thumbnailImage: UIImage
}

var imagePicker: UIImagePickerController!

let notification = PushNotificationSender()


class ChatViewController: MessagesViewController {
    
    var otherUserToken = ""
    
    var currentUser = Sender(senderId: "self", displayName: "Sender")
    var otherUser = Sender(senderId: "other", displayName: "Recipient")
    
    var messages = [Message]()
    
    var selectedUser = ""
    var selectedThread = ""
    
    var myKey = game.string(forKey: "key")!
    
    let plzWaitPhoto = "https://firebasestorage.googleapis.com/v0/b/calculator-a6d61.appspot.com/o/please_wait%2FScreen%20Shot%202021-02-05%20at%2012.08.53%20AM.png?alt=media&token=4506ecfe-1837-499c-9473-8949c180e9cb"
    let plzWaitVideo = "https://firebasestorage.googleapis.com/v0/b/calculator-a6d61.appspot.com/o/please_wait%2Fplease_wait_vid.mov?alt=media&token=0b5f6f41-743a-47c8-b0b7-602a3eeb7a5b"
    
    var removalIndex:[Int] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        game.setValue(true, forKey: "chatPageViewed")
        
        selectedUser = game.string(forKey: "selectedUser")!
        selectedThread = game.string(forKey: "chatID")!
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        currentUser.displayName = myKey
        otherUser.displayName = selectedUser
        currentUser.senderId = myKey
        otherUser.senderId = selectedUser
        removalIndex.removeAll()
        
        self.navigationController?.navigationBar.backgroundColor = UIColor.black
        
        ref.child("users/\(selectedUser)/token").observeSingleEvent(of: .value, with: { (snapshot) in
            let val = snapshot.value as? String ?? ""
            self.otherUserToken = val
        })
        
        
        removeAvatar()
        listen()
        
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        self.showMessageTimestampOnSwipeLeft = true
        
        messagesCollectionView.contentInset.top += 10
        
        scrollsToLastItemOnKeyboardBeginsEditing = true
        
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.onTouchUpInside { [weak self] _ in
            self?.presentInputActionSheet()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
        
        let saveItem = UIMenuItem(title: "Save".localized(), action: #selector(MessageCollectionViewCell.saveMedia(_:)))
        let shareItem = UIMenuItem(title: "Share".localized(), action: #selector(MessageCollectionViewCell.shareMedia(_:)))
        UIMenuController.shared.menuItems = [saveItem, shareItem]
        
        messagesCollectionView.backgroundColor = .black
        view.backgroundColor = .clear
    }
    
    @objc private func presentInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Media".localized(),
                                            message: "What would you like to attach?".localized(),
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera".localized(), style: .default) { action in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = false
                imagePicker.mediaTypes = ["public.movie", "public.image"]
                imagePicker.videoQuality = .typeHigh
                imagePicker.showsCameraControls = true
                
                
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                self.alert(title: "Oh no!".localized(), message: "It seems that this device cannot access the camera".localized(), actionTitle: "Okay".localized())
            }
        })
        actionSheet.addAction(UIAlertAction(title: "Photo Library".localized(), style: .default) { action in
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            imagePicker.mediaTypes = ["public.movie", "public.image"]
            imagePicker.videoQuality = .typeHigh
            
            
            self.present(imagePicker, animated: true, completion: nil)
        })
        actionSheet.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil))
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(actionSheet, animated: true)
    }
    
    
    func listen() {
        ref.child("users/\(myKey)/threads/\(selectedThread)/messages").observe(.childAdded, with: { (snapshot) in
            if isView(selfView: self, checkView: ChatViewController.self) {
                let thing = snapshot.value as? [String:String] ?? ["":""]
                self.load(thing: thing)
            }
        })
        
        ref.child("users/\(myKey)/threads/\(selectedThread)/messages").observe(.childChanged, with: { (snapshot) in
            if isView(selfView: self, checkView: ChatViewController.self) {
                let thing = snapshot.value as? [String:String] ?? ["":""]
                
                var sender = self.otherUser
                
                if self.currentUser.senderId == thing["sender"] ?? "" {
                    sender = self.currentUser
                }
                
                let data = thing["data"] ?? ""
                let date = thing["date"] ?? ""
                let type = thing["type"] ?? ""
                let id = thing["id"] ?? ""
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss' 'Z"
                let convertedDate = dateFormatter.date(from: date)
                
                switch type {
                case "photo":
                    guard let imageUrl = URL(string: data),
                          let placeholder = UIImage(systemName: "plus") else {
                        return
                    }
                    
                    let media = Media(url: imageUrl,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: CGSize(width: 300, height: 300))
                    
                    for i in self.removalIndex {
                        let messID = self.messages[i].messageId
                        if messID == id {
                            self.messages[i] = Message(sender: sender, messageId: id, sentDate: convertedDate ?? Date(), kind: .photo(media), data: "\(imageUrl)")
                            self.reload(scroll: true)
                        }
                    }
                    break
                    
                case "video":
                    guard let imageUrl = URL(string: data),
                          let placeholder = UIImage(systemName: "plus") else {
                        return
                    }
                    
                    let media = Media(url: imageUrl,
                                      image: self.videoPreviewImage(url: imageUrl),
                                      placeholderImage: placeholder,
                                      size: CGSize(width: 300, height: 300))
                    
                    for i in self.removalIndex {
                        let messID = self.messages[i].messageId
                        if messID == id {
                            self.messages[i] = Message(sender: sender, messageId: id, sentDate: convertedDate ?? Date(), kind: .video(media), data: "\(imageUrl)")
                            self.reload(scroll: true)
                        }
                    }
                    
                    break
                default:
                    break
                    
                }
                
            }
        })
    }
    
    func delayLoad(count: Int, imgURL: URL, message: Message, kind: String) {
        let placeholder = UIImage(systemName: "plus")
        var currentMessage = message
        var media = Media(url: imgURL,
                          image: nil,
                          placeholderImage: placeholder!,
                          size: CGSize(width: 300, height: 300))
        
        switch kind {
        case "photo":
            currentMessage.kind = .photo(media)
            break
        case "video":
            media.image = videoPreviewImage(url: imgURL)
            currentMessage.kind = .video(media)
            break
        default:
            break
        }
        
        self.messages[count] = currentMessage
        self.reload(scroll: false)
    }
    
    func load(thing: [String:String]) {
        var sender = self.otherUser
        
        if self.currentUser.senderId == thing["sender"] ?? "" {
            sender = self.currentUser
        }
        
        let data = thing["data"] ?? ""
        let date = thing["date"] ?? ""
        let type = thing["type"] ?? ""
        let id = thing["id"] ?? ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss' 'Z"
        let convertedDate = dateFormatter.date(from: date)
        
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            let generator2 = UIImpactFeedbackGenerator(style: .heavy)
            
            // if user sends message, vibrate lightly
            if sender.senderId == myKey {
                generator.impactOccurred()
            }
            else {
                //if other sends message, vibrate medium
                generator2.impactOccurred()
            }
        }
        
        switch type {
        case "text":
            self.messages.append(Message(sender: sender, messageId: id, sentDate: convertedDate ?? Date(), kind: .text("\(data)"), data: data))
            self.reload(scroll: true)
            break
        case "photo":
            guard let placeHolder = UIImage(named: "download") else {
                return
            }
            
            let media = Media(url: nil,
                              image: nil,
                              placeholderImage: placeHolder,
                              size: CGSize(width: 300, height: 300))
            
            let mess = Message(sender: sender, messageId: id, sentDate: convertedDate ?? Date(), kind: .photo(media), data: data)
            
            
            if data == plzWaitPhoto {
                removalIndex.append(messages.count)
            }
            
            self.messages.append(mess)
            
            self.reload(scroll: true)
            break
            
        case "video":
            guard let placeHolder = UIImage(named: "download") else {
                return
            }
            
            let media = Media(url: nil,
                              image: nil,
                              placeholderImage: placeHolder,
                              size: CGSize(width: 300, height: 300))
            
            let mess = Message(sender: sender, messageId: id, sentDate: convertedDate ?? Date(), kind: .video(media), data: data)
            
            if data == plzWaitVideo {
                removalIndex.append(messages.count)
            }
            
            self.messages.append(mess)
            
            self.reload(scroll: true)
            break
            
            
        case "linkPreview":
            let data2 = data.replacingOccurrences(of: "https://", with: "")
            let data3 = data2.replacingOccurrences(of: "http://", with: "")
            let data4 = data3.replacingOccurrences(of: "www.", with: "")
            let url = "https://www.google.com/s2/favicons?domain=www.\(data4)"
            
            let link = Link(text: "", url: URL(string: "https://\(data4)")!, title: getTitleOfURL(webpage: data4), teaser: "", thumbnailImage: load(url: url))
            
            self.messages.append(Message(sender: sender, messageId: id, sentDate: convertedDate ?? Date(), kind: .linkPreview(link), data: data))
            self.reload(scroll: true)
            break
        default:
            break
        }
    }
    
    func getTitleOfURL(webpage: String) -> String {
        if let url = URL(string: "https://www.\(webpage)") {
            do {
                let contents = try String(contentsOf: url)
                if contents.contains("<title>") {
                    let range = contents.endIndex(of: "<title>")
                    let range2 = contents.index(of: "</title>")
                    return String(contents[range!..<range2!])
                } else {
                    return "\(url)"
                }
            } catch {
                // contents could not be loaded
                return "\(url)"
            }
        } else {
            // the URL was bad!
            return "\(webpage)"
        }
    }
    
    func load(url: String) -> UIImage {
        let backup = UIImage(systemName: "safari")!
        if let url2 = URL(string: url) {
            if let data = try? Data(contentsOf: url2) {
                if let image = UIImage(data: data) {
                    return image
                }
                else {
                    return backup
                }
            }
            else {
                return backup
            }
        }
        else {
            return backup
        }
    }
    
    func videoPreviewImage(url: URL) -> UIImage? {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        if let cgImage = try? generator.copyCGImage(at: CMTime(seconds: 0.0, preferredTimescale: 60), actualTime: nil) {
            return UIImage(cgImage: cgImage)
        }
        else {
            return nil
        }
    }
    
    func removeAvatar() {
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
            layout.photoMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.photoMessageSizeCalculator.incomingAvatarSize = .zero
            layout.videoMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.videoMessageSizeCalculator.incomingAvatarSize = .zero
            layout.attributedTextMessageSizeCalculator.incomingAvatarSize = .zero
            layout.attributedTextMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.attributedTextMessageSizeCalculator.avatarLeadingTrailingPadding = .zero
            layout.linkPreviewMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.linkPreviewMessageSizeCalculator.incomingAvatarSize = .zero
            layout.setMessageOutgoingMessagePadding(UIEdgeInsets(top: -7, left: 50, bottom: 0, right: 0))
            layout.setMessageIncomingMessagePadding(UIEdgeInsets(top: -7, left: 0, bottom: 0, right: 50))
        }
    }
    
    func reload(scroll: Bool) {
        ref.child("users/\(myKey)/threads/\(selectedThread)/recipients/\(myKey)").setValue("N")
        
        self.messagesCollectionView.reloadData()
        
        if scroll {
            self.messagesCollectionView.scrollToLastItem(animated: true)
        }
    }
    
    func hasLink(input: String, type: String) -> Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        
        let matches = detector.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
        
        let count = matches.count
        
        if count == 0 || type == "photo" || type == "video" {
            return false
        }
        else {
            var lowerBound = input.firstIndex(of: input.first!)!
            var inputs:[String:[Bool:String]] = [:]
            for match in matches {
                let range = Range(match.range, in: input)!
                
                let before = input[lowerBound..<range.lowerBound]
                let link = input[range]
                
                if !before.isEmpty {
                    inputs[String(before)] = [false:"before"]
                }
                
                
                inputs[String(link)] = [true:"none"]
                lowerBound = range.upperBound
                
                
                if match.isEqual(matches.last) {
                    let after = input[lowerBound...]
                    if !after.isEmpty {
                        inputs[String(after)] = [false:"after"]
                    }
                }
            }
            let now = Date()
            for t in inputs {
                let s = t.key
                let b = t.value.first!.key
                let v = t.value.first!.value
                
                if b {
                    let newDate = now.betterDate()
                    let link = Link(text: "", url: URL(string: "https://\(s)")!, title: getTitleOfURL(webpage: s), teaser: "", thumbnailImage: load(url: s))
                    
                    let message = Message(sender: currentUser, messageId: "\(newDate)-\(UUID().uuidString)", sentDate: Date(), kind: .linkPreview(link), data: s)
                    
                    
                    let mess: [String: Any] = [
                        "data": message.data,
                        "id": message.messageId,
                        "sender": message.sender.senderId,
                        "type": "linkPreview",
                        "date": "\(message.sentDate)"
                    ]
                    
                    let otraKey = self.otherUser.senderId
                    
                    let both = [myKey, otraKey]
                    
                    for key in both {
                        ref.child("users/\(key)/threads/\(selectedThread)/messages/\(message.messageId)").setValue(mess)
                        ref.child("users/\(key)/threads/\(selectedThread)/last").setValue("\(message.sentDate)")
                    }
                    
                    ref.child("users/\(otraKey)/threads/\(selectedThread)/recipients/\(otraKey)").setValue("Y")
                    
                    var titl = "\(messageFrom) Yush"
                    let body = "URL message".localized()
                    
                    if otraKey == "ADMIN" {
                        //titl = myKey
                        titl = "Someone needs your fucking help, bitch"
                    }
                    
                    
                    notification.sendPushNotification(to: self.otherUserToken, title: titl, body: body)
                    
                    
                    self.messagesCollectionView.scrollToLastItem()
                }
                else {
                    if v == "before" {
                        let date = now.addingTimeInterval(-0.1)
                        let newDate = date.betterDate()
                        
                        let message = Message(sender: currentUser, messageId: "\(newDate)-\(UUID().uuidString)", sentDate: Date(), kind: .text("\(s)"), data: s)
                        save(message)
                    }
                    else {
                        let date = now.addingTimeInterval(0.1)
                        let newDate = date.betterDate()
                        
                        let message = Message(sender: currentUser, messageId: "\(newDate)-\(UUID().uuidString)", sentDate: Date(), kind: .text("\(s)"), data: s)
                        save(message)
                    }
                }
            }
            return true
        }
    }
    
    private func save(_ message: Message) {
        save(message, sendNotification: true)
    }
    
    private func save(_ message: Message, sendNotification: Bool) {
        
        let text = message.data
        var offset = 0
        var findParentheses = false
        let kind = "\(message.kind)"
        
        while !findParentheses {
            if kind.substring(with: offset..<(offset + 1)) == "(" {
                findParentheses = true
            }
            else {
                offset += 1
            }
        }
        
        let sub = kind.prefix(offset)
        
        if !hasLink(input: text, type: String(sub)) {
            
            let mess: [String: Any] = [
                "data": message.data,
                "id": message.messageId,
                "sender": message.sender.senderId,
                "type": sub,
                "date": "\(message.sentDate)"
            ]
            
            let otraKey = self.otherUser.senderId
            
            let both = [myKey, otraKey]
            
            for key in both {
                ref.child("users/\(key)/threads/\(selectedThread)/messages/\(message.messageId)").setValue(mess)
                ref.child("users/\(key)/threads/\(selectedThread)/last").setValue("\(message.sentDate)")
            }
            
            ref.child("users/\(otraKey)/threads/\(selectedThread)/recipients/\(otraKey)").setValue("Y")
            
            var titl = "\(messageFrom) Yush"
            var body = "Your calculation is complete"
            
            
            if sub == "photo"{
                body = "Photo Message".localized()
            }
            else if sub == "video" {
                body = "Video Message".localized()
            }
            else if sub == "linkPreview" {
                body = "URL".localized()
            }
            else {
                body = "\(message.data)"
            }
            
            if otraKey == "ADMIN" {
                //titl = myKey
                titl = "Someone needs your fucking help, bitch"
            }
            if sendNotification {
                notification.sendPushNotification(to: self.otherUserToken, title: titl, body: body)
            }
            
            self.messagesCollectionView.scrollToLastItem()
            
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if action == #selector(MessageCollectionViewCell.saveMedia(_:)) {
            switch messages[indexPath.section].kind {
            case .photo(let media), .video(let media):
                if media.url == nil {
                    return false
                }
                else {
                    return true
                }
            default:
                return super.collectionView(collectionView, canPerformAction: action, forItemAt: indexPath, withSender: sender)
            }
        } else if action == #selector(MessageCollectionViewCell.shareMedia(_:)) {
            switch messages[indexPath.section].kind {
            case .photo(let media):
                if media.url == nil {
                    return false
                }
                else {
                    return true
                }
            default:
                return super.collectionView(collectionView, canPerformAction: action, forItemAt: indexPath, withSender: sender)
            }
        }
        else {
            return super.collectionView(collectionView, canPerformAction: action, forItemAt: indexPath, withSender: sender)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        if action == #selector(MessageCollectionViewCell.saveMedia(_:)) {
            switch messages[indexPath.section].kind {
            case .photo(let media):
                savePhoto(url: "\(media.url!)")
                break
            case .video(let media):
                DispatchQueue.global(qos: .background).async {
                    if let url = media.url, let urlData = NSData(contentsOf: url) {
                        let galleryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                        let filePath="\(galleryPath)/nameX.mp4"
                        DispatchQueue.main.async {
                            urlData.write(toFile: filePath, atomically: true)
                            PHPhotoLibrary.shared().performChanges({
                                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL:
                                                                                        URL(fileURLWithPath: filePath))
                            }){
                                success, error in
                                if success {
                                    print("Succesfully Saved")
                                } else {
                                    let l1 = "Could not save video:".localized()
                                    self.alert(title: "Error".localized(), message: "\(l1) \(error!.localizedDescription)", actionTitle: "Okay".localized())
                                }
                            }
                        }
                    }
                }
                break
            default:
                break
            }
        } else if action == #selector(MessageCollectionViewCell.shareMedia(_:)) {
            switch messages[indexPath.section].kind {
            case .photo(let media):
                // image to share
                let image = load(url: "\(media.url!)")
                
                // set up activity view controller
                let imageToShare = [ image ]
                let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
                
                // present the view controller
                self.present(activityViewController, animated: true, completion: nil)
                
                break
            default:
                break
            }
        }
        else {
            super.collectionView(collectionView, performAction: action, forItemAt: indexPath, withSender: sender)
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
        }.resume()
    }
    
    func savePhoto(url: String) {
        guard let yourImageURL = URL(string: url) else { return }
        
        getDataFromUrl(url: yourImageURL) { (data, response, error) in
            
            guard let data = data, let imageFromData = UIImage(data: data) else { return }
            
            DispatchQueue.main.async() {
                UIImageWriteToSavedPhotosAlbum(imageFromData, nil, nil, nil)
            }
        }
    }
}

extension Date {
    func betterDate() -> String {
        return "\(Int(self.timeIntervalSince1970 * 1000))"
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        let newDate = Date().betterDate()
        
        let message = Message(sender: currentUser, messageId: "\(newDate)-\(UUID().uuidString)", sentDate: Date(), kind: .text("\(text)"), data: text)
        
        save(message)
        
        inputBar.inputTextView.text = ""
        messagesCollectionView.scrollToLastItem(animated: true)
    }
}


extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        
        let placeholder = UIImage(systemName: "plus")
        let date = Date()
        let newDate = date.betterDate()
        
        var media = Media(url: URL(string: plzWaitPhoto),
                          image: nil,
                          placeholderImage: placeholder!,
                          size: .zero)
        
        let mID = "\(date)-\(UUID().uuidString)"
        
        let messageID = "\(newDate)-\(UUID().uuidString)"
        
        if let image = info[.originalImage] as? UIImage, let imageData =  image.pngData() {
            let fileName = "photo_message_" + mID.replacingOccurrences(of: " ", with: "——") + ".png"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                let tempMessage = Message(sender: self.currentUser,
                                          messageId: messageID,
                                          sentDate: date,
                                          kind: .photo(media),
                                          data: "\(self.plzWaitPhoto)")
                
                self.save(tempMessage)
                self.messagesCollectionView.scrollToLastItem(animated: true)
                
            }
            
            StorageManager.shared.uploadMessagePhoto(with: imageData, fileName: fileName, completion: { [weak self] result in
                
                switch result {
                case .success(let urlString):
                    // Ready to send message
                    print("Uploaded Message Photo: \(urlString)")
                    
                    guard let url = URL(string: urlString) else {
                        return
                    }
                    
                    media.url = url
                    
                    let message = Message(sender: self!.currentUser,
                                          messageId: messageID,
                                          sentDate: date,
                                          kind: .photo(media),
                                          data: "\(urlString)")
                    
                    self?.save(message, sendNotification: false)
                    self?.messagesCollectionView.scrollToLastItem(animated: true)
                    
                    
                case .failure(let error):
                    print("message photo upload error: \(error)")
                    self?.alert(title: "Error".localized(), message: "The photo was unable to be sent. The problem could be your network connection.".localized(), actionTitle: "Okay".localized())
                }
            })
        }
        else if let videoUrl = info[.mediaURL] as? URL {
            let vURL = createTemporaryURLforVideoFile(url: videoUrl as NSURL)
            let fileName = "photo_message_" + mID.replacingOccurrences(of: " ", with: "—") + ".mov"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                media.url = URL(string: self.plzWaitVideo)
                let tempMessage = Message(sender: self.currentUser,
                                          messageId: messageID,
                                          sentDate: date,
                                          kind: .video(media),
                                          data: self.plzWaitVideo)
                
                self.save(tempMessage)
            }
            
            // Upload Video
            
            StorageManager.shared.uploadMessageVideo(with: vURL as URL, fileName: fileName, completion: { [weak self] result in
                
                switch result {
                case .success(let urlString):
                    // Ready to send message
                    print("Uploaded Message Video: \(urlString)")
                    
                    guard let url = URL(string: urlString) else {
                        return
                    }
                    
                    media.url = url
                    
                    let message = Message(sender: self!.currentUser,
                                          messageId: messageID,
                                          sentDate: date,
                                          kind: .video(media),
                                          data: urlString)
                    
                    self?.save(message, sendNotification: false)
                    self?.messagesCollectionView.scrollToLastItem(animated: true)
                    
                case .failure(let error):
                    print("message video upload error: \(error)")
                    self?.alert(title: "Error".localized(), message: "The video was unable to be sent. The problem could be your network connection.".localized(), actionTitle: "Okay".localized())
                }
            })
        }
    }
    
    func createTemporaryURLforVideoFile(url: NSURL) -> NSURL {
        /// Create the temporary directory.
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        /// create a temporary file for us to copy the video to.
        let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(url.lastPathComponent ?? "")
        /// Attempt the copy.
        do {
            try FileManager().copyItem(at: url.absoluteURL!, to: temporaryFileURL)
        } catch {
            print("There was an error copying the video file to the temporary location.")
        }

        return temporaryFileURL as NSURL
    }
}


extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        if isFromCurrentSender(message: message) {
            return UIColor(named: "MayhemBlue")!
        }
        else {
            return UIColor(named: "MayhemGray")!
        }
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return UIColor.white
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else {
            return
        }
        
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            imageView.sd_setImage(with: imageUrl, completed: nil)
            break
        default:
            break
        }
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath,
                      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let futureIndex = indexPath.section + 1
        
        if futureIndex < messages.count {
            if isFromCurrentSender(message: message) {
                if isFromCurrentSender(message: messages[futureIndex]) {
                    return .bubble
                }
                else {
                    return .bubbleTail(.bottomRight, .curved)
                }
            }
            else {
                if isFromCurrentSender(message: messages[futureIndex]) {
                    return .bubbleTail(.bottomLeft, .curved)
                }
                else {
                    return .bubble
                }
            }
        }
        else {
            if isFromCurrentSender(message: message) {
                return .bubbleTail(.bottomRight, .curved)
            }
            else {
                return .bubbleTail(.bottomLeft, .curved)
            }
        }
    }
    
    func messageTimestampLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let sentDate = message.sentDate
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/YYYY h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        let dateString = formatter.string(from: sentDate)
        let timeLabelFont: UIFont = .boldSystemFont(ofSize: 10)
        let timeLabelColor: UIColor
        timeLabelColor = .systemGray
        return NSAttributedString(string: dateString, attributes: [.foregroundColor: timeLabelColor, .font: timeLabelFont])
    }
}

extension ChatViewController: MessageCellDelegate {
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        
        let message = messages[indexPath.section]
        
        switch message.kind {
        case .photo(let media):
            if media.url == nil {
                let ct = indexPath.section
                
                let imgURL = URL(string: message.data)!
                let kind = "photo"
                
                self.delayLoad(count: ct, imgURL: imgURL, message: message , kind: kind)
            }
            else {
                print("loaded")
                
                guard let imageUrl = media.url else {
                    return
                }
                
                let vc = PhotoViewerViewController(with: imageUrl)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            break
            
        case .video(let media):
            if media.url == nil {
                let ct = indexPath.section
                let imgURL = URL(string: message.data)!
                let kind = "video"
                
                self.delayLoad(count: ct, imgURL: imgURL, message: message , kind: kind)
            }
            else {
                guard let videoUrl = media.url else {
                    return
                }
                let vc = AVPlayerViewController()
                vc.player = AVPlayer(url: videoUrl)
                present(vc, animated: true)
                break
            }
        default:
            break
        }
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        
        let message = messages[indexPath.section]
        
        switch message.kind {
        case .linkPreview(let link):
            UIApplication.shared.open(link.url)
            break
        default:
            break
        }
    }
    
}

extension MessageCollectionViewCell {
    @objc func saveMedia(_ sender: Any?) {
        if let collectionView = self.superview as? UICollectionView {
            // Get indexPath
            if let indexPath = collectionView.indexPath(for: self) {
                collectionView.delegate?.collectionView?(collectionView, performAction: #selector(MessageCollectionViewCell.saveMedia(_:)), forItemAt: indexPath, withSender: sender)
            }
        }
    }
    
    @objc func shareMedia(_ sender: Any?) {
        if let collectionView = self.superview as? UICollectionView {
            // Get indexPath
            if let indexPath = collectionView.indexPath(for: self) {
                collectionView.delegate?.collectionView?(collectionView, performAction: #selector(MessageCollectionViewCell.shareMedia(_:)), forItemAt: indexPath, withSender: sender)
            }
        }
    }
}
