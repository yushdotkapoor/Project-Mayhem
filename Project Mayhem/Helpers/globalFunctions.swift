//
//  globalFunctions.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 2/18/21.
//

import UIKit
import AVKit
import CallKit
import CloudKit
import StoreKit

var video:VideoPlayer?
var godThread:UIViewController?
var ripplingView:UIView?
var talk:speechModule?
var wordToSearch:[String]?
var funcToPass:(() -> Void)?
var tomorrow = UIFont(name: "Tomorrow", size: 20)
var videosCurrentlyDownloading = false
var IAPs:[SKProduct]?
var receipt: Receipt?
let database = CKContainer.default().publicCloudDatabase
let vidArr = ["Chap1Intro", "lvl7Intro", "lvl7Outro", "subPostChapter15", "ProjectVenomTrailer"]
var urlDict = [String: NSURL]()
var freeVersions = ["2", "11"]

func wait(time: Float, actions: @escaping () -> Void) {
    let timeInterval = TimeInterval(time)
    DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) {
        actions()
    }
}

func wait(actions: @escaping () -> Void) {
    wait(time: 1.0, actions: {
        actions()
    })
}

func activateAVSession(option:AVAudioSession.CategoryOptions) {
    do {
        try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: option)
        try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        try AVAudioSession.sharedInstance().setMode(.default)
        try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
        try AVAudioSession.sharedInstance().setAllowHapticsAndSystemSoundsDuringRecording(true)
    } catch {
        print("FUCK")
    }
}

func openLink(st: String) {
    guard let url = URL(string: st) else { return }
    UIApplication.shared.open(url)
}

func isOnPhoneCall() -> Bool {
    if isCallKitSupported() {
        for call in CXCallObserver().calls {
            if call.hasEnded == false {
                print("on call")
                return true
            }
        }
        print("not on call")
        return false
    }
    else {
        return false
    }
}

func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.impactOccurred()
}

func countLines(of label: UILabel, maxHeight: CGFloat) -> Int {
        // viewDidLayoutSubviews() in ViewController or layoutIfNeeded() in view subclass
        guard let labelText = label.text else {
            return 0
        }
        
        let rect = CGSize(width: label.bounds.width, height: maxHeight)
        let labelSize = labelText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: label.font!], context: nil)
        
        return Int(ceil(CGFloat(labelSize.height) / label.font.lineHeight))
   }

func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
    let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
    label.numberOfLines = 0
    label.font = font
    label.font = label.font.withSize(font.pointSize + 1)
    label.text = text
    
    label.sizeToFit()
    return label.frame.height
}

func isCallKitSupported() -> Bool {
    let userLocale = NSLocale.current
    
    guard let regionCode = userLocale.regionCode else { return false }
    
    if regionCode.contains("CN") ||
        regionCode.contains("CHN") {
        return false
    } else {
        return true
    }
}

func vidToURL(name: String, type: String) -> NSURL {
    if let filePath = Bundle.main.path(forResource: name, ofType: type) {
        let fileURL = NSURL(fileURLWithPath: filePath)
        return fileURL
    }
    return NSURL()
}

func downloadVideos() {
    for vid in vidArr {
        var videoURL:NSURL?
        print("Downloading \(vid)")
        game.setValue(false, forKey: "downloaded")
        videosCurrentlyDownloading = true
        database.fetch(withRecordID: CKRecord.ID(recordName: vid)) { results, error in
            if error != nil {
                print(" Error Downloading Record  " + error!.localizedDescription)
            } else {
                if results != nil {
                    let record = results! as CKRecord
                    let videoFile = record.object(forKey: "video") as! CKAsset
                    
                    videoURL = videoFile.fileURL! as NSURL
                    let videoData = NSData(contentsOf: videoURL! as URL)
                    
                    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                    let destinationPath = NSURL(fileURLWithPath: documentsPath).appendingPathComponent("\(vid).mov", isDirectory: false)
                    
                    FileManager.default.createFile(atPath: destinationPath!.path, contents:videoData as Data?, attributes:nil)
                    
                    videoURL = destinationPath! as NSURL
                    urlDict[vid] = videoURL
                    print("end download \(vid)")
                    if urlDict.count == vidArr.count {
                        videosCurrentlyDownloading = false
                        print("\n\nVideo Downloads Completed\n\n")
                        game.setValue(true, forKey: "downloaded")
                    }
                } else {
                    print("results Empty")
                    videosCurrentlyDownloading = false
                }
            }
        }
    }
}

func uploadVideos() {
    let thing = ["subPostChapter15"]
    for vid in thing {
        let url = vidToURL(name: vid, type: "mov")
        
        let videoRecord = CKRecord(recordType: "Videos", recordID: CKRecord.ID(recordName: vid))
        videoRecord["title"] = vid
        
        let videoAsset = CKAsset(fileURL: url as URL)
        videoRecord["video"] = videoAsset
        print("uploading \(vid)")
        videosCurrentlyDownloading = true
        database.save(videoRecord) { (record, error) -> Void in
            if error == nil {
                if urlDict.count == vidArr.count {
                    print("\n\nVideo Uploads Complete\n\n")
                    videosCurrentlyDownloading = false
                }
                print("\(vid) uploaded successfully")
            } else {
                print("upload error: \(error!)")
                videosCurrentlyDownloading = false
            }
        }
    }
}

func formatDateForUI(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter.string(from: date)
}

func validateReceipt() {
    print("Validating Receipt...")
    receipt = Receipt()
    if let receiptStatus = receipt?.receiptStatus {
        print("receipt status \(receiptStatus.rawValue)")
        guard receiptStatus == .validationSuccess else {
            // If verification didn't succeed, then show status in red and clear other fields
            print("verification did not succeed")
            return
        }
        
        // If verification succeed, we show information contained in the receipt
        print("Bundle Identifier: \(receipt?.bundleIdString!)")
        print("Bundle Version: \(receipt?.bundleVersionString!)")
        
        if let originalVersion = receipt?.originalAppVersion {
            print("Original Version: \(originalVersion)")
            game.setValue(originalVersion, forKey: "originalVersion")
        } else {
            print("Version Not Provided")
        }
        
        if let receiptExpirationDate = receipt?.expirationDate {
            print("Expiration Date: \(formatDateForUI(receiptExpirationDate))")
        } else {
            print("Not Provided.")
        }
        
        if let receiptCreation = receipt?.receiptCreationDate {
            print("Receipt Creation Date: \(formatDateForUI(receiptCreation))")
        } else {
            print("Not Provided.")
        }
        
    }
}

