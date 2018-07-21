//
//  CameraController.swift
//  Memer
//
//  Created by Nuri Chun on 5/2/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import Foundation


// MARK: - NOTES
/*
 1. First find out how to create a customTabBar
 2. Remember to create the unselected and selected tabBarItem.

 -------
 1. Need 3 tabBarItems: photoLibrary, camera, video
 2. Need a customAnimationTransition for the three.
 3. When transitioning, the tabBar and the navigationBar should stay in view.
 4. Also, when transitioning, the navigationBarItems should change depending on the controller.
 5. PhotoSelectorController is its entire controller of its own.
 6. The CameraController and VideoController have the same view, but the bottom section of the controller, the mechanics, change.
 */

/*
 1. Create a custom UIView class for both camera and video
 
 */

class CameraController: UIViewController, AVCapturePhotoCaptureDelegate {
    // MARK: - AVCapture Properties
    
    let postPhotoController = PostPhotoController()
    let previewContainerView = PhotoPreviewContainerView()

    let session = AVCaptureSession()
    var output = AVCapturePhotoOutput()
    var previewLayer:AVCaptureVideoPreviewLayer?
    var frontCamera: AVCaptureDevice?
    var backCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    
    var usingFrontCamera = false
    var isCameraTab = true
    var isVideoTab = false
    var isLibraryTab = false
    
    var selectedImage: UIImage?
    
    // MARK: - UIBarButtonItem
    
    lazy var backBarItem: UIBarButtonItem = {
        let backBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "CoolSmallBack").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleBack))
        
        return backBarButton
    }()
    
    lazy var nextBarItem: UIBarButtonItem = {
        let nextBarButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
        
        nextBarButton.tintColor = UIColor.white
        
        return nextBarButton
    }()
    
    // MARK: - Views
    
    let cameraView: UIView = {
        let view = UIView()
        
        view.clipsToBounds = true
        
        return view
    }()
    
    let topDivider: UIView = {
        let view = UIView()
        
        view.backgroundColor = .white
        view.alpha = 0.8
        
        return view
    }()
    
    let cameraToolView: UIView = {
        let view = UIView()
        
        view.backgroundColor = UIColor.rgb(r: 216, g: 216, b: 216)
        
        return view
    }()

    // MARK: - Button Properties
    
    let photoLibraryButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitle("Photo Album", for: .normal)
        button.layer.cornerRadius = 10.0
        button.layer.borderColor = UIColor.rgb(r: 216, g: 216, b: 216).cgColor
        button.layer.borderWidth = 1.5
        button.backgroundColor = UIColor.rgb(r: 96, g: 96, b: 96)
        button.setTitleColor(UIColor.white, for: .normal)
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleAlbum), for: .touchUpInside)
        
        return button
    }()
    
    @objc func handleAlbum() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionHeadersPinToVisibleBounds = true
        
        let photoLibrary = PhotoSelectorController(collectionViewLayout: layout, forEditing: false)
        
        navigationController?.pushViewController(photoLibrary, animated: true)
    }
    
    let capturePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "GrayCameraButton").withRenderingMode(.alwaysOriginal), for: .normal)
        button.layer.borderColor = UIColor.white.cgColor
        button.alpha = 0.8
        button.clipsToBounds = true
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(handleCapturePhoto), for: .touchUpInside)
        
        return button
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setImage(#imageLiteral(resourceName: "SkinnyCancelButton").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        button.alpha = 0.8
        
        return button
    }()
    
    let reverseButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setImage(#imageLiteral(resourceName: "reverse arrow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleReverse), for: .touchUpInside)
        button.alpha = 0.8
        
        return button
    }()
    
    // MARK: - HANDLE METHODS button.addTarget()
    
    @objc func handleReverse() {
        usingFrontCamera = !usingFrontCamera
        self.setupCaptureSession()
        previewLayer?.frame = cameraView.bounds
    }
    
    @objc func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleCapturePhoto() {
        let settings = AVCapturePhotoSettings()
        
        self.output.capturePhoto(with: settings, delegate: self)
        
        cancelButton.isEnabled = false
    }
    
    // MARK: - prefersStatusBarHidden
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.rgb(r: 99, g: 99, b: 99)
        setupNavigationItem()
        setupCaptureSession()
        setupHUD()
    }
    
    // MARK: - viewDidAppear()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        previewLayer?.frame = cameraView.bounds
    }

    // MARK: - viewWillAppear()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - setupNavBar()
    
    private func setupNavigationItem() {
        title = "Camera"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        navigationController?.navigationBar.barTintColor = UIColor.rgb(r: 99, g: 99, b: 99)
    }
    
    // MARK: - setupHUD()
    
    public func setupHUD() {
        guard let navigationBarHeightPadding = navigationController?.navigationBar.frame.height else { return }
        
        view.addSubview(cameraView)
        view.addSubview(topDivider)
        view.addSubview(cameraToolView)
        cameraToolView.addSubview(photoLibraryButton)
        cameraToolView.addSubview(capturePhotoButton)
        cameraToolView.addSubview(cancelButton)
        cameraToolView.addSubview(reverseButton)
        
        cameraToolView.backgroundColor = UIColor.rgb(r: 99, g: 99, b: 99)
 
        cameraView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: topDivider.topAnchor , right: view.rightAnchor, topPad: navigationBarHeightPadding, leftPad: 0, bottomPad: 0, rightPad: 0, width: view.frame.width,  height: 0)
        
        topDivider.anchor(top: nil, left: view.leftAnchor, bottom: cameraToolView.topAnchor, right: view.rightAnchor, topPad: 0, leftPad: 0, bottomPad: 0, rightPad: 0, width: 0,  height: 1.5)
        
        cameraToolView.anchor(top: topDivider.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topPad: 0, leftPad: 0, bottomPad: 0, rightPad: 0, width: 0, height: view.frame.width / 2)
        
        capturePhotoButton.centerXAnchor.constraint(equalTo: cameraToolView.centerXAnchor).isActive = true
        capturePhotoButton.centerYAnchor.constraint(equalTo: cameraToolView.centerYAnchor).isActive = true
        capturePhotoButton.anchor(top: nil, left: nil, bottom: nil, right:  nil, topPad: 0, leftPad: 0, bottomPad: 0,   rightPad: 0, width:  80, height: 80)
        
        cancelButton.centerYAnchor.constraint(equalTo: cameraToolView.centerYAnchor).isActive = true
        cancelButton.anchor(top: nil, left: cameraToolView.leftAnchor, bottom: nil, right: nil, topPad: 0, leftPad: 20, bottomPad: 50, rightPad: 20,  width: 30, height: 30)

        reverseButton.centerYAnchor.constraint(equalTo: cameraToolView.centerYAnchor).isActive = true
        reverseButton.anchor(top: nil, left: nil, bottom: nil, right:  cameraToolView.rightAnchor, topPad: 0, leftPad: 20, bottomPad: 0, rightPad: 20, width:  30, height: 30)
        
        photoLibraryButton.centerXAnchor.constraint(equalTo: cameraToolView.centerXAnchor).isActive = true
        photoLibraryButton.anchor(top: capturePhotoButton.bottomAnchor, left: nil, bottom: nil,  right: nil, topPad: 12,  leftPad: 0, bottomPad: 0, rightPad: 0, width: 120, height:   30)

    }
}

