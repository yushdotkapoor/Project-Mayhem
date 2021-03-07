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
        if let bundle = Bundle.main.path(forResource: "01", ofType: "wav") {
            let backgroundMusic = NSURL(fileURLWithPath: bundle)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf:backgroundMusic as URL)
                guard let audioPlayer = audioPlayer else { return }
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
        let vol = game.float(forKey: "volume") * 0.4
        audioPlayer?.volume = vol
    }
    
    func updateVolumeLow() {
        let vol = game.float(forKey: "volume") * 0.2
        audioPlayer?.volume = vol
    }
}
