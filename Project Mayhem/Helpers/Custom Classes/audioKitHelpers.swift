//
//  audioKitHelpers.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 1/29/21.
//

import Foundation
import AudioKit
import AVKit

class Tone {
    var engine = AudioEngine()
    var osc = Oscillator()
    
    init() {
        engine.output = osc
    }
    
    func start(amplitude: Float, frequency: Float) {
        osc.amplitude = amplitude
        osc.frequency = frequency
        
        do {
            try engine.start()
        } catch let err {
            print("Error: \(err)")
        }
        osc.start()
    }
    
    func stop() {
        osc.stop()
    }
}

class Listen {
    let engine = AudioEngine()
    var fq: Float = 0.0
    let mic: AudioEngine.InputNode!
    var tappableNode1: Mixer
    var tracker: PitchTap!
    var silence: Fader
    var memeBlock: Bool
    
    init() {
        guard let input = engine.input else {
            fatalError()
        }
        
        mic = input
        tappableNode1 = Mixer(mic)
        silence = Fader(tappableNode1, gain: 0)
        engine.output = silence
        memeBlock = false
        tracker = PitchTap(mic) { pitch, amp in
            DispatchQueue.main.async {
                if amp[0] > 0.1 {
                    self.fq = pitch[0]
                }
                else {
                    self.fq = 0.0
                }
                if amp[0] > 1 {
                    if !self.memeBlock {
                        self.memeBlock = true
                        print("block active")
                        openLink(st: "https://i.ibb.co/qYnmL23/images.jpg")
                        print("gawddamnn das loud")
                    }
                }
            }
        }
    }
    
    func start() {
        print("Audio kit start")
        do {
            try engine.start()
            tracker.start()
        } catch(let error) {
            print(error.localizedDescription)
        }
    }
    
    func stop() {
        print("Audio kit stop")
        engine.stop()
        tracker.stop()
    }
    
}
