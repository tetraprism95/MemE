//
//  HomeFeedController.swift
//  Memer
//
//  Created by Nuri Chun on 5/2/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import UIKit
import Firebase

class HomeFeedController: UICollectionViewController, UICollectionViewDelegateFlowLayout, HomeCellDelegate
{
    var posts = [Post?]()
    //    var like: Int
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBarItems()
        NotificationCenter.default.addObserver(self, selector: #selector(handleMemeFeed), name: PostPhotoController.updateFeedNotification, object: nil)
        setupCollectionAttributes()
        fetchAllPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func handleMemeFeed() {
        handleRefresh()
    }
    
    @objc func handleRefresh() {
        posts.removeAll()
        fetchPosts()
    }
}

// MARK: - setup functions

extension HomeFeedController {
    
    // MARK: - setupCollectionAttributes()
    
    private func setupCollectionAttributes() {
        collectionView?.backgroundColor = .mainDark()
        collectionView?.register(HomeCell.self, forCellWithReuseIdentifier: Identification.postCellId)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        collectionView?.refreshControl = refreshControl
    }
    
    // MARK: - setupNavigationBarItems()
    
    private func setupNavigationBarItems() {
        navigationItem.title = "Meme Feed"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Cochin", size: 25) ??  UIFont.boldSystemFont(ofSize: 25), NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationController?.navigationBar.barTintColor = .mainDark()
    }
    
    private func fetchAllPosts() {
        fetchPosts()
    }
    
    private func fetchPosts() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        Database.fetchUser(withUID: currentUid) { (user) in
            self.fetchPostsWithUser(user: user)
            self.collectionView?.reloadData()
        }
    }
    
    private func fetchPostsWithUser(user: User) {
        
        let currentUserPostRef = Database.database().reference().child("posts").child(user.uid)
        currentUserPostRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let postDictionaries = snapshot.value as? [String : Any] else { return }

            postDictionaries.forEach({ (key, value) in
                
                guard let postDictionary = value as? [String : Any] else { return }
                
                var post = Post(user: user, dictionary: postDictionary)
                post.id = key
                
                guard let uid = Auth.auth().currentUser?.uid else { return }
                

                Database.database().reference().child("likes").child(key).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let value = snapshot.value as? Int, value == 1 {
                        post.hasLiked = true
                        post.likeCount += 1
                    } else {
                        post.hasLiked = false
                    }
    
                    self.posts.append(post)
                    self.collectionView?.reloadData()
                    
                }, withCancel: { (error) in
                    print("Failed to retrieve likes database", error)
                })
                
                // Check if the the currentUser has liked the post, key, if so count += 1 and update it.
                
                Database.database().reference().child("posts").child(uid).child(key).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let value = snapshot.value as? Int, value == 0 {
                        
                    }
                    
                    
                    
                    
                }, withCancel: { (error) in
                    print("error")
                })
            })
        }) { (error) in
            print("Not able to fetch User's posts")
        }
    }
}

// MARK: - HomeCellDelegate Protocol Methods

extension HomeFeedController {
    
    func didTapComment(forPost post: Post) {
        
        let commentsController = CommentsController(collectionViewLayout: UICollectionViewFlowLayout())
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    // MARK: - Properties
    
    func didTapLike(forCell cell: HomeCell) {
    
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        guard var post = posts[indexPath.item] else { return }
        guard let postId = post.id else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
    
        // False being default.
        // If false, it will be 1
        let values = [currentUid : post.hasLiked == true ? 0 : 1]
    
        Database.database().reference().child("likes").child(postId).updateChildValues(values) { (error,  ref) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
        
            post.hasLiked = !post.hasLiked

            if post.hasLiked == true {
                post.likeCount += 1
            } else{
                if post.likeCount > 0 {
                    post.likeCount -= 1
                } else {
                    post.likeCount -= 0
                }
            }
            
            let values = ["countLikes" : post.likeCount]

            Database.database().reference().child("posts").child(currentUid).child(postId).updateChildValues(values, withCompletionBlock: { (error, dataRef) in
                if let error = error {
                    print("Error failed to update like count", error)
                    return
                }
            })
            
            self.posts[indexPath.item] = post
            self.collectionView?.reloadItems(at: [indexPath])
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout Methods

extension HomeFeedController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identification.postCellId, for: indexPath) as! HomeCell

        cell.backgroundColor = .mainDark()
        cell.post = posts[indexPath.item]
        cell.delegate = self
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let viewWidth = view.frame.width
        let extraHeight = viewWidth / 3
        var height = viewWidth + extraHeight
        height += 50
        
        if let post = posts[indexPath.item] {

            let approximateWidthMemeCaptionLabel = view.frame.width - 8 - 6 - 3
            let approximateWidthMemeDescriptionLabel = view.frame.width - 6 - 6 - 3
            
            let memeCaptionSize = CGSize(width: approximateWidthMemeCaptionLabel, height: 1000)
            let memeDescriptionSize = CGSize(width: approximateWidthMemeDescriptionLabel, height: 1000)
            
            let attributes = [NSAttributedString.Key.font : UIFont.init(name: "ChalkboardSE-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)] 
            
            // usernameContainerView: H - 44
            // postImageView: H - 312.5
            // stackView: H - 30
            // pad dist between stackView and descriptionLabel: P - 4
            
            let estimatedMemeCaptionFrame = NSString(string: post.memeCaption!).boundingRect(with: memeCaptionSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            
            let estimatedMemeDescriptionFrame = NSString(string: post.memeDescription!).boundingRect(with: memeDescriptionSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            
//            let estimatedMemeDescriptionFrame
            
            return CGSize(width: view.frame.width, height: estimatedMemeCaptionFrame.height + 44 + 312.5 + 30 + estimatedMemeDescriptionFrame.height + 1 + 12 + 8 + 8)
        }
        return CGSize(width: viewWidth, height: 400)
    }
}
