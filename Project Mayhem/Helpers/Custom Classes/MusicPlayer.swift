//
//  MusicPlayer.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 3/2/21.
//

import UIKit
import AVFoundation

class MusicPlayer {
    static let shared = MusicPlayer()
    var audioPlayer: AVAudioPlayer?

    func startBackgroundMusic() {
        pause()
        if let bundle = Bundle.main.path(forResource: "Between0And1", ofType: "wav") {
            let backgroundMusic = NSURL(fileURLWithPath: bundle)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf:backgroundMusic as URL)
                guard let audioPlayer = audioPlayer else { return }
                let target = game.float(forKey: "volume") * 0.4
                audioPlayer.volume = 0
                audioPlayer.setVolume(target, fadeDuration: 0.75)
                audioPlayer.numberOfLoops = -1
                audioPlayer.prepareToPlay()
                audioPlayer.play()
            } catch {
                print(error)
            }
        }
    }
    
    func pause() {
        guard let audioPlayer = audioPlayer else { return }
        audioPlayer.pause()
    }
    
    func play() {
        guard let audioPlayer = audioPlayer else { return }
        audioPlayer.play()
    }
    
    func updateVolume() {
        volumeControl(factor: 0.4)
       
    }
    
    func updateVolumeLow() {
        volumeControl(factor: 0.1)
    }
    
    func volumeControl(factor:Float) {
        
        let target = game.float(forKey: "volume") * factor
        audioPlayer?.setVolume(target, fadeDuration: 1)
        
        /*
        let currVol = audioPlayer?.volume ?? 0.0
        let target = game.float(forKey: "volume") * factor
        
        if currVol > target {
            turnVolumeDown(current: currVol, target: target)
        }
        else {
            turnVolumeUp(current: currVol, target: target)
        }
 */
    }
    
    func turnVolumeDown(current: Float, target: Float) {
        audioPlayer?.volume -= 0.01
        let inter:Float = audioPlayer!.volume
        if inter > target {
            wait(time:0.03, actions: {
                self.turnVolumeDown(current: inter, target: target)
            })
        }
    }
    
    func turnVolumeUp(current: Float, target: Float) {
        audioPlayer?.volume += 0.005
        let inter:Float = audioPlayer!.volume
        if inter < target {
            wait(time:0.025, actions: {
                self.turnVolumeUp(current: inter, target: target)
            })
        }
    }
}
