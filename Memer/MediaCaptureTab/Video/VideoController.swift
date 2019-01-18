//
//  VideoController.swift
//  Memer
//
//  Created by Nuri Chun on 5/22/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class VideoController: UIViewController, AVCaptureFileOutputRecordingDelegate, UIViewControllerTransitioningDelegate
{
    // MARK: - AnimationTransitioning Properties
    
    let animationPresentor = CustomAnimationPresontorRight()
    let animationDismisser = CustomAnimationDismisserRight()
    
    // MARK: - AVCapture Properties
    
    let captureSession = AVCaptureSession()
    let movieOutput = AVCaptureMovieFileOutput()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var activeInput: AVCaptureDeviceInput!
    var outputURL: URL!
    
    // MARK: - BASIC Properties
    
    let cancelButton: UIButton =
    {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "SkinnyCancelButton").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        
        return button
    }()
    
    let recordButton: UIButton =
    {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "GrayRecordButton Copy").withRenderingMode(.alwaysOriginal), for: .normal) 
        button.addTarget(self, action: #selector(handleRecord), for: .touchUpInside)

        return button
    }()
    
    let reverseButton: UIButton =
    {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "reverse arrow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleReverse), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - HANDLE METHODS button.addTarget()
    
    @objc func handleCancel()
    {
        print("Cancel button pressed...")
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @objc func handleRecord()
    {
        print("Record button pressed...")
        startRunning()
    }
    
    @objc func handleReverse()
    {
        print("Reverse button pressed...")
    }
    
    // MARK: - viewDidLoad()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        transitioningDelegate = self
        
        setupNavigationItem()
        
        if setupSession()
        {
            setupPreview()
            startSession()
            setupHUD()
        }
    }
    
    // MARK: - setupNavigationItem()
    
    private func setupNavigationItem() {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
    }
    
    // video 
    
    private func setupHUD()
    {
        // create a stack UI?
        
        let topDivider = UIView()
        
        topDivider.backgroundColor = UIColor.rgb(r: 216, g: 216, b: 216)
        
        view.addSubview(recordButton)
        recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        recordButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, topPad: 0, leftPad: 0, bottomPad: 20, rightPad: 0, width: 80, height: 80)
        
        view.addSubview(topDivider)
        topDivider.anchor(top: nil, left: view.leftAnchor, bottom: recordButton.topAnchor, right: view.rightAnchor, topPad: 0, leftPad: 10, bottomPad: 10, rightPad: 10, width: 0, height: 1.5)
        
        view.addSubview(cancelButton)
        cancelButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: nil, topPad: 0, leftPad: 20, bottomPad: 20, rightPad: 0, width: 30,  height: 30)
        
        view.addSubview(reverseButton)
        reverseButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: view.rightAnchor, topPad: 0, leftPad: 0, bottomPad: 20, rightPad: 20, width: 30, height: 30)
    }
}

// MARK: - AVFoundation CaptureSession Methods

extension VideoController
{
    // Checks is session is all complete and we have the suitable device to capture photos and record videos.
    
    private func setupSession() -> Bool
    {
        captureSession.sessionPreset = .high
        
        // Camera
        guard let camera = AVCaptureDevice.default(for: AVMediaType.video) else { return false}
        
        do {
            let input = try AVCaptureDeviceInput.init(device: camera)
            
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
            }
        } catch {
            print("Error, device requirement invalid. \(error)")
            return false
        }
        
        // Microphone
        guard let microphone = AVCaptureDevice.default(for: .audio) else { return false }
        
        do {
            let micInput = try AVCaptureDeviceInput.init(device: microphone)
            
            if captureSession.canAddInput(micInput) {
                captureSession.addInput(micInput)
            }
            
        } catch {
            print("Error, built it audio non-existent: \(error)")
            return false
        }
        
        // MovieOutput
        
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
        return true
    }
    
    private func setupPreview()
    {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        
        view.layer.addSublayer(previewLayer)
     }
    
    private func startRunning()
    {
        if movieOutput.isRecording == false
        {
            let connection = movieOutput.connection(with: AVMediaType.video)
            
            if (connection?.isVideoOrientationSupported)!
            {
                connection?.videoOrientation = currentVideoOrientation()
            }
            
            if (connection?.isVideoStabilizationSupported)!
            {
                connection?.preferredVideoStabilizationMode = .auto
            }
            
            let device = activeInput.device
            
            if (device.isSmoothAutoFocusSupported)
            {
                try? device.lockForConfiguration()
                device.isSmoothAutoFocusEnabled = false
                device.unlockForConfiguration()
            }
            
            outputURL = tempURL()
            movieOutput.startRecording(to: outputURL, recordingDelegate: self)
            
        } else {
            stopRecording()
        }
    }
    
    private func stopRecording()
    {
        if movieOutput.isRecording == true {
            movieOutput.stopRecording()
        }
    }
    
    private func startSession()
    {
        if !captureSession.isRunning {
            DispatchQueue.main.async {
                self.captureSession.startRunning()
            }
        }
    }
    
    private func stopSession()
    {
        if captureSession.isRunning {
            DispatchQueue.main.async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    private func currentVideoOrientation() -> AVCaptureVideoOrientation
    {
        var orientation: AVCaptureVideoOrientation!
        
        switch UIDevice.current.orientation
        {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
        case .landscapeRight:
            orientation = AVCaptureVideoOrientation.landscapeLeft
        case .portraitUpsideDown:
            orientation = AVCaptureVideoOrientation.portraitUpsideDown
        default:
            orientation = AVCaptureVideoOrientation.landscapeRight
         }
        return orientation
    }
    
    private func tempURL() -> URL?
    {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        return nil
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate

extension VideoController
{
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection])
    {
        // Set logic, if record button is pressed first time, record, if pressed second, stop recording.
    }
    
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?)
    {
        if error != nil {
            print("Error: \(String(describing: error?.localizedDescription))")
        } else {
            _ = outputURL as URL
        }
        outputURL = nil
    }
}

// MARK: - UIViewControllerTransitioningDelegate Methods

extension VideoController
{
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return animationPresentor
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return animationDismisser
    }
}









