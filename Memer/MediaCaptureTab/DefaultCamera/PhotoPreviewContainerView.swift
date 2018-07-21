//
//  PhotoPreviewContainerView.swift
//  Memer
//
//  Created by Nuri Chun on 5/16/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import UIKit
import Photos

class PhotoPreviewContainerView: UIView {
    
    let previewImageView: UIImageView = 
    {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
    
        return iv
    }()
    
//    let saveToPhotoLibrary: UIButton = {
//        let button = UIButton(type: .system)
////        button.setImage(<#T##image: UIImage?##UIImage?#>, for: <#T##UIControlState#>)
//
//        return button
//    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        setupPreviewUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - handleNextButton()
    
    
    
    // MARK: - handleBackButton()
    
    @objc func handleBackButton()
    {
        print("Back button has been pressed...")
        
//        self.removeFromSuperview()
    }
    
    private func setupPreviewUI()
    {
        addSubview(previewImageView)
        previewImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topPad: 0, leftPad: 0, bottomPad: 0, rightPad: 0, width: 0, height: 0)
    }
    
    
}


