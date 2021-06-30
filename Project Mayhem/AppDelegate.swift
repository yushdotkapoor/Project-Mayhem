

import UIKit
import UserNotifications
import AVFoundation
import OneSignal
import CallKit
import AppsFlyerLib
import Firebase
import Network
import StoreKit
import Siren

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CXCallObserverDelegate, SKRequestDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?
    
    let gcmMessageIDKey = "gcm.message_id"
    
    let callObserver = CXCallObserver()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        AppsFlyerLib.shared().appsFlyerDevKey = "pFA4cAKh8K3p2G6sRXEsC4"
        AppsFlyerLib.shared().appleAppID = "1551711683"
        AppsFlyerLib.shared().delegate = self 
        AppsFlyerLib.shared().isDebug = false
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 120)
        
        FirebaseApp.configure()
        
        Siren.shared.wail()
        
        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setAppId("12db9d9f-4c00-4d45-83e7-0cf7e40026cd")
        
        //game.setValue("en", forKey: "AppleLanguage")
        var lang = game.string(forKey: "AppleLanguage")
        
        if lang == "" {
            lang = Locale.preferredLanguages.first
            game.setValue(lang, forKey: "AppleLanguage")
        }
        game.synchronize()
        Bundle.setLanguage(lang)
        
        let center = UNUserNotificationCenter.current()
           center.delegate = self
        
        
        //default values for the start of the game
        if game.string(forKey: "name") == nil {
            game.setValue(1.0, forKey: "volume")
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
        
        
        Messaging.messaging().delegate = self
        
        game.setValue("\(Messaging.messaging().fcmToken ?? "")", forKey: "token")
        
        if(launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] != nil){
             print("user tapped and now is doing stuff!")
            goToChat(vc: (self.window?.rootViewController?.topViewController!)!)
         }
        
        return true
    }
    
    func refreshReceipt() {
        print("Requesting refresh of receipt.")
        let refreshRequest = SKReceiptRefreshRequest()
        refreshRequest.delegate = self
        refreshRequest.start()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        AppsFlyerLib.shared().handleOpen(url, options: options)
        return true
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
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Start the SDK (start the IDFA timeout set above, for iOS 14 or later)
        AppsFlyerLib.shared().start()
        print("did become active")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("foreground")
        MusicPlayer.shared.play()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("background")
        MusicPlayer.shared.pause()
    }
    
    // Open Univerasal Links
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print(" user info \(userInfo)")
        AppsFlyerLib.shared().handlePushNotification(userInfo)
    }
    // Open Deeplinks
    // Open URI-scheme for iOS 8 and below
    private func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: restorationHandler)
        return true
    }
    // Open URI-scheme for iOS 9 and above
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        AppsFlyerLib.shared().handleOpen(url, sourceApplication: sourceApplication, withAnnotation: annotation)
        return true
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        AppsFlyerLib.shared().handlePushNotification(userInfo)
    }
    // Reports app open from deep link for iOS 10 or later
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
        return true
    }
}

//MARK: AppsFlyerLibDelegate
extension AppDelegate: AppsFlyerLibDelegate{
    // Handle Organic/Non-organic installation
    func onConversionDataSuccess(_ installData: [AnyHashable: Any]) {
        print("onConversionDataSuccess data:")
        for (key, value) in installData {
            print(key, ":", value)
        }
        if let status = installData["af_status"] as? String {
            if (status == "Non-organic") {
                if let sourceID = installData["media_source"],
                   let campaign = installData["campaign"] {
                    print("This is a Non-Organic install. Media source: \(sourceID)  Campaign: \(campaign)")
                }
            } else {
                print("This is an organic install.")
            }
            if let is_first_launch = installData["is_first_launch"] as? Bool,
               is_first_launch {
                print("First Launch")
            } else {
                print("Not First Launch")
            }
        }
    }
    func onConversionDataFail(_ error: Error) {
        print(error)
    }
    //Handle Deep Link
    func onAppOpenAttribution(_ attributionData: [AnyHashable : Any]) {
        //Handle Deep Link Data
        print("onAppOpenAttribution data:")
        for (key, value) in attributionData {
            print(key, ":",value)
        }
    }
    func onAppOpenAttributionFailure(_ error: Error) {
        print(error)
    }
    
}

