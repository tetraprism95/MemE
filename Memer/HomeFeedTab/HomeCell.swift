//
//  PostCell.swift
//  Memer
//
//  Created by Nuri Chun on 6/18/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import UIKit
import Firebase

protocol HomeCellDelegate {
    func didTapLike(forCell cell: HomeCell)
    func didTapComment(forPost post: Post)
}

class HomeCell: UICollectionViewCell {
    
    var delegate: HomeCellDelegate?
    var post: Post? {
        didSet {
            setupPostProfileImageCache()
            guard let postUrlString = self.post?.imageURL else { return }
            postImageView.loadImage(urlString: postUrlString)
        
            likeButton.setImage(post?.hasLiked == true ? #imageLiteral(resourceName: "likeButtonFilled").withRenderingMode(.alwaysOriginal) : #imageLiteral(resourceName: "LikeButtonLogo-2").withRenderingMode(.alwaysOriginal), for: .normal)
        
            usernameLabel.text = self.post?.user.username
            memeCaptionLabel.text = self.post?.memeCaption
            self.setupAttributedDescription()
            
            let attributedText = NSMutableAttributedString(string: "Likes: ", attributes: [NSAttributedStringKey.foregroundColor : UIColor.white, NSAttributedStringKey.font :  UIFont.boldSystemFont(ofSize: 15)])
            attributedText.append(NSAttributedString(string: "\(post?.likeCount ?? 0)", attributes:   [NSAttributedStringKey.foregroundColor : UIColor.rgb(r: 217, g: 215, b: 215)]))
            
            numberOfLikesButton.setAttributedTitle(attributedText, for: .normal)
 
            // memeDescriptionLabel
//            descriptionLabel.text = self.post?.memeDescription
            
        }
    }
    
    // MARK: - UIButton Closure Properties

    let settingsButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.rgb(r: 23, g: 82, b: 69)
        button.addTarget(self, action: #selector(handleSettingsButton), for: .touchUpInside)
        
        return button
    }()
    
    let numberOfLikesButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .right
        
//        let attributedText = NSMutableAttributedString(string: "Likes: ", attributes: [NSAttributedStringKey.foregroundColor : UIColor.white, NSAttributedStringKey.font :  UIFont.boldSystemFont(ofSize: 15)])
//        attributedText.append(NSAttributedString(string: "10,000", attributes: [NSAttributedStringKey.foregroundColor : UIColor.rgb(r: 217, g: 215, b: 215)]))
//
//        button.setAttributedTitle(attributedText, for: .normal)
        button.addTarget(self, action: #selector(handleNumberOfLikes), for: .touchUpInside)
        
        return button
    }()
    
    lazy var commentButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "CommentLogo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        
        return button
    }()
    
    lazy var likeButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "LikeButtonLogo-2").withRenderingMode(.alwaysOriginal), for: .normal)
        button.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        
        return button
    }()
    
    let shareButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ShareSteamLogo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.contentMode = .scaleAspectFill
    
        return button
    }()
    
    // MARK: - UIImageView Closure Properties
    
    let profileImageView: ImageViewCache = {
        
        let iv = ImageViewCache()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.layer.borderColor = UIColor.lightGray.cgColor
        iv.layer.borderWidth = 1.5
    
        return iv
    }()
    
    let postImageView: ImageViewCache = {
        
        let iv = ImageViewCache()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 10
        iv.layer.borderColor = UIColor.rgb(r: 156, g: 156, b: 156).cgColor
        iv.layer.borderWidth = 1.5
        
        return iv
    }()
    
    // MARK: - UILabel Closure Propeties
    
    let usernameLabel: UILabel = {
        
        let label = UILabel()
        label.text = "marcochun300"
        label.numberOfLines = 1
        label.textColor = UIColor.rgb(r: 217, g: 215, b: 215)
        
        return label
    }()
    
    let memeCaptionLabel: UILabel = {
        
        let label = UILabel()
        label.textColor = UIColor.rgb(r: 217, g: 215, b: 215)
        label.textAlignment = .left
        label.font = UIFont(name: "Futura-CondensedMedium", size: 25)
        label.numberOfLines = 4
        label.sizeToFit()
        
        return label
    }()
    
    let descriptionLabel: UILabel = {
        
        let label = UILabel()
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.text = "Welcome friend, this is your first meme post. Congratulations, you are now a Memer!"
        
        return label
    }()
    
    let creationDateLabel: UILabel = {
        
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "2 hours ago"
        label.textAlignment = .right
        label.textColor = UIColor.rgb(r: 217, g: 215, b: 215)
        
        return label
    }()
    
    // MARK: - Selector() Handle Methods
    
    @objc func handleComment() {
        guard let post = post else { return }
        delegate?.didTapComment(forPost: post)
    }
    
    @objc func handleLike() {
        
        delegate?.didTapLike(forCell: self)
    }
    
    @objc func handleNumberOfLikes() {
        print("You pressed Number of Likes Button")
    }
    
    @objc func handleSettingsButton() {
        print("You pressed Settings Button")
    }
    
    // MARK: - init(frame: CGRect)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK : - setupPostProfileImageCache() 
    
    private func setupPostProfileImageCache() {
        
        guard let profileUrl = self.post?.user.profileImageURL else { return }
        
        if self.post?.user.profileImageURL == "" {
            profileImageView.image = #imageLiteral(resourceName: "WillyWonka").withRenderingMode(.alwaysOriginal)
        } else {
            profileImageView.loadImage(urlString: profileUrl)
        }
    }
}

