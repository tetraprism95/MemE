//
//  UserProfileCell.swift
//  Memer
//
//  Created by Nuri Chun on 7/18/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import UIKit


class UserProfileCell: UICollectionViewCell {
    
    // MARK: - Post?
    
    var post: Post? {
        didSet {
            guard let photoImageUrl = self.post?.imageURL else { return }
            photoImageView.loadImage(urlString: photoImageUrl)
        }
    }

    // MARK: - UIImageView Property
    
    let photoImageView: ImageViewCache = {
        let iv = ImageViewCache()
        
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        
        return iv
    }()
    
    // MARK: - init(frame: CGRect)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupBackgroundUI()
        setupUI()
    }
    
    // MARK: - init(coder aDecoder: NSCodef)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: - Setup UI Function

extension UserProfileCell {
    
    private func setupBackgroundUI() {
        backgroundColor = .mainDark()
    }
    
    private func setupUI() {
        addSubview(photoImageView)
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topPad: 0, leftPad: 0, bottomPad: 0, rightPad: 0, width: 0, height: 0)
    }
}















