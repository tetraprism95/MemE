//
//  PostPhotoController.swift
//  Memer
//
//  Created by Nuri Chun on 6/5/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import UIKit
import Firebase

class PostPhotoController: UIViewController, UIViewControllerTransitioningDelegate
{
    // MARK: - UIViewControllerTransitioning Properties
    
    let customAnimationPresentorRight = CustomAnimationPresontorRight()
    let customAnimationDismisserRight = CustomAnimationDismisserRight()
    
    // MARK: - UIImage Transfer Property didSet
    
    var selectedImage: UIImage? {
        didSet {
            self.imagePostView.image = selectedImage
        }
    }
 
    // MARK: - NavigationBarItem Properties
    
    lazy var backBarItem: UIBarButtonItem =
    {
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "CoolSmallBack").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleBack))
        return backButton
    }()
    
    lazy var shareBarItem: UIBarButtonItem =
    {
        let shareButton = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        shareButton.tintColor = UIColor.white
        shareButton.isEnabled = false

        return shareButton
    }()
    
    // MARK: - UI Properties
    
    let locationView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(r: 97, g: 87, b: 87)
        view.layer.cornerRadius = 5.0
        
        return view
    }()
    
    let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "Current Location"
        label.font = UIFont(name: "BanglaSangamMN", size: 20)
        
        return label
    }()
    
    let memeTitleTextView: UITextView = {
        let tv = UITextView()
        
        tv.layer.borderWidth = 1.5
        tv.layer.borderColor = UIColor.rgb(r: 97, g: 87, b: 87).cgColor
//        tv.placeholder = "Caption Your Meme..."
//        tv.textColor = UIColor.rgb(r: 33, g: 26, b: 26)
        tv.textColor = UIColor.lightGray
        tv.text = "Meme Placeholder"
        tv.font = UIFont(name: "ChalkboardSE-Bold", size: 20)
        tv.layer.cornerRadius = 5.0
        tv.enablesReturnKeyAutomatically = false
        
        return tv
    }()
    
    let descriptionTextView: UITextView = {
        let tv = UITextView()
        tv.layer.borderWidth = 1.5
        tv.layer.borderColor = UIColor.rgb(r: 97, g: 87, b: 87).cgColor
//        tv.placeholder = "Write a brief description..."
        tv.text = "Description Placeholder"
        tv.font = UIFont(name: "BanglaSangamMN", size: 14)
        tv.textColor = UIColor.lightGray
 //        tv.textColor = UIColor.rgb(r: 33, g: 26, b: 26)
        tv.layer.cornerRadius = 5.0
        
        return tv
    }()
    
    var imagePostView: UIImageView = { 
        let iv = UIImageView()
        iv.backgroundColor = UIColor.red
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.borderWidth = 1.5
        iv.layer.borderColor = UIColor.rgb(r: 97, g: 87, b: 87).cgColor
        iv.layer.cornerRadius = 5.0
        
        return iv
    }()

    let locationSuggestions: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = UIColor.cyan
        
        return tv
    }()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.rgb(r: 227, g: 220, b: 220)
        transitioningDelegate = self
        setupTextViewDelegateSelf()
        setupNavigationBar()
        hideKeyboardByTap()
        setupUI()
    }
    
    // MARK: - setupNavigationBar()
    
    private func setupNavigationBar() {
        title = "Post"
        navigationController?.navigationBar.isHidden = false
        navigationItem.leftBarButtonItem = backBarItem
//        PostPhotoController.shareBarItem.target = self
        navigationItem.rightBarButtonItem = shareBarItem
    }
    
    // MARK: - #Selector()
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleShare() {
        
        let filename = NSUUID().uuidString
        
        guard let memeCaption = memeTitleTextView.text, memeCaption.count > 0 else { return }
        guard let memeDescription = descriptionTextView.text, memeDescription.count >= 0 else { return }
        guard let image = selectedImage else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        
        Storage.storage().reference().child("posts").child(filename).putData(imageData, metadata: nil) { (metaData, error) in
            
            if let error = error {
                print("Error: Could not save Image URL to Storagebase", error)
                return
            }
            
            guard let imageUrl = metaData?.downloadURL()?.absoluteString else { return }
            
            self.saveImageURLToDatabase(imageURL: imageUrl)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    static let updateFeedNotification = NSNotification.Name("UpdateFeed")
    
    private func saveImageURLToDatabase(imageURL: String) {
        
        guard let postImage = selectedImage else { return }
        guard let memeCaption = memeTitleTextView.text else { return }
        guard let memeDescription = descriptionTextView.text else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let userPostRef = Database.database().reference().child("posts").child(uid)
        let ref = userPostRef.childByAutoId()
        
        
        // 1. Where would I retrieve this likeCount instance?
        // "likeCount" : likeCount
        
        let values =
            ["imagePostUrl" : imageURL,
            "memeCaption" : memeCaption,
            "memeDescription" : memeDescription,
            "imageWidth" : postImage.size.width,
            "imageHeight" : postImage.size.height,
            "creationDate" : Date().timeIntervalSince1970] as [String : Any]
        
        
        ref.updateChildValues(values) { (error, dataRef)  in 
            if let error = error {
                print("Error could not save imagePostUrl to FirebaseDatabase", error)
                return
            }
    
            NotificationCenter.default.post(name: PostPhotoController.updateFeedNotification, object: nil)
            
            self.memeTitleTextView.text = nil
        }
    }
    
    // MARK: - TextView Delegate Self Method
    
    private func setupTextViewDelegateSelf() {
        memeTitleTextView.delegate = self
        descriptionTextView.delegate = self
    }

    // MARK: - setupUI()

    private func setupUI() {
        
        let leftDividerView = UIView()
        let rightDividerView = UIView()
        
        leftDividerView.backgroundColor =  UIColor.rgb(r: 97, g: 87, b: 87)
        rightDividerView.backgroundColor = UIColor.rgb(r: 97, g: 87, b: 87)
        
        let imageViewWidth = view.frame.width / 4
        guard let navBarHeight = navigationController?.navigationBar.frame.height else { return }
        let constantPadding: CGFloat = 3.0
        let navBarHeightWithPadding = navBarHeight + constantPadding
        let viewWithWithPadding: CGFloat = view.frame.width - (constantPadding * 2)
 
        view.addSubview(imagePostView)
        imagePostView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topPad: navBarHeightWithPadding, leftPad: 3, bottomPad: 0, rightPad: 0, width: imageViewWidth, height: imageViewWidth)
        
        view.addSubview(memeTitleTextView)
        memeTitleTextView.anchor(top: view.topAnchor, left: imagePostView.rightAnchor, bottom: nil, right: view.rightAnchor, topPad: navBarHeightWithPadding, leftPad: 3, bottomPad: 0, rightPad: 3,  width: 0, height: imageViewWidth)
        
        view.addSubview(descriptionTextView)
        descriptionTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        descriptionTextView.anchor(top: memeTitleTextView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topPad: 6, leftPad: 3, bottomPad: 0, rightPad: 3, width: viewWithWithPadding, height: 200)
        
        view.addSubview(locationLabel)
        locationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        locationLabel.anchor(top: descriptionTextView.bottomAnchor, left: nil, bottom: nil, right: nil, topPad: 20, leftPad: 0, bottomPad: 0, rightPad: 0, width: 0, height: 0)
        
        view.addSubview(leftDividerView)
        leftDividerView.anchor(top: descriptionTextView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: locationLabel.leftAnchor, topPad: 35, leftPad: 3, bottomPad: 0, rightPad: 3, width: 0, height: 1)
        
        view.addSubview(rightDividerView)
        rightDividerView.anchor(top: descriptionTextView.bottomAnchor, left: locationLabel.rightAnchor, bottom: nil, right: view.rightAnchor, topPad: 35, leftPad: 3, bottomPad: 0, rightPad: 3, width: 0, height: 1)
        
        view.addSubview(locationView)
        
        locationView.anchor(top: locationLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topPad: 20, leftPad: 3, bottomPad: 0, rightPad: 3, width: 0, height: 75)
     }
}

// MARK: - UIViewControllerTransitioningDelegate

extension PostPhotoController {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customAnimationPresentorRight
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customAnimationDismisserRight
    }
}

// MARK: - UITextViewDelegate

extension PostPhotoController: UITextViewDelegate {
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        return text != "\n"
        // If the current inputted text does not equal "New Line", which is True, then you are able to edit.
        // Else if the current inputted text is the "New Line", which is false, then you are not able to edit.
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if memeTitleTextView.text.count > 0 && memeTitleTextView.textColor == UIColor.black {
            shareBarItem.isEnabled = true
        } else {
            shareBarItem.isEnabled = false
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text.isEmpty == true {
            textView.textColor = UIColor.lightGray
            textView.text = "Meme Placeholder"
        }
    }
}


























