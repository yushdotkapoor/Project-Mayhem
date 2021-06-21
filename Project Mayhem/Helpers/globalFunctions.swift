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
let database = CKContainer.default().publicCloudDatabase
let vidArr = ["Chap1Intro", "lvl7Intro", "lvl7Outro", "subPostChapter15", "ProjectVenomTrailer"]
var mediaCount = 0
let messageFrom = "Message From".localized()

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

func impact(style: UINotificationFeedbackGenerator.FeedbackType) {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(style)
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
    mediaCount = 0
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
                    
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let fileURL = documentsDirectory.appendingPathComponent("\(vid).mov")
                    
                    do {
                        try videoData!.write(to: fileURL)
                        print("\(vid) saved @ \(fileURL)")
                    } catch {
                        print("error saving file:", error)
                    }
                    
                    mediaCount += 1
                    
                    print("end download \(vid)")
                    if mediaCount == vidArr.count {
                        videosCurrentlyDownloading = false
                        print("\n\nVideo Downloads Completed\n\n")
                        let date = Date().timeIntervalSince1970 + 604800
                        game.setValue(Double(date), forKey: "weekDate")
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

func weekTimer() -> Bool {
    let date = Date().timeIntervalSince1970
    let dateToCheck = game.double(forKey: "weekDate")
    
    if date > dateToCheck {
        return true
    }
    
    return false
}

func getDirectoryPath() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectory = paths[0]
    return documentsDirectory
}

func retrieveVideo(name: String) -> String {
    let fileManager = FileManager.default
    let path = (getDirectoryPath() as NSString).appendingPathComponent("\(name).mov")
    print("Pathfinder \(path)")
    if fileManager.fileExists(atPath: path) {
        return path
    } else{
        print("No Video Exists")
        return ""
    }
}


func uploadVideos() {
    let thing = ["subPostChapter15", "lvl7Intro", "lvl7Outro", "ProjectVenomTrailer", "Chap1Intro"]
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
                if mediaCount == vidArr.count {
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

func isView(selfView: UIViewController, checkView: AnyClass) -> Bool {
    if let viewController = selfView.navigationController?.visibleViewController {
        if viewController.isKind(of: checkView.self) {
            return true
        }
        return false
    }
    return false
}

extension String {
    func localized() -> String {
        return NSLocalizedString(self, tableName: "Localizable", bundle: .main, value: self, comment: self)
    }
    
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
    
    mutating func removeLastSpace() -> String {
        if (last == " ") {
            return String(dropLast())
        }
        return self
    }
}


extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
              let range = self[startIndex...]
                .range(of: string, options: options) {
            result.append(range)
            startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}


func getIAP(productIdentifier: String) -> SKProduct {
    for i in IAPs ?? [] {
        if i.productIdentifier == productIdentifier {
            return i
        }
    }
    return SKProduct()
}

extension Int {
    static func parse(from string: String) -> Int? {
        return Int(string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
    }
}