// MARK: - Method/Functions

extension HomeCell {
    
    // MARK: - setupUI()
    
    private func setupUI() {
        
        let viewWidth = self.frame.width
        
        // MARK: - setupUI() containerView
        
        let usernameContainerView = UIView()
        let cellDivier = UIView()
        
        cellDivier.backgroundColor = UIColor.black
        
        self.addSubview(usernameContainerView)
        usernameContainerView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topPad: 0, leftPad: 0, bottomPad: 0, rightPad: 0, width: 0, height: 44)
        
        // MARK: - setupUI() profileImageView
        
        usernameContainerView.addSubview(profileImageView)
        profileImageView.anchor(top: usernameContainerView.topAnchor, left: usernameContainerView.leftAnchor, bottom: usernameContainerView.bottomAnchor, right: nil, topPad: 2, leftPad: 4, bottomPad: 2, rightPad: 0, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        
        // MARK: - setupUI() usernameLabel
        
        usernameContainerView.addSubview(usernameLabel)
        usernameLabel.anchor(top: usernameContainerView.topAnchor, left: profileImageView.rightAnchor, bottom: usernameContainerView.bottomAnchor, right: nil, topPad: 2, leftPad: 4, bottomPad: 2, rightPad: 2, width: 0, height: 0)
        
        // MARK: - setupUI() creationDateLabel
        
        usernameContainerView.addSubview(creationDateLabel)
        creationDateLabel.anchor(top: usernameContainerView.topAnchor, left: usernameLabel.rightAnchor, bottom: usernameContainerView.bottomAnchor, right: usernameContainerView.rightAnchor, topPad: 2, leftPad: 2, bottomPad: 0, rightPad: 4, width: 0, height: 0)
        
        // MARK: - setupUI() memeCaptionLabel
        
        self.addSubview(memeCaptionLabel)
        memeCaptionLabel.anchor(top: usernameContainerView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topPad: 0, leftPad: 8, bottomPad: 0, rightPad: 6, width: 0, height: 0)
        
        // MARK: - setupUI() postImageView
        
        let sixthOfWidth = frame.size.width / 6
        let height = frame.size.width - sixthOfWidth
        
        print("height of postImageView: \(height)")
        
        let width = frame.width
        
        self.addSubview(postImageView)
        postImageView.anchor(top: memeCaptionLabel.bottomAnchor, left: leftAnchor, bottom:  nil, right: rightAnchor, topPad: 0, leftPad: 0, bottomPad: 0,  rightPad: 0, width: width, height: height)
        
        // MARK: - setupUI() stackView
        
        let stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, shareButton])
        
        self.addSubview(stackView)
        
        stackView.distribution = .fillEqually
        stackView.spacing = 2
        
        stackView.anchor(top: postImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, topPad: 8, leftPad: 2, bottomPad: 0, rightPad: 0, width: viewWidth / 2.5, height: 30)
        
        // MARK: - setupUI() numberOfLikes
        
        self.addSubview(numberOfLikesButton)
        numberOfLikesButton.anchor(top: postImageView.bottomAnchor, left: stackView.rightAnchor, bottom: nil, right: rightAnchor, topPad: 8, leftPad: 2, bottomPad: 0, rightPad: 4, width: 0, height: 30)
        
        // MARK: - descriptionLabel
        
        self.addSubview(descriptionLabel)
        descriptionLabel.anchor(top: stackView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topPad: 12, leftPad:  8, bottomPad: 0, rightPad: 6, width: 0, height: 0)
        
        // MARK: - cellDivider
        
        self.addSubview(cellDivier)
        cellDivier.anchor(top: descriptionLabel.bottomAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, topPad: 8, leftPad: 0, bottomPad: 4, rightPad: 0, width: 0, height: 1)
    }
    
    // MARK: - setupAttributedDescription
    
    private func setupAttributedDescription() {
        
        guard let post = self.post else { return }
        
        let attributedText = NSMutableAttributedString(string: post.user.username, attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: "  \(post.memeDescription ?? "")",    attributes: [NSAttributedStringKey.foregroundColor : UIColor.rgb(r: 217, g: 215,  b: 215)]))
        
        descriptionLabel.attributedText = attributedText
    }
}
















