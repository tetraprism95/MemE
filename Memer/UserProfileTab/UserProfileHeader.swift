//
//  UserProfileHeader.swift
//  Memer
//
//  Created by Nuri Chun on 5/4/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import UIKit
import Firebase

// Refactor Later

protocol UserProfileHeaderDelegate {
    
    func didTapEditProfile(forUser user: User?)
    func didTapList()
    func didTapGrid()
}

class UserProfileHeader: UICollectionViewCell {

    var delegate: UserProfileHeaderDelegate?
    var user: User? {
        didSet {
            guard let profileImageUrl = self.user?.profileImageURL else {
                return profileImageView.image = #imageLiteral(resourceName: "WillyWonka").withRenderingMode(.alwaysOriginal)
            }
            profileImageView.loadImage(urlString: profileImageUrl)
//            nameLabel.text = self.user?.fullName
        }
    }

    // MARK: - LABEL PROPERTIES
    
    let nameLabel: UILabel =
    {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor.rgb(r: 217, g: 215, b: 215)
        label.text = "Nuri Chun"
        label.font =  UIFont(name: "Courier", size: 15) ??   UIFont.boldSystemFont(ofSize: 18)
        
        return label
    }()
    
    let popularityLabel: UILabel =
    {
        let label = UILabel()
        
        label.numberOfLines = 2
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        
        let attributedText = NSMutableAttributedString(attributedString: NSAttributedString(string: "100\n", attributes:  [NSAttributedString.Key.foregroundColor : UIColor.rgb(r: 77, g: 255, b: 98),  NSAttributedString.Key.font : UIFont(name: "Futura-CondensedMedium", size: 25) ?? UIFont.boldSystemFont(ofSize: 18)]))
        attributedText.append(NSAttributedString(attributedString: NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor : UIColor.rgb(r: 217, g: 215, b: 215)])))
        label.attributedText = attributedText
        
        return label
    }()
    
    let postsLabel: UILabel =
    {
        let label = UILabel()
        
        label.text = "Posts"
        label.textAlignment = .center
        label.numberOfLines = 2
        label.layer.cornerRadius = 10
        
        let attributedText = NSMutableAttributedString(attributedString: NSAttributedString(string: "99\n", attributes:  [NSAttributedString.Key.foregroundColor : UIColor.rgb(r: 77, g: 255, b: 98), NSAttributedString.Key.font :UIFont(name: "Futura-CondensedMedium", size: 25) ?? UIFont.boldSystemFont(ofSize: 18)]))
        attributedText.append(NSAttributedString(attributedString: NSAttributedString(string: "posts", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor : UIColor.rgb(r: 217, g: 215, b: 215)])))
        label.attributedText = attributedText
        
        return label
    }()
    
    let memersLabel: UILabel = 
    {
        let label = UILabel()
        
        label.text = "Memers"
        label.numberOfLines = 2
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        
        let attributedText = NSMutableAttributedString(attributedString: NSAttributedString(string: "30\n", attributes:  [NSAttributedString.Key.foregroundColor : UIColor.rgb(r: 77, g: 255, b: 98), NSAttributedString.Key.font : UIFont(name: "Futura-CondensedMedium", size: 25) ?? UIFont.boldSystemFont(ofSize: 18)]))
        attributedText.append(NSAttributedString(attributedString: NSAttributedString(string: "memers", attributes: [NSAttributedString.Key.font  : UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor : UIColor.rgb(r: 217, g: 215, b: 215)])))
        label.attributedText = attributedText
        
        return label
    }()
    
    // MARK: - BUTTON PROPERTIES
    
    lazy var editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.rgb(r: 217, g: 215, b: 215).cgColor
        button.layer.cornerRadius = 10.0
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(handleEditProfile), for: .touchUpInside)
        
        return button
    }()
    
    lazy var gridButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "memeSelected"), for: .normal)
        button.tintColor = UIColor.rgb(r: 196, g: 132, b: 132)
        button.addTarget(self, action: #selector(handleGrid), for: .touchUpInside)
 
        return button
    }()
    
    lazy var listButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "gridSelected"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleList), for: .touchUpInside)
        
        return button
    }()
    
    // Mark: - IMAGEVIEW PROPERTIES
    
    let profileImageView: ImageViewCache = {
        
        let iv = ImageViewCache()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .white
        iv.clipsToBounds = true
        iv.layer.masksToBounds = true
        iv.layer.cornerRadius = 80 / 2
        iv.layer.borderColor = UIColor.rgb(r: 217, g: 215, b: 215).cgColor
        iv.layer.borderWidth = 2.5
        
        return iv
    }()
    
    // MARK: - INIT()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupBackgroundColor()
        addNotificationObserver()
        setupHeaderUI()
    }
    
    // MARK: - Selectors() handle methods
    
    @objc func handleGrid() {
        gridButton.tintColor = UIColor.rgb(r: 196, g: 132, b: 132)
        listButton.tintColor = .white
        delegate?.didTapGrid()
    }
    
    @objc func handleList() {
        listButton.tintColor = UIColor.rgb(r: 196, g: 132, b: 132)
        gridButton.tintColor = .white
        delegate?.didTapList()
    }
    
    @objc func handleEditProfile() {
        delegate?.didTapEditProfile(forUser: user)
     }
    
    @objc func handleProfileImage() {
        fetchProfileImage()
    }
    
    private func fetchProfileImage() {
    
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        let currentUserRef = Database.database().reference().child("users").child(currentUserUid)
        
        currentUserRef.observe(.value, with: { (snapshot) in
            
            let userDict = snapshot.value as! [String : Any]
            let user = User(uid: currentUserUid, dictionary: userDict)
            
            self.user = user
        }) { (error) in
            print("Could not retrieve the imageUrl at Database: ", error)
        }
    }
    
    // MARK: - NotificationCenterAddObserver()
    
    private func addNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleProfileImage), name: EditProfileController.updateProfileImageNotifcation, object: nil)
    }
    
    // MARK: - setupBackgroundColor()
    
    private func setupBackgroundColor() {
        self.backgroundColor = .mainDark()
    }
    
    // MARK: - setupHeaderUI()
    
    private func setupHeaderUI()
    {
        let topDivider = UIView()
        topDivider.backgroundColor = UIColor.white
        
        let bottomDivider = UIView()
        bottomDivider.backgroundColor = UIColor.white
        
        let socialStackView = UIStackView(arrangedSubviews: [popularityLabel, postsLabel, memersLabel])
        
        let selectionStackView = UIStackView(arrangedSubviews: [gridButton, listButton])
        
        addSubview(profileImageView)
        addSubview(nameLabel)
        addSubview(editProfileButton)
        addSubview(socialStackView)
        addSubview(topDivider)
        addSubview(selectionStackView)
        addSubview(bottomDivider)
        
        socialStackView.axis = .horizontal
        socialStackView.alignment = .center
        socialStackView.distribution = .fillEqually
        socialStackView.spacing = 5
        
        profileImageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, topPad: 12, leftPad: 6, bottomPad: 0, rightPad: 0, width: 80, height: 80)
        
        nameLabel.anchor(top: self.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, topPad: 24, leftPad: 16, bottomPad: 0, rightPad: 0, width: 0, height: 0)
        
        editProfileButton.anchor(top: nameLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil,  right: nil, topPad: 8, leftPad: 12, bottomPad: 0, rightPad: 0, width: 160, height: 35)
        
        socialStackView.anchor(top: profileImageView.bottomAnchor, left: leftAnchor,  bottom: nil, right: rightAnchor, topPad: 40, leftPad: 6, bottomPad: 4, rightPad: 6, width: 0, height: 0)
        
        selectionStackView.backgroundColor = .lightGray
        selectionStackView.axis = .horizontal
        selectionStackView.alignment = .center
        selectionStackView.distribution = .fillEqually
        
        
        topDivider.anchor(top: socialStackView.bottomAnchor, left: leftAnchor, bottom:  selectionStackView.topAnchor, right: rightAnchor, topPad: 2, leftPad: 0, bottomPad: 0, rightPad: 0, width: 0, height: 1)
        
        selectionStackView.anchor(top: nil, left: leftAnchor, bottom: bottomDivider.topAnchor, right: rightAnchor, topPad: 0, leftPad: 0, bottomPad: 0, rightPad: 0, width: 0, height: 52)
        
        bottomDivider.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topPad: 0, leftPad: 0, bottomPad: 0, rightPad: 0, width: 0, height: 1)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}















