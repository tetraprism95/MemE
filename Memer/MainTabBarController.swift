//
//  ViewController.swift
//  Memer
//
//  Created by Nuri Chun on 4/30/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.delegate = self
        
        if Auth.auth().currentUser == nil {
            
            DispatchQueue.main.async {
                
                let loginController = LogInController()
                
                let navController = UINavigationController(rootViewController: loginController)
                
                self.present(navController, animated: true, completion: nil)
            }
            return
        }
        setupNavigationControllers()
    }
    
     func setupNavigationControllers()
    {
        let memeFeedNavController = navigationTabInputs(selectedImage: #imageLiteral(resourceName: "HomeFeedSelected").withRenderingMode(.alwaysOriginal), unselectedImage: #imageLiteral(resourceName: "HomeFeedUnselected").withRenderingMode(.alwaysOriginal), rootViewController:  HomeFeedController(collectionViewLayout: UICollectionViewFlowLayout())) 
        let memeCameraNavController = navigationTabInputs(selectedImage: #imageLiteral(resourceName: "CameraSelected").withRenderingMode(.alwaysOriginal), unselectedImage:#imageLiteral(resourceName: "CameraUnselected").withRenderingMode(.alwaysOriginal), rootViewController: CameraController())
        let userProfileNavController = navigationTabInputs(selectedImage: #imageLiteral(resourceName: "UserProfileSelected").withRenderingMode(.alwaysOriginal), unselectedImage: #imageLiteral(resourceName: "UserProfileUnselected").withRenderingMode(.alwaysOriginal), rootViewController: UserProfileController(collectionViewLayout: UICollectionViewFlowLayout()))

        tabBar.tintColor = UIColor.black
        
        viewControllers =
            [
            memeFeedNavController,
            memeCameraNavController,
            userProfileNavController
            ]
        
        guard let items = tabBar.items else { return }
        
        for item in items
        {
            item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -5, right: 0)
        }
        
        let navigationAppearance = UINavigationBar.appearance()
        
        navigationAppearance.barTintColor = .mainDark()
        UITabBar.appearance().barTintColor = .mainDark()
    }
    
    private func navigationTabInputs(selectedImage: UIImage, unselectedImage: UIImage, rootViewController: UIViewController = UIViewController()) ->  UINavigationController
    {
        let viewController = rootViewController
        
        let navController = UINavigationController(rootViewController: viewController)
        
        navController.tabBarItem.selectedImage = selectedImage
        navController.tabBarItem.image = unselectedImage
        
        return navController
    }
}

extension MainTabBarController
{
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool
    {
        let index = viewControllers?.index(of: viewController)
        
        if index == 1
        {
            // Implement a photoSelectorController as the default rootview => Which will also have 2 other tabs video or library.
            let cameraController = CameraController()
            
            let navController = UINavigationController(rootViewController: cameraController)
            
            self.present(navController, animated: true, completion: nil)
            
            return false
        }
        return true
    }
}

