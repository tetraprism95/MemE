//
//  VideoController.swift
//  Memer
//
//  Created by Nuri Chun on 5/21/18.
//  Copyright © 2018 tetra. All rights reserved.
//

// MARK: - Imports

import UIKit
import Foundation
import AVFoundation
import Photos

// MARK: - Storyboard

struct Storyboard
{
    static let cellId = "photoCellId"
    static let headerId = "photoHeaderId"
}

// MARK: Protocol

protocol PhotoSelectorControllerDelegate {
    func setProfileImage(selectedImage: UIImage?)
}

// MARK: - PhotoSelectorController

class PhotoSelectorController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate
{
    // MARK: Controller instances
    
    var postPhotoController = PostPhotoController()
    var editProfileHeader = EditProfileHeader()
    var photoSelectorHeader = PhotoSelectorHeader()
    var delegate: PhotoSelectorControllerDelegate?
    
    // MARK: - Photos Framework Properties
    
    var assets = [PHAsset]()
    var images = [UIImage]()
    var selectedImage: UIImage?
    var forEditing = false
    
    convenience init(collectionViewLayout layout: UICollectionViewLayout, forEditing: Bool) {
        self.init(collectionViewLayout: layout)
        self.forEditing = forEditing
    }
    
    // MARK: - AnimatedTransitioning Properties and Class objects
    
    let animationPresentor = CustomAnimationPresentorLeft()
    let animationDismisser = CustomAnimationDismisserLeft() 
    
    // MARK: - Button Objects
    
    lazy var doneBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "done", style: .plain, target: self, action: #selector(handleDone))
        button.tintColor = .white
        
        return button
    }()
    
    lazy var cancelBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "cancel", style: .plain, target: self, action: #selector(handleCancelNav))
        
        button.tintColor = .white
        
        return button
    }()
    
    lazy var pickBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "pick", style: .plain, target: self, action: #selector(handlePick))
        
        button.tintColor = .white
        
        return button
    }()
    
    // MARK: - handleCancel()
    
    @objc func handleDone() {
        // Check if currentUser is in userProfileController
        // When done is pressed, the image will be saved to firebase, userProfileImage.
        // This will reflect all controllers that have userProfileImage.
        delegate?.setProfileImage(selectedImage: selectedImage)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleCancelNav() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handlePick() {
        navigationController?.pushViewController(postPhotoController, animated: true)
    }
    
    private func setupUI() {
        let dividerView = UIView()
        dividerView.backgroundColor = UIColor.black
    }

    // MARK: - prefersStatusBarHidden
    
    override var prefersStatusBarHidden: Bool {
        if self.forEditing {
            return false
        } else {
            return true
        }
    }
    
    // MARK: - viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transitioningDelegate = self
        
        setupNavigationItem()
        setupCollectionView()
        setupUI()
        fetchPhotos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Photo Album"
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - setupNavigationItem()

    private func setupNavigationItem() {
        if self.forEditing {
            navigationItem.rightBarButtonItem = doneBarButton
            navigationController?.navigationBar.titleTextAttributes =  [NSAttributedString.Key.foregroundColor : UIColor.white]
            navigationItem.setLeftBarButton(cancelBarButton, animated: true)
            navigationController?.navigationBar.tintColor = .mainDark()
        } else {
            navigationItem.rightBarButtonItem = pickBarButton
            navigationController?.navigationBar.titleTextAttributes =  [NSAttributedString.Key.foregroundColor : UIColor.white]
            navigationItem.setRightBarButton(pickBarButton, animated: true)
            navigationItem.setLeftBarButton(cancelBarButton, animated: true)
            navigationController?.navigationBar.barTintColor = .mainDark() 
        }
    }

    // MARK: - setupCollectionView()
    
    private func setupCollectionView() {
        collectionView?.backgroundColor = UIColor.rgb(r: 216, g: 216, b: 216)
        collectionView?.delegate = self
        collectionView?.register(PhotoSelectorCell.self, forCellWithReuseIdentifier: Storyboard.cellId)
        collectionView?.register(PhotoSelectorHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Storyboard.headerId)
    }
    
    // MARK: - PHFetchOptions
    
    private func fetchOptions() -> PHFetchOptions
    {
        let options = PHFetchOptions()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        options.sortDescriptors = [sortDescriptor]
        
        return options
    }
    
    // MARK: - FetchPhotos()
    
    private func fetchPhotos()
    {
        let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions())
        
        DispatchQueue.global(qos: .background).async {
            
            allPhotos.enumerateObjects({ (asset, count, stop) in
                
                let imageManager = PHImageManager()
                let imageSize = CGSize(width: 200, height: 200)
                
                let imageOptions = PHImageRequestOptions()
                
                imageOptions.isSynchronous = true
            
                imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFit, options: imageOptions, resultHandler: { (image, info) in
                    
                    // Check if there is an image
                    
                    if let image = image {
                        self.images.append(image)
                        self.assets.append(asset)
                    }
                    
                    if self.selectedImage == nil {
                        self.selectedImage = image
                    }
                    
                    // Once retreieved all photos, reload the collectionView
                    
                    if count == allPhotos.count - 1
                    {
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                        }
                    }
                })
            })
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension PhotoSelectorController
{
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Storyboard.cellId, for: indexPath) as! PhotoSelectorCell
        
        cell.photoImageView.image = images[indexPath.row]
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedImage = images[indexPath.row]
        self.collectionView?.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = (view.frame.width - 2) / 3
        
        print("ItemSize: \(itemSize)")
        
        return CGSize(width: itemSize, height: itemSize)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Storyboard.headerId, for: indexPath) as! PhotoSelectorHeader
        
        // Defining that the header controllers is assigned
        photoSelectorHeader = header
        
        header.mainPhotoImageView.image = selectedImage
        
        // checking if image which was selected is not nil
        if let selectedImage = selectedImage {
            if let index = self.images.index(of: selectedImage) {
                let asset = self.assets[index]
                
                let imageManager = PHImageManager()
                let imageSize = CGSize(width: 1000, height: 1000)
                
                imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: .default, options: nil) { (image, nil) in
                    header.mainPhotoImageView.image = image
                    self.postPhotoController.selectedImage = image
                }
            }
        }
        return header
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    }
}

// MARK: - UIViewControllerTransitioningDelegate Methods

extension PhotoSelectorController {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animationPresentor
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animationDismisser
    }
}






