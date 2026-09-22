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
var satella = UIFont(name: "Satella", size: 20)
var videosCurrentlyDownloading = false
var IAPs:[SKProduct]?
let database = CKContainer.default().publicCloudDatabase
let vidArr = ["Chap1Intro", "lvl7Intro", "lvl7Outro", "subPostChapter15", "ProjectVenomTrailer"]
let videoFileExtension = "mp4"
/// Extension used by builds before the videos were compressed; stale copies are cleaned up on download.
let legacyVideoFileExtension = "mov"
let localeArr = ["ar", "ca", "zh-Hans", "zh-Hant", "hr", "cs", "da", "nl", "en", "fi", "fr", "de", "el", "he", "hi", "hu", "id", "it", "ja", "ko", "ms", "nb", "pl", "pt", "ro", "ru", "sk", "es", "sv", "th", "tr", "uk", "vi"]
var mediaCount = 0
let messageFrom = "Message From".localized()
var menuState = false
var languageTranslations:[String:String] = [:]
var languageCodes:[String:String] = [:]
var languages:[String:String] = [:]

// MARK: - General
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

func isView(selfView: UIViewController, checkView: AnyClass) -> Bool {
	if let viewController = selfView.navigationController?.visibleViewController {
		if viewController.isKind(of: checkView.self) {
			return true
		}
		return false
	}
	return false
}

func notAbleToUseCellular() -> Bool {
    return !game.bool(forKey: "useCellular") && game.bool(forKey: "onCellular")
}

// MARK: - Wait Functions
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

// MARK: - Haptic Feedback
func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
	let generator = UIImpactFeedbackGenerator(style: style)
	generator.impactOccurred()
}

func impact(style: UINotificationFeedbackGenerator.FeedbackType) {
	let generator = UINotificationFeedbackGenerator()
	generator.notificationOccurred(style)
}

// MARK: - Label Height
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

// MARK: - Phone Stuff
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

// MARK: - Videos

private var videoRetryCounts: [String: Int] = [:]
private let maxVideoDownloadAttempts = 3

func changeTagKey(for vid: String) -> String {
	return "\(vid)ChangeTag"
}

/// Fetches only the metadata of every video record (no asset download) and calls back on the
/// main thread with the names of videos that are missing on disk or whose server copy has a
/// different change tag than the one saved locally. If CloudKit can't be reached, falls back
/// to reporting only the videos that are missing on disk.
func checkForVideoUpdates(completion: @escaping ([String]) -> Void) {
	let op = CKFetchRecordsOperation(recordIDs: vidArr.map { CKRecord.ID(recordName: $0) })
	op.desiredKeys = ["title"]
	op.fetchRecordsCompletionBlock = { recordDict, error in
		var needed: [String] = []
		if let records = recordDict, error == nil {
			for vid in vidArr {
				let exists = retrieveVideo(name: vid) != ""
				guard let serverTag = records[CKRecord.ID(recordName: vid)]?.recordChangeTag else {
					if !exists { needed.append(vid) }
					continue
				}
				let localTag = game.string(forKey: changeTagKey(for: vid))
				if !exists {
					needed.append(vid)
				} else if localTag == nil {
					// Existing install with no stored tag: adopt the server's tag instead of
					// re-downloading a file that is already here.
					game.setValue(serverTag, forKey: changeTagKey(for: vid))
				} else if localTag != serverTag {
					needed.append(vid)
				}
			}
		} else {
			print("Could not check for video updates: \(error?.localizedDescription ?? "unknown error")")
			needed = validateVideos()
		}
		DispatchQueue.main.async { completion(needed) }
	}
	database.add(op)
}

func downloadVideos(vidNames: [String]) {
	mediaCount = 0
	for vid in vidNames {
		downloadVideo(named: vid, of: vidNames.count)
	}
}

