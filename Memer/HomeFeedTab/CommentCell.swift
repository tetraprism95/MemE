//
//  CommentCell.swift
//  Memer
//
//  Created by Nuri Chun on 7/19/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import UIKit

class CommentCell: UICollectionViewCell {
    
    var comment: Comment? {
        didSet {
            
            guard let comment = comment else { return }
            
            let attributedText = NSMutableAttributedString(string: comment.user.username,  attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor.white])
            attributedText.append(NSMutableAttributedString(string: "  \(comment.text)", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)]))
            commentLabel.attributedText = attributedText
            
            profileImageView.loadImage(urlString: comment.user.profileImageURL)
        }
    }
    
    let commentLabel: UILabel = {
        
        let label = UILabel()
        label.backgroundColor = .mainDark()
        label.textColor = .white
        label.numberOfLines = 0
        
        
        return label
    }()
    
    let profileImageView: ImageViewCache = {
        
        let iv = ImageViewCache()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 40 / 2
        iv.layer.borderWidth = 1.0
        iv.layer.borderColor = UIColor.white.cgColor
        
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        setupBackroundColor()
        setupCommentUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension CommentCell {
    
    private func setupBackroundColor() {
        backgroundColor = .yellow
    }
    
    private func setupCommentUI() {
        
        addSubview(profileImageView)
        addSubview(commentLabel)
        
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, topPad: 4, leftPad: 4, bottomPad: 4, rightPad: 0, width: 40, height: 40)
        commentLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, topPad: 4, leftPad: 8, bottomPad: 4, rightPad: 4, width: 0, height: 0)
    }
}






