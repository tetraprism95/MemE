//
//  PhotoHeaderCell.swift
//  Memer
//
//  Created by Nuri Chun on 5/22/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import Foundation
import UIKit
import Photos

class PhotoSelectorHeader: UICollectionViewCell
{
    
    let mainPhotoImageView: UIImageView =
    {
        let iv = UIImageView()
        
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupHeaderUI()
    }
    
    func setupHeaderUI()
    {
        addSubview(mainPhotoImageView)
        mainPhotoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right:  rightAnchor, topPad: 0, leftPad: 0, bottomPad: 0, rightPad: 0, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
