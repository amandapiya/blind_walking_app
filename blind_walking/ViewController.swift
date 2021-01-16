//
//  ViewController.swift
//  blind_walking
//
//  Created by Amanda P on 1/16/21.
//

import UIKit
import CoreServices
import Photos
import BambuserBroadcaster


class ViewController: UIViewController, BambuserViewDelegate {
    var bambuserView : BambuserView
    var broadcastButton : UIButton
    
    //override the init function of ViewController class
    required init?(coder aDecoder: NSCoder) {
        bambuserView = BambuserView(preparePreset: kSessionPresetAuto)
        broadcastButton = UIButton(type: UIButton.ButtonType.system)
        super.init(coder: aDecoder)
        //assign it to BambuserView in ViewController.swift directly after initialization
        bambuserView.applicationId = "dgKc5pPeoIjbx9699K8Pcw"
    }
    
     override func viewDidLoad() {
         super.viewDidLoad()
         bambuserView.orientation = UIApplication.shared.statusBarOrientation
         self.view.addSubview(bambuserView.view)
        
        broadcastButton.addTarget(self, action: #selector(ViewController.broadcast), for: UIControl.Event.touchUpInside)
        broadcastButton.setTitle("Broadcast", for: UIControl.State.normal)
        self.view.addSubview(broadcastButton)

         //After all settings to BambuserView has been done, add a call to startCapture in the viewDidLoad method.
         //bambuserView.startCapture()
     }


     override func viewWillLayoutSubviews() {
         var statusBarOffset : CGFloat = 0.0
         statusBarOffset = CGFloat(self.topLayoutGuide.length)
         bambuserView.previewFrame = CGRect(x: 0.0, y: 0.0 + statusBarOffset, width: self.view.bounds.size.width, height: self.view.bounds.size.height - statusBarOffset)
        broadcastButton.frame = CGRect(x: 0.0, y: 0.0 + statusBarOffset, width: 100.0, height: 50.0);

     }
     
    @objc func broadcast() {
        NSLog("Starting broadcast")
        broadcastButton.setTitle("Connecting", for: UIControl.State.normal)
        broadcastButton.removeTarget(nil, action: nil, for: UIControl.Event.touchUpInside)
        broadcastButton.addTarget(bambuserView, action: #selector(bambuserView.stopBroadcasting), for: UIControl.Event.touchUpInside)
        bambuserView.startBroadcasting()
    }

}

