

import UIKit
import UserNotifications
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        if game.string(forKey: "name") == nil {
            game.setValue(1.0, forKey: "volume")
        }
        audio()
        
        let theSession = AVAudioSession.sharedInstance()
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: theSession)
       
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
        if AVAudioSession.isHeadphonesConnected {
            activateAVSession(option: [.allowBluetooth, .allowAirPlay, .allowBluetoothA2DP])
        }
        else {
            activateAVSession(option: [.allowBluetooth, .allowAirPlay, .allowBluetoothA2DP, .defaultToSpeaker])
        }
        MusicPlayer.shared.startBackgroundMusic()
        MusicPlayer.shared.updateVolume()
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

