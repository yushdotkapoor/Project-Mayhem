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
        if let bundle = Bundle.main.path(forResource: "Between0And1", ofType: "m4a") {
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
    
    func playGlitch() {
        guard let url = Bundle.main.url(forResource: "Glitch", withExtension: "wav") else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let player = audioPlayer else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
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
    
    func volumeControl(factor:Float) {
        let target = game.float(forKey: "volume") * factor
        audioPlayer?.setVolume(target, fadeDuration: 1)
    }
    
}
