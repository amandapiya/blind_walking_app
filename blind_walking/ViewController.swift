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
         //After all settings to BambuserView has been done, add a call to startCapture in the viewDidLoad method.
         //bambuserView.startCapture()
     }


     override func viewWillLayoutSubviews() {
         var statusBarOffset : CGFloat = 0.0
         statusBarOffset = CGFloat(self.topLayoutGuide.length)
         bambuserView.previewFrame = CGRect(x: 0.0, y: 0.0 + statusBarOffset, width: self.view.bounds.size.width, height: self.view.bounds.size.height - statusBarOffset)
     }
     

}

