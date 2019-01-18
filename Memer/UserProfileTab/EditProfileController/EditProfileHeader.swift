//
//  EditProfileHeader.swift
//  Memer
//
//  Created by Nuri Chun on 7/2/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import UIKit
import Firebase

protocol EditProfileHeaderDelegate {
    func didTapChangePic(forUser user: User?)
}

class EditProfileHeader: UICollectionViewCell, PhotoSelectorControllerDelegate {
    
    // MARK: - Protocol Delegate
    
    var delegate: EditProfileHeaderDelegate?
    var photoSelector: PhotoSelectorController!
    
    var user: User? {
        didSet {
            // Current getting nil? Why?
            guard let profileUrl = self.user?.profileImageURL else { return }
            
            if self.user?.profileImageURL == "" {
                profileImageView.image = #imageLiteral(resourceName: "WillyWonka").withRenderingMode(.alwaysOriginal)
            } else {
                profileImageView.loadImage(urlString: profileUrl)
            }
        }
    }
    
    var selectedImage: UIImage? {
        didSet {
            profileImageView.image = selectedImage
        }
    }

    // MARK: - UIImageView Property
    
    let profileImageView: ImageViewCache = {
        
        let iv = ImageViewCache()
        
        iv.clipsToBounds = true
        iv.layer.masksToBounds = true
        iv.layer.borderColor = UIColor.rgb(r: 217, g: 215, b: 215).cgColor
        iv.layer.cornerRadius = 125.0 / 2.0
        iv.layer.borderWidth = 2.5
        
        return iv
    }()
    
    // MARK: - UIButton Property
    
    lazy var changeProfilePicButton: UIButton = {
        
        let button = UIButton()
        
        button.backgroundColor = .mainDark()
        button.setTitle("Change", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 5.0
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2.5
        button.addTarget(self, action: #selector(handleChangePic), for: .touchUpInside)
    
        return button
    }()
    
    // MARK: - UIButton addTarget method
    
    @objc func handleChangePic() {
        //        guard let user = user else { return }
        self.delegate?.didTapChangePic(forUser: user)
    }
    
    @objc func handleProfileImage() {
        saveProfileImage()
    }

    // MARK: - init(frame)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .mainDark()
        addNotificationObserver()
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: - Private functions

extension EditProfileHeader {
    
    // MARK: - addNotificationObserver()
    
    private func addNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleProfileImage), name: EditProfileController.updateProfileImageNotifcation, object: nil)
    }
    
    // MARK: - saveProfileImage()
    
    private func saveProfileImage() {
        
        // Creating a random string key for storage
        let filename = NSUUID().uuidString
        
        guard let profileImage = selectedImage else { return }
        guard let imageData = profileImage.jpegData(compressionQuality: 0.5) else { return }
        let storageRef = Storage.storage().reference().child("profilePictures").child(filename)
            storageRef.putData(imageData, metadata: nil) { (metaData, error) in
            
            if let error = error {
                print("Could not save to storage: ", error)
            }
            
                storageRef.downloadURL(completion: { (url, error) in
                    if error != nil {
                        print("failed to download url:", error ?? "error")
                        return
                    } else {
                        if let imageUrl = url {
                            self.saveProfileToDatabase(imageUrl: imageUrl.absoluteString)
                        }
                    }
                })
                
//            guard let imageUrl = metaData?.downloadURL()?.absoluteString else { return }
            
            
//            self.saveProfileToDatabase(imageUrl: imageUrl)
        }
    }
    
    // MARK: - saveProfileToDatabase()
    
    private func saveProfileToDatabase(imageUrl: String) {
        // UserProfileInformation All the data will be saved here.
        
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        let userRef = Database.database().reference().child("users").child(currentUserUid)
        
        let values = ["profileImageURL" : imageUrl] as [String : Any]
        
        userRef.updateChildValues(values) { (error, dataRef) in
            
            if let error = error {
                print("Could not update userProfileImage to database", error)
            }
        }
    }
    
    // MARK: - setupUI()
    
    private func setupUI() {
        
        let customHeightForProfileButton = profileImageView.frame.width / 4 // 31.25
        
        self.addSubview(profileImageView)
        self.addSubview(changeProfilePicButton)
        
        profileImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        profileImageView.anchor(top: topAnchor, left: nil, bottom: nil, right: nil, topPad: 30, leftPad: 0, bottomPad: 0, rightPad: 0, width: 125, height: 125)
        
        changeProfilePicButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        changeProfilePicButton.anchor(top: profileImageView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topPad: 15, leftPad: 125,    bottomPad: 0, rightPad: 125, width: 0, height: customHeightForProfileButton)
    }
}

// MARK: - Protocol: PhotoSelectorControllerDelegate

extension EditProfileHeader {
    
    func setProfileImage(selectedImage: UIImage?) {
        if let selectedImage = selectedImage {
            self.selectedImage = selectedImage
        }
    }
}






