private func downloadVideo(named vid: String, of total: Int) {
	print("Downloading \(vid)")
	videosCurrentlyDownloading = true
	let op = CKFetchRecordsOperation(recordIDs: [CKRecord.ID(recordName: vid)])
	op.perRecordProgressBlock = { record, progress in
		DispatchQueue.main.async {
			print("\(record.recordName) progress: \(progress)")
			game.setValue(progress, forKey: "\(record.recordName)DownloadProgress")
		}
	}
	op.fetchRecordsCompletionBlock = { recordDict, error in
		if let error = error {
			let attempts = (videoRetryCounts[vid] ?? 0) + 1
			videoRetryCounts[vid] = attempts
			print("Error downloading \(vid) (attempt \(attempts) of \(maxVideoDownloadAttempts)): \(error.localizedDescription)")
			if attempts < maxVideoDownloadAttempts {
				wait(time: Float(attempts) * 2.0) {
					downloadVideo(named: vid, of: total)
				}
			} else {
				print("Giving up on \(vid) after \(attempts) attempts")
				videoRetryCounts[vid] = 0
				videosCurrentlyDownloading = false
			}
			return
		}

		guard let record = recordDict?.values.first,
			  let videoFile = record.object(forKey: "video") as? CKAsset,
			  let videoURL = videoFile.fileURL,
			  let videoData = NSData(contentsOf: videoURL) else {
			print("results Empty")
			videosCurrentlyDownloading = false
			return
		}

		let fileURL = URL(fileURLWithPath: videoFilePath(for: vid))

		do {
			try videoData.write(to: fileURL, options: .atomic)
			// Only remember the server's tag once the file is safely on disk, so an
			// interrupted download is retried next time rather than treated as done.
			game.setValue(record.recordChangeTag, forKey: changeTagKey(for: vid))
			videoRetryCounts[vid] = 0
			removeLegacyVideoFile(for: vid)
			print("\(vid) saved @ \(fileURL)")
		} catch {
			print("error saving file:", error)
		}

		mediaCount += 1
		print("end download \(vid)")
		if mediaCount == total {
			videosCurrentlyDownloading = false
			print("\n\nVideo Downloads Completed\n\n")
		}
	}
	database.add(op)
}

