

import UIKit
import UserNotifications
import AVFoundation
import OneSignal
import CallKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CXCallObserverDelegate {
    
    var window: UIWindow?
    
    let callObserver = CXCallObserver()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
         OneSignal.initWithLaunchOptions(launchOptions)
         OneSignal.setAppId("12db9d9f-4c00-4d45-83e7-0cf7e40026cd")
        
         OneSignal.promptForPushNotifications(userResponse: { accepted in
           print("User accepted notifications: \(accepted)")
         })
        
        if game.string(forKey: "name") == nil {
            game.setValue(1.0, forKey: "volume")
        }
        audio()
        
        let theSession = AVAudioSession.sharedInstance()
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: theSession)
        
        callObserver.setDelegate(self, queue: nil)

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
        MusicPlayer.shared.updateVolume()
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
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([])
    }
    
    private func application(_ application: UIApplication, didReceive notification: UNNotificationRequest) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}

