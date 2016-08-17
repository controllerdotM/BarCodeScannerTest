//
//  BarScannerViewController.swift
//  BarScannerTest
//
//  Created by Brad Woodard on 8/17/16.
//  Copyright © 2016 Brad Woodard. All rights reserved.
//

import UIKit
import AVFoundation

class BarScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.whiteColor()
        captureSession = AVCaptureSession()
        
        let videoCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            captureFailed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        // You can only add an output to a session if canAddOutput: returns true.
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypePDF417Code]
        } else {
            captureFailed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.running == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.running == true) {
            captureSession.stopRunning()
        }
    }
    
    //MARK: - Utilities
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            let readableObject = metadataObject as! AVMetadataMachineReadableCodeObject
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            foundCode(readableObject.stringValue)
        }
        // Dismiss the view controller if a bar code is found
        //dismissViewControllerAnimated(true, completion: nil)
    }
    
    func foundCode(code: String) {
        let alertController = UIAlertController(title: "Found Bar Code", message: "\(code)", preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "OK", style: .Default) { _ in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(alertAction)
        presentViewController(alertController, animated: true, completion: nil)
        print(code)
    }
    
    func captureFailed() {
        let alertController = UIAlertController(title: "Scanning Not Supported", message: "Your device does support scanning. Please use a device with a camera.", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
        captureSession = nil
    }
    
    //MARK: - Cleanup
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}