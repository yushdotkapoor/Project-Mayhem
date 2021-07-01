

import UIKit
import UserNotifications
import AVFoundation
import CallKit
import Firebase
import Network
import StoreKit
import Siren

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CXCallObserverDelegate, SKRequestDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?
    
    let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
    
    let gcmMessageIDKey = "gcm.message_id"
    
    let callObserver = CXCallObserver()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        
        Siren.shared.wail()
        
        downloadLocaleFiles()
        
        //game.setValue("en", forKey: "AppleLanguage")
        var lang = game.string(forKey: "AppleLanguage")
        if lang == nil {
            lang = Locale.current.languageCode
        }
        
        game.setValue(lang, forKey: "AppleLanguage")
        game.synchronize()
        Bundle.setLanguage(lang)
        
        let center = UNUserNotificationCenter.current()
           center.delegate = self
        
        
        //default values for the start of the game
        if game.string(forKey: "name") == nil {
            game.setValue(1.0, forKey: "volume")
            game.setValue(true, forKey: "useCellular")
            game.setValue(false, forKey: "photosensitive")
        }
        
        audio()
        
        let theSession = AVAudioSession.sharedInstance()
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: theSession)
        
        
        if isCallKitSupported() {
            callObserver.setDelegate(self, queue: nil)
        }
        
        ProjectMayhemProducts.store.requestProducts{ [weak self] success, products in
            guard self != nil else { return }
            if success {
                IAPs = products!
                print(IAPs as Any)
            }
        }
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                game.setValue(false, forKey: "onCellular")
                //connected to wifi
            } else {
                game.setValue(true, forKey: "onCellular")
                // not connected to wifi
            }
            
            print(path.isExpensive)
        }
        
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
        
        
        Messaging.messaging().delegate = self
        
        game.setValue("\(Messaging.messaging().fcmToken ?? "")", forKey: "token")
        
        if(launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] != nil){
             print("user tapped and now is doing stuff!")
            goToChat(vc: (self.window?.rootViewController?.topViewController!)!)
         }
        
        return true
    }
    
    func removeLocaleDirectories(code: String) {
        let DocumentDirectory = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        let DirPath = DocumentDirectory.appendingPathComponent("\(code)-fire.lproj")
        
        do {
            try FileManager.default.removeItem(atPath: DirPath!.path)
            
        } catch let error as NSError {
            print("Unable to remove directory \(error.debugDescription)")
        }
    }
    
    func refreshReceipt() {
        print("Requesting refresh of receipt.")
        let refreshRequest = SKReceiptRefreshRequest()
        refreshRequest.delegate = self
        refreshRequest.start()
    }
    
    
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        if call.hasEnded {
            print("call ended")
            print(MusicPlayer.shared.audioPlayer!.isPlaying)
            wait(time:3.0 ,actions: {
                if !MusicPlayer.shared.audioPlayer!.isPlaying {
                    print("music restarted")
                    self.audio()
                }
                if video != nil {
                    video?.functionCalled = false
                    video?.play()
                }
            })
        }
    }
    
    @objc func handleInterruption(notification: NSNotification) {
        let info = notification.userInfo!
        var intValue: UInt = 0
        (info[AVAudioSessionInterruptionTypeKey] as! NSValue).getValue(&intValue)
        if let interruptionType = AVAudioSession.InterruptionType(rawValue: intValue) {
            
            switch interruptionType {
            case .began:
                print("Interruption Began")
                // player is paused and session is inactive. need to update UI)
                MusicPlayer.shared.pause()
                if video != nil {
                    video?.pause()
                }
                print("audio paused")
                break
                
            default:
                print("Interruption Ended")
                audio2()
                MusicPlayer.shared.play()
                if video != nil {
                    video?.functionCalled = false
                    video?.play()
                }
                print("audio resumed")
            }
        }
    }
    
    func audio() {
        audio2()
        MusicPlayer.shared.startBackgroundMusic()
        MusicPlayer.shared.volumeControl(factor: 0.4)
    }
    
    func audio2() {
        if AVAudioSession.isHeadphonesConnected {
            activateAVSession(option: [.allowAirPlay, .allowBluetoothA2DP, .duckOthers])
        }
        else {
            activateAVSession(option: [.allowAirPlay, .allowBluetoothA2DP, .defaultToSpeaker, .duckOthers])
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let data = response.notification.request.content.userInfo
        
        let topView = self.window?.rootViewController?.topViewController
        
        if topView is ChatViewController || topView is MessageView {
            //test to reduce
        } else if !data.isEmpty {
            goToChat(vc: (self.window?.rootViewController?.topViewController)!)
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      
         let topView = self.window?.rootViewController?.topViewController
        if topView is ChatViewController || topView is MessageView {
            completionHandler([])
        } else {
            completionHandler([.list, .banner, .sound])
        }
    }

    
    private func application(_ application: UIApplication, didReceive notification: UNNotificationRequest) {
        UIApplication.shared.applicationIconBadgeNumber = 1
    }
    
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("foreground")
        MusicPlayer.shared.play()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("background")
        MusicPlayer.shared.pause()
    }
    
}
