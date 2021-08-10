

import UIKit
import UserNotifications
import AVFoundation
import CallKit
import Firebase
import Network
import StoreKit
import Siren

var administratorToken:String?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CXCallObserverDelegate, SKRequestDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?
    
    let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
    
    let callObserver = CXCallObserver()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        
        Siren.shared.wail()
        
        ref.child("users/Admin/token").observeSingleEvent(of: .value, with: { (snapshot) in
            let val = snapshot.value as? String ?? ""
            administratorToken = val
        })
        
        downloadLocaleFiles()
        Auth.auth().signInAnonymously()
        
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
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }
            else{
                print("User accepted notifications")
            }
        }
        
        application.registerForRemoteNotifications()
        
        //default values for the start of the game
        if game.string(forKey: "name") == nil {
            game.setValue(1.0, forKey: "volume")
            game.setValue(true, forKey: "useCellular")
            game.setValue(false, forKey: "photosensitive")
        }
        
        audio()
        
        ref.child("Data/RickRollLink").observeSingleEvent(of: .value, with: { (snapshot) in
            let val = snapshot.value as? String ?? ""
            game.setValue(val, forKey: "RikeshLink")
        })
        
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
        
        
        let tolkien = "\(Messaging.messaging().fcmToken ?? "")"
        print("FCM Registration token \(tolkien)")
        game.setValue(tolkien, forKey: "token")
        
        
        
        if launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] != nil {
            goToChat(vc: (self.window?.rootViewController?.topViewController!)!)
        }
        
        return true
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register: \(error)")
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict:[String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
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
        var titl = "Project Mayhem"
        if !data.isEmpty {
            let aps = data[AnyHashable("aps")] as! NSDictionary
            let alert = aps["alert"] as! [String:String]
            titl = alert["title"]!
        }
        
        let topView = self.window?.rootViewController?.topViewController
        
        if topView is ChatViewController || topView is MessageView {
            //test to reduce
        } else if titl == "Yush" || titl == "Someone needs your fucking help, bitch" {
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
