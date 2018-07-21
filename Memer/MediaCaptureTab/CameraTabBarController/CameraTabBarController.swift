//
//  CameraTabBarController.swift
//  Memer
//
//  Created by Nuri Chun on 7/7/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import UIKit

class CameraTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    let presentorLeft = CustomAnimationPresentorLeft()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        setupNavigationControllers()
        selectedIndex = 1
    }
    
    // MARK: - setupNavigationControllers()
    
    private func setupNavigationControllers() {
        // Consist of three controllers
        let layout = UICollectionViewFlowLayout()
        layout.sectionHeadersPinToVisibleBounds = true
        
        let photoSelectorController = PhotoSelectorController(collectionViewLayout: layout)
        photoSelectorController.navigationItem.title = "Photo Library"
        photoSelectorController.navigationController?.navigationBar.tintColor = .white
        
        let photoLibraryNavController = navigationTabInput(unselectedImage: #imageLiteral(resourceName: "albumUnselected").withRenderingMode(.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "albumSelected").withRenderingMode(.alwaysOriginal), rootViewController: photoSelectorController)
        
        let cameraController = CameraController()
        cameraController.navigationItem.title = "Camera"
        
        let cameraNavController = navigationTabInput(unselectedImage: #imageLiteral(resourceName: "cameraUnselected-1").withRenderingMode(.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "cameraSelected-1").withRenderingMode(.alwaysOriginal) , rootViewController: cameraController)
        
        let videoController = VideoController()
        videoController.navigationItem.title = "Video"
        
        let videoNavController = navigationTabInput(unselectedImage: #imageLiteral(resourceName: "videoUnselected").withRenderingMode(.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "videoSelected-1").withRenderingMode(.alwaysOriginal), rootViewController: videoController)
        
        tabBar.tintColor = UIColor.rgb(r: 99, g: 99, b: 99)
        
        viewControllers = [photoLibraryNavController, cameraNavController, videoNavController]
        
        guard let items = tabBar.items else { return }
        
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -10, right: 0)
        }
    }
    
    // MARK: - navigationTabInput()
    
    private func navigationTabInput(unselectedImage: UIImage?, selectedImage: UIImage?, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        
        let viewController = rootViewController
        
        let navController = UINavigationController(rootViewController: viewController)
        
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        
        return navController
    }
}

// MARK: - extension

extension CameraTabBarController {
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentorLeft
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension CameraTabBarController {
    
}