// MARK: - AVCaptureSession Methods

extension CameraController
{
    func stopCaptureSession ()
    {
        self.session.stopRunning()
        
        // removes the current input
        if let inputs = session.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                self.session.removeInput(input)
            }
        }
    }
    
    // create a new view?, view for camera and view for video?
    
    func presentPreviewLayer()
    {
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraView.layer.addSublayer(previewLayer!)
    }
    
    private func setupCaptureSession()
    {
        
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: .video, position: AVCaptureDevice.Position.unspecified)
        let devices = discoverySession.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                frontCamera = device
            }
        }
        
        guard let currentCamera = (usingFrontCamera ? frontCamera : backCamera) else { return }
        
        self.stopCaptureSession()
        
        // Setup Device Input
        do {
            let input = try AVCaptureDeviceInput(device: currentCamera)
            
            if session.canAddInput(input)
            {
                session.addInput(input)
            }
            
        } catch let error {
            print("Could not capture input...", error)
        }
        
        // Setup Device Output
        
        if session.canAddOutput(output)
        {
            session.addOutput(output)
        }
        
        // Setup CapturePreviewLayer && reset the HUD
        self.presentPreviewLayer()
        
        session.startRunning()
    }
}

// MARK: - AVCapturePhotoCaptureDelegate Methods

extension CameraController
{
    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?)
    {
        
//        navigationController?.navigationBar.backgroundColor = UIColor.rgb(r: 227, g: 220, b: 220)
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action:   #selector(handleBack))
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleNext))
        
        guard let photoCapturedData = photo.fileDataRepresentation() else { return }
        guard let navigationBarHeight = navigationController?.navigationBar.frame.height else { return }
        
        let previewImage = UIImage(data: photoCapturedData)
        
        view.addSubview(previewContainerView)
        previewContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: topDivider.topAnchor, right: view.rightAnchor, topPad: navigationBarHeight, leftPad: 0,  bottomPad: 0, rightPad: 0, width: view.frame.width, height: 0)
 
        previewContainerView.previewImageView.image = previewImage
        postPhotoController.selectedImage = previewImage 
        
        capturePhotoButton.isEnabled = false
        
        UIView.animate(withDuration: 0.6,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: UIViewAnimationOptions.curveLinear,
                       animations: {
                        self.navigationItem.setLeftBarButton(self.backBarItem, animated: true)
                        self.navigationItem.setRightBarButton(self.nextBarItem, animated: true)
        },
                       completion: nil)
    }

    @objc func handleBack() {
        previewContainerView.removeFromSuperview()
        capturePhotoButton.isEnabled = true
        cancelButton.isEnabled = true
        
        UIView.animate(withDuration: 0.6,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: UIViewAnimationOptions.curveLinear,
                       animations: {
                        self.navigationItem.setLeftBarButton(nil, animated: true)
                        self.navigationItem.setRightBarButton(nil, animated: true)
        },
                       completion: nil)
    }
    
    @objc func handleNext() {
        self.navigationController?.pushViewController(postPhotoController, animated: true)
    }
}



