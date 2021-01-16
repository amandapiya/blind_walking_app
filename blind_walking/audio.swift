//
//  audio.swift
//  blind_walking
//
//  Created by Kristin Ng on 1/16/21.
//

import Foundation
import AVFoundation
import AudioToolbox
import UIKit

func playSound(){
    
    var blindSound: AVAudioPlayer?
    
    //locate sound + create URL
    let path = Bundle.main.path(forResource: "example.mp3", ofType:nil)!
    let url = URL(fileURLWithPath: path)

    do {
        blindSound = try AVAudioPlayer(contentsOf: url)
        //play sound
        blindSound?.play()
    } catch {
        print("could not load file.")
    }
}
