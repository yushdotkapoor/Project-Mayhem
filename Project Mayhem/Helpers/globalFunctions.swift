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

var video:VideoPlayer?
var godThread:UIViewController?
var ripplingView:UIView?
var talk:speechModule?
var wordToSearch:[String]?
var funcToPass:(() -> Void)?
var tomorrow = UIFont(name: "Tomorrow", size: 20)
var videosCurrentlyDownloading = false

let database = CKContainer.default().publicCloudDatabase
let vidArr = ["Chap1Intro", "lvl7Intro", "lvl7Outro", "subPostChapter15", "ProjectVenomTrailer"]
var urlDict = [String: NSURL]()

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
