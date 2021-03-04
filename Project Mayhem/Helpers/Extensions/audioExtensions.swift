//
//  audioExtensions.swift
//  Project Mayhem
//
//  Created by Yush Raj Kapoor on 3/3/21.
//

import AVFoundation


extension AVAudioSession {

static var isHeadphonesConnected: Bool {
    return sharedInstance().isHeadphonesConnected
}

var isHeadphonesConnected: Bool {
    return !currentRoute.outputs.filter { $0.isHeadphones }.isEmpty
}

}

extension AVAudioSessionPortDescription {
var isHeadphones: Bool {
    return portType == AVAudioSession.Port.headphones
}
}
