//
//  EditProfileController.swift
//  Memer
//
//  Created by Nuri Chun on 7/2/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import UIKit
import Firebase

class EditProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout, EditProfileHeaderDelegate {
    
    var user: User?
    
    var editProfileHeader = EditProfileHeader()
    var selectedProfileImage: UIImage? {
        didSet {
            
        }
    }
  
    // MARK: - Properties
    
    lazy var cancelBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "cancel", style: .plain, target: self, action: #selector(handleCancel))
        button.tintColor = .white
        
        return button
    }()
    
    lazy var doneBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "done", style: .done, target: self, action: #selector(handleDone))
        button.tintColor = .white
        
        return button
    }()
    
    // MARK: - UIButton Targets
    
    static let updateProfileImageNotifcation = NSNotification.Name(rawValue: "UpdateProfileImage")

    @objc func handleDone() {
        NotificationCenter.default.post(name: EditProfileController.updateProfileImageNotifcation,  object: nil)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleCancel() {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Where is the Post NotificationCenter? EditProfileController will do post?
        // Observer in here, handling
        
        fetchUserInfo()
        setupNavBarTItle()
        setupCollectionAttributes()
        setupNavigationAttributes()
    }
    
    // MARK: - viewWillAppear()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.tintColor = .mainDark()
        self.tabBarController?.tabBar.isHidden = true
    }
    
    // MARK: - fetchUserProfile()
    
    private func fetchUserInfo() {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        
        Database.fetchUser(withUID: currentUserUid) { (user) in
            self.fetchUserProfileImage(user: user)
        }
    }
    
    private func fetchUserProfileImage(user: User) {
        let currentUserRef = Database.database().reference().child("users").child(user.uid)
        
        currentUserRef.observe(.value, with: { (snapshot) in
            
            guard let userDictionary = snapshot.value as? [String : Any] else { return }
            
            let user = User(uid: user.uid, dictionary: userDictionary)
            self.user = user
            self.collectionView?.reloadData()
            
        }) { (error) in
            print("Error: ", error)
        }
    }
    
    // MARK: - setupNavBarTitle()
    
    private func setupNavBarTItle() {
        title = "Edit Profile"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
    }
    
    // MARK: - setupCollectionAttributes()
    
    private func setupCollectionAttributes() {
        collectionView?.backgroundColor = .yellow
        collectionView?.register(EditProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Identification.editProfileCellId)
    }
    
    // MARK: - setupNavigationAttributes()
    
    private func setupNavigationAttributes() {
        self.navigationItem.setLeftBarButton(cancelBarButton, animated: true)
        self.navigationItem.setRightBarButton(doneBarButton, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension EditProfileController {
    
    override func collectionView(_ collectionView: UICollectionView,  viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Identification.editProfileCellId, for: indexPath) as! EditProfileHeader
        
        
        header.delegate = self
        header.user = user
        self.editProfileHeader = header
    
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let viewWidth = view.frame.width
        
        return CGSize(width: viewWidth, height: viewWidth - 125)
    }
}

// MARK: - EditProfileHeaderDelegate Method

extension EditProfileController {
    
    func didTapChangePic(forUser user: User?) {
        
        let layout = UICollectionViewFlowLayout()
        let photoSelectorController = PhotoSelectorController(collectionViewLayout: layout, forEditing: true)
        layout.sectionHeadersPinToVisibleBounds = true
        photoSelectorController.delegate = self.editProfileHeader
        
        navigationController?.pushViewController(photoSelectorController, animated: true)
    }
}
















