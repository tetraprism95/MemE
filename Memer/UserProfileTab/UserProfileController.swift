//
//  UserProfileController.swift
//  Memer
//
//  Created by Nuri Chun on 5/2/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import UIKit
import Firebase

struct Identification
{
    static let photoCellId = "photoCell"
    static let headerId = "headerId"
    
    // HomeFeed UICollectionViewController/Celll
    static let postCellId = "postCellId"
    
    // EditProfileController HeaderCell
    static let editProfileCellId = "editProfileCellId"
}

class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserProfileHeaderDelegate
{
    // MARK: - Properties
    
    var currentUser: User? {
        didSet {
            if let username = currentUser?.username {
                navigationItem.title = "\(username)"
            }
        }
    }
    
    var posts = [Post?]()
    var isGrid = true
    
    // MARK: - viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchProfileInfo()
        setupNavigationBarItems()
        setupCollectionAttributes()
        
    }
    
    // MARK: - viewWillAppear()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.tintColor = .mainDark()
        tabBarController?.tabBar.isHidden = false
    }
}

// Mark: - Setting Up NavigationBarItems

extension UserProfileController
{
    private func setupCollectionAttributes() {
        
        collectionView?.backgroundColor = .mainDark()
        collectionView?.register(UserProfileCell.self, forCellWithReuseIdentifier:  Identification.photoCellId)
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: Identification.headerId)
        collectionView?.register(HomeCell.self, forCellWithReuseIdentifier: Identification.postCellId)
    }
    
    private func setupNavigationBarItems() {
    
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font :  UIFont(name: "Cochin", size: 25) ??  UIFont.boldSystemFont(ofSize: 25), NSAttributedStringKey.foregroundColor : UIColor.white]
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "LogoutButton").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action:
            #selector(handleLogout))
    }
    
    @objc func handleLogout() {
        
        print("Logout button has been pressed.")
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { (action) in
            
            do {
                try Auth.auth().signOut()
                let loginController = LogInController()
                let navController = UINavigationController(rootViewController: loginController)
                
                self.present(navController, animated: true, completion: nil)
                
            } catch let signoutError {
                print("Cannot signout: ", signoutError)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Fetching Profile Information

extension UserProfileController {
    
    private func fetchProfileInfo() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        Database.fetchUser(withUID: currentUid) { (user) in
            self.currentUser = user
            self.fetchPostsFor(userUid: currentUid)
            self.collectionView?.reloadData()
        }
    }
    
    private func fetchPostsFor(userUid uid: String) {
        // Fetching the post by observing.
        
        let userPostRef = Database.database().reference().child("posts").child(uid)
        userPostRef.observe(.childAdded, with: { (snapshot) in
            // The UserProfileCell should be displayed in an orderly fashion, by creationDate.
            guard let dictionary = snapshot.value as? [String : Any] else { return }
            guard let user = self.currentUser else { return }
            
            let post = Post(user: user, dictionary: dictionary)
            
            self.posts.append(post)
            self.collectionView?.reloadData()
            
        }) { (error) in
            print("Error: \(error)")
        }
    }
}

// Mark: - UICollectionViewController: DataSource && Delegate/DelegateFlowLayout

extension UserProfileController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let viewWidth = view.frame.width
        let extraHeight = viewWidth / 3
        var height = viewWidth + extraHeight
        height += 50
        
        if isGrid {
            return CGSize(width: (view.frame.width / 3) - 1, height: 140)
        } else {
            if let post = posts[indexPath.item] {
                let approximateWidthMemeCaptionLabel = view.frame.width - 8 - 6 - 3
                let approximateWidthMemeDescriptionLabel = view.frame.width - 6 - 6 - 3
                
                let memeCaptionSize = CGSize(width: approximateWidthMemeCaptionLabel, height: 1000)
                let memeDescriptionSize = CGSize(width: approximateWidthMemeDescriptionLabel, height: 1000)
                
                let attributes = [NSAttributedStringKey.font : UIFont.init(name: "ChalkboardSE-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)]
                
                // usernameContainerView: H - 44
                // postImageView: H - 312.5
                // stackView: H - 30
                // pad dist between stackView and descriptionLabel: P - 4
                
                let estimatedMemeCaptionFrame = NSString(string: post.memeCaption!).boundingRect(with: memeCaptionSize,  options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
                
                let estimatedMemeDescriptionFrame = NSString(string: post.memeDescription!).boundingRect(with: memeDescriptionSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
                
                //            let estimatedMemeDescriptionFrame
                
                return CGSize(width: view.frame.width, height: estimatedMemeCaptionFrame.height + 44 + 312.5 + 30 + estimatedMemeDescriptionFrame.height + 1 + 12 + 8 + 8)
            }
        }
        return CGSize(width: viewWidth, height: 400)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if isGrid {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identification.photoCellId, for: indexPath) as! UserProfileCell
            cell.post = posts[indexPath.item]
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identification.postCellId, for: indexPath) as! HomeCell
            cell.post = posts[indexPath.item]
            cell.backgroundColor = .mainDark()
            
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Depending on which cell was tapped in UserProfileController, that cell will be presented in a new viewController.
        // We want to present here by displaying a new controller, and dismissing is it when needed.
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Identification.headerId, for: indexPath) as! UserProfileHeader
        
        header.delegate = self
        header.user = currentUser
    
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 250)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 1.5
    }
}

// MARK: - UserProfileHeaderDelegate Method

extension UserProfileController {
    
    func didTapEditProfile(forUser user: User?) {
        
        let editProfileController = EditProfileController(collectionViewLayout:  UICollectionViewFlowLayout())
        editProfileController.user = user
        
        self.navigationController?.pushViewController(editProfileController, animated: true)
    }
    
    func didTapGrid() {
        isGrid = true
        self.collectionView?.reloadData()
    }

    func didTapList() {
        isGrid = false
        self.collectionView?.reloadData()
    }
}




