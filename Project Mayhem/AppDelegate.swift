

import UIKit
import UserNotifications
import AVFoundation
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Remove this method to stop OneSignal Debugging
         OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)

         // OneSignal initialization
         OneSignal.initWithLaunchOptions(launchOptions)
         OneSignal.setAppId("12db9d9f-4c00-4d45-83e7-0cf7e40026cd")

         // promptForPushNotifications will show the native iOS notification permission prompt.
         // We recommend removing the following code and instead using an In-App Message to prompt for notification permission (See step 8)
         OneSignal.promptForPushNotifications(userResponse: { accepted in
           print("User accepted notifications: \(accepted)")
         })
        
        if game.string(forKey: "name") == nil {
            game.setValue(1.0, forKey: "volume")
        }
        audio()
        
        let theSession = AVAudioSession.sharedInstance()
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: theSession)

          return true
    }
    
    @objc func handleInterruption(notification: NSNotification) {
        let info = notification.userInfo!
               var intValue: UInt = 0
               (info[AVAudioSessionInterruptionTypeKey] as! NSValue).getValue(&intValue)
        if let interruptionType = AVAudioSession.InterruptionType(rawValue: intValue) {

           switch interruptionType {
           case .began:
               print("began")
               // player is paused and session is inactive. need to update UI)
            MusicPlayer.shared.pause()
               print("audio paused")
            break

           default:
                print("ended")
            MusicPlayer.shared.play()
                print("audio resumed")
               }
           }
       }
    
    func audio() {
       audio2()
        MusicPlayer.shared.startBackgroundMusic()
        MusicPlayer.shared.updateVolume()
    }
    
    func audio2() {
        if AVAudioSession.isHeadphonesConnected {
            activateAVSession(option: [.allowBluetooth, .allowAirPlay, .allowBluetoothA2DP, .duckOthers])
        }
        else {
            activateAVSession(option: [.allowBluetooth, .allowAirPlay, .allowBluetoothA2DP, .defaultToSpeaker, .duckOthers])
        }
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([])
    }
    
    private func application(_ application: UIApplication, didReceive notification: UNNotificationRequest) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
   
        
    
}

