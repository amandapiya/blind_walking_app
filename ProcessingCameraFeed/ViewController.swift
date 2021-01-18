//
//  ViewController.swift
//  ProcessingCameraFeed
//
//  Created by Anurag Ajwani on 02/05/2020.
//  Copyright © 2020 Anurag Ajwani. All rights reserved.
//

import UIKit
import AVFoundation
import VideoToolbox
import ARKit
import VideoToolbox
import AudioToolbox
import Foundation
import AudioUnit

/*
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true
 */

let SOUNDS = 88;



class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var blindSound = [AVAudioPlayer?](repeating:nil, count:SOUNDS)
    var sound_being_used = 0;
    
    func base64urlToBase64(base64url: String) -> String {
        var base64 = base64url
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        if base64.count % 4 != 0 {
            base64.append(String(repeating: "=", count: 4 - base64.count % 4))
        }
        return base64
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
       let size = image.size

       let widthRatio  = targetSize.width  / size.width
       let heightRatio = targetSize.height / size.height

       // Figure out what our orientation is, and use that to form the rectangle
       var newSize: CGSize
       if(widthRatio > heightRatio) {
           newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
       } else {
           newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
       }

       // This is the rect that we've calculated out and this is what is actually used below
       let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

       // Actually do the resizing to the rect using the ImageContext stuff
       UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
       image.draw(in: rect)
       let newImage = UIGraphicsGetImageFromCurrentImageContext()
       UIGraphicsEndImageContext()

       return newImage!
   }
    
    private let captureSession = AVCaptureSession()
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview = AVCaptureVideoPreviewLayer(session: self.captureSession)
        preview.videoGravity = .resizeAspect
        return preview
    }()
    private let videoOutput = AVCaptureVideoDataOutput()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addCameraInput()
        self.addPreviewLayer()
        self.addVideoOutput()
        self.captureSession.startRunning()
        
        for i in 0..<SOUNDS {
            
            guard let url = Bundle.main.url(forResource: String(0), withExtension: "mp3") else { return }

                 do {
                    try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                    try AVAudioSession.sharedInstance().setActive(true)

                    /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
                    player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
                    player?.prepareToPlay();
                    /* iOS 10 and earlier require the following line:
                    player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

                    //player?.play()
                    blindSound[i] = player;
                    
                } catch let error {
                    print(error.localizedDescription)
                }
        
        }
        blindSound[sound_being_used]?.play();
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.previewLayer.frame = self.view.bounds
    }
    
    var player: AVAudioPlayer? = nil;
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("unable to get image from sample buffer")
            return
        }
        print("  did receive image frame");
        // process image here
        //MARK: CVPixel to UIImage
       var image = UIImage(ciImage: CIImage(cvPixelBuffer: frame))
       
       //MARK: UIIMage to Base64
       let size = CGSize(width: image.size.width/6, height:image.size.height/6)
       let newImage = resizeImage(image: image,targetSize: size)
       
       let imageData = newImage.jpegData(compressionQuality: 1)
       let imageBase64UrlString = imageData?.base64EncodedString(options:.lineLength64Characters)
       
       let imageBase64String = imageBase64UrlString!; //base64urlToBase64(base64url: imageBase64UrlString!)
       
       
       let json: [String: Any] = ["img": imageBase64String]

       let jsonData = try? JSONSerialization.data(withJSONObject: json)

       // create post request
       let url = URL(string: "http://34.125.240.78:5000/sendvideo")!
       var request = URLRequest(url: url)
       request.httpMethod = "POST"

       // insert json data to the request
       request.httpBody = jsonData

       let task = URLSession.shared.dataTask(with: request) { data, response, error in
           guard let data = data, error == nil else {
               print(error?.localizedDescription ?? "No data")
               return
           }
           self.dataString = String(data: data, encoding: .utf8)!
           
       }

               task.resume()

        let dataString = ".5 (12, 42)" // mock API endpoint
        
        let oldSound = sound_being_used;
        sound_being_used = (oldSound + 1) % SOUNDS; // get_sound_index(dataString: dataString)
        print("Playing sound!!!!!");
        
        

        blindSound[sound_being_used]?.play();//atTime:
                                            // -blindSound[sound_being_used]!.currentTime)
        let seconds = 0.06
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            // Put your code which should be executed with a delay here
        
            self.blindSound[oldSound]?.pause();
            self.blindSound[oldSound]?.currentTime = 0;
            self.blindSound[oldSound]?.prepareToPlay();
        }
        
        do {
            usleep(100)
        }

//
//
    }
    
    private func get_sound_index(dataString: String) -> Int{
        return 0 //TODO actual math
    }
    
    private func addCameraInput() {
        let device = AVCaptureDevice.default(for: .video)!
        let cameraInput = try! AVCaptureDeviceInput(device: device)
        self.captureSession.addInput(cameraInput)
    }
    
    private func addPreviewLayer() {
        self.view.layer.addSublayer(self.previewLayer)
    }
    
    private func addVideoOutput() {
        self.videoOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "my.image.handling.queue"))
        self.captureSession.addOutput(self.videoOutput)
    }
}