func uploadVideos() {
	let thing = ["subPostChapter15", "lvl7Intro", "lvl7Outro", "ProjectVenomTrailer", "Chap1Intro"]
	for vid in thing {
		let url = vidToURL(name: vid, type: videoFileExtension)
		
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


/// Weekly refresh used only for the (small) Firebase localization files.
func weekTimer() -> Bool {
	let now = Date().timeIntervalSince1970
	let dateToCheck = game.double(forKey: "weekDate")

	if dateToCheck == 0.0 || now > dateToCheck {
		game.setValue(now + 604800, forKey: "weekDate")
		return true
	}

	return false
}

func getDirectoryPath() -> String {
	let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
	let documentsDirectory = paths[0]
	return documentsDirectory
}

func videoFilePath(for name: String, ext: String = videoFileExtension) -> String {
	return (getDirectoryPath() as NSString).appendingPathComponent("\(name).\(ext)")
}

/// Deletes the uncompressed copy left behind by older builds, if one exists.
func removeLegacyVideoFile(for name: String) {
	let legacyPath = videoFilePath(for: name, ext: legacyVideoFileExtension)
	guard FileManager.default.fileExists(atPath: legacyPath) else { return }
	do {
		try FileManager.default.removeItem(atPath: legacyPath)
		print("Removed legacy \(name).\(legacyVideoFileExtension)")
	} catch {
		print("Could not remove legacy video \(name):", error)
	}
}

func retrieveVideo(name: String) -> String {
	let fileManager = FileManager.default
	let path = videoFilePath(for: name)
	print("Pathfinder \(path)")
	if fileManager.fileExists(atPath: path) {
		return path
	} else{
		print("No Video Exists")
		return ""
	}
}

/// Returns the names of videos that are missing on disk.
func validateVideos() -> [String] {
	let fileManager = FileManager.default
	var toReturn:[String] = []
	for i in vidArr {
		let path = videoFilePath(for: i)
		if !fileManager.fileExists(atPath: path) {
			print("Error: There seems to be a video file missing")
			toReturn.append(i)
		}
	}
	return toReturn
}


func vidToURL(name: String, type: String) -> NSURL {
	if let filePath = Bundle.main.path(forResource: name, ofType: type) {
		let fileURL = NSURL(fileURLWithPath: filePath)
		return fileURL
	}
	return NSURL()
}

// MARK: = IAPs
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

// MARK: = Localization
func createDirectory(langCode: String, values: String) {
    let code = langCode.replacingOccurrences(of: "_", with: "-")
 
    let DocumentDirectory = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
    let DirPath = DocumentDirectory.appendingPathComponent("\(code)-fire.lproj")
    
    do {
        try FileManager.default.createDirectory(atPath: DirPath!.path, withIntermediateDirectories: true, attributes: nil)
        
    } catch let error as NSError {
        print("Unable to create directory \(error.debugDescription)")
    }
    
    let str = values
    
    let fm = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let filename = fm.appendingPathComponent("\(code)-fire.lproj/Localizable.strings")
    
    do {
        try str.write(to: filename, atomically: true, encoding: String.Encoding.utf16)
    } catch let error as NSError {
        print("ERROR in writing file \(error.debugDescription)")
    }
}

func validateLocalizationFiles() -> [String] {
    let fileManager = FileManager.default
    var toReturn:[String] = []
    for i in localeArr {
        let path = (getDirectoryPath() as NSString).appendingPathComponent("\(i)-fire.lproj/Localizable.strings")
        if !fileManager.fileExists(atPath: path) {
            print("Error: There seems to be a video file missing")
            toReturn.append(i)
        }
    }
    return toReturn
}


func downloadLocaleFiles() {
    ref.child("Localizations").observeSingleEvent(of: .value, with: { (snapshot) in
        let val = snapshot.value as? NSDictionary
        let codes = val!["Codes"] as? [String:String]
        let translations = val!["Translations"] as? [String: String]
        
        languageCodes = codes ?? [:]
        languageTranslations = translations ?? [:]
        for i in languageCodes.keys {
            let code = (languageCodes[i] ?? "") as String
            let trans = (languageTranslations[i] ?? "") as String
            
            //removeLocaleDirectories(code: code)
            
           createDirectory(langCode: code, values: trans)
            
        }
    })
}

func getLanguage(row: Int) -> String {
    let lan = languages.keys.sorted()
    for (i, f) in lan.enumerated() {
        if i == row {
            return f
        }
    }
    return ""
}

func getLanguageCode(row: Int) -> String {
    let lan = languages.keys.sorted()
    for (i, f) in lan.enumerated() {
        if i == row {
            return languages[f] ?? ""
        }
    }
    return ""
}

func getRowOfLanguageCode(code: String) -> Int {
    let lan = languages.keys.sorted()
    for (i, f) in lan.enumerated() {
        if languages[f] == code {
            return i
        }
    }
    return 0
    
}

func getLanguageFromCode(code: String) -> String {
    for f in languages.keys {
        if languages[f] == code {
            return f
        }
    }
    return ""
}

func initLanguagesArray() {
    languages = ["Arabic".localized(): "ar", "Catalan".localized(): "ca", "Chinese (Simplified)".localized(): "zh-Hans", "Chinese (Traditional)".localized(): "zh-Hant", "Croatian".localized(): "hr", "Czech".localized(): "cs", "Danish".localized(): "da", "Dutch".localized(): "nl", "English".localized(): "en", "Finnish".localized(): "fi", "French".localized(): "fr", "German".localized(): "de", "Greek".localized(): "el", "Hebrew".localized(): "he", "Hindi".localized(): "hi", "Hungarian".localized(): "hu", "Indonesian".localized(): "id", "Italian".localized(): "it", "Japanese".localized(): "ja", "Korean".localized(): "ko", "Malay".localized(): "ms", "Norwegian".localized(): "nb", "Polish".localized(): "pl", "Portuguese".localized(): "pt", "Romanian".localized(): "ro", "Russian".localized(): "ru", "Slovak".localized(): "sk", "Spanish".localized(): "es", "Swedish".localized(): "sv", "Thai".localized(): "th", "Turkish".localized(): "tr", "Ukranian".localized(): "uk", "Vietnamese".localized(): "vi"]
}
