//
//  ViewController.swift
//  blind_walking
//
//  Created by Amanda P on 1/16/21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        var blindSound: AVAudioPlayer?
        
        //locate sound + create URL
        let path = Bundle.main.path(forResource: "blind.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)

        do {
            blindSound = try AVAudioPlayer(contentsOf: url)
            //play sound
            blindSound?.play()
        } catch {
            print("could not load file.")
        }
    }

}

