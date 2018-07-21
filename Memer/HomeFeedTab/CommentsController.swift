//
//  CommentsController.swift
//  Memer
//
//  Created by Nuri Chun on 7/19/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import UIKit
import Firebase

class CommentsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var post: Post?
    var comments = [Comment]()
    let commentCellId = "commentCellId"
    
    lazy var containerView: UIView = {
        
        let cv = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        cv.backgroundColor = .white
        cv.backgroundColor  = .mainDark()
        
        let lineDividerView = UIView()
        lineDividerView.backgroundColor = .white
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
    
        cv.addSubview(sendButton)
        sendButton.anchor(top: cv.topAnchor, left: nil, bottom: cv.bottomAnchor, right: cv.rightAnchor, topPad: 0, leftPad: 0, bottomPad: 0, rightPad: 0, width: 50, height: 0)
        
        cv.addSubview(commentTextField)
        commentTextField.anchor(top: cv.topAnchor, left: cv.leftAnchor, bottom: cv.bottomAnchor, right: sendButton.leftAnchor, topPad: 0, leftPad: 12, bottomPad: 0, rightPad: 0, width: 0, height: 0)
        
        cv.addSubview(lineDividerView)
        lineDividerView.anchor(top: cv.topAnchor, left: cv.leftAnchor, bottom: nil, right: cv.rightAnchor, topPad: 0, leftPad: 0, bottomPad: 0, rightPad: 0, width: 0, height: 0.5)
        
        return cv
    }()
    
    let commentTextField: UITextField = {
        
        let tf = UITextField()
        tf.backgroundColor = .mainDark()
        tf.textColor = .white
        tf.attributedPlaceholder = NSAttributedString(string: "Enter text here..", attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
        
        return tf
    }()
    
    // Selector Methods
    
    @objc func handleSend() {
        print("Handle Send...")
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let postId = self.post?.id ?? ""
        let values = ["text" : commentTextField.text ?? "", "creationDate": Date().timeIntervalSince1970, "uid" : currentUid] as [String : Any]
        
        Database.database().reference().child("comments").child(postId).childByAutoId().updateChildValues(values) { (error, ref) in
            if let error = error {
                print("Error: \(error)")
            }
        }
        
        commentTextField.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardByTap()
        setupTitle()
        setupBackgroundColor()
        setupCollectionAttributes()
        fetchComments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }

    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
}

// MARK: - FUNCTIONS/METHODS

extension CommentsController {
    
    private func setupTitle() {
        title = "Comments"
    }
    
    private func setupBackgroundColor() {
        collectionView?.backgroundColor = .mainDark()
    }
    
    private func setupCollectionAttributes() {
        collectionView?.register(CommentCell.self, forCellWithReuseIdentifier: commentCellId)
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
    }
    
    private func fetchComments() {
        
        guard let postId = self.post?.id else { return }
        
        Database.database().reference().child("comments").child(postId).observe(.childAdded, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String : Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            
            Database.fetchUser(withUID: uid, completion: { (user) in
                let comment = Comment(user: user, dictionary: dictionary)
                self.comments.append(comment)
                self.collectionView?.reloadData()
            })
        }) { (error) in
            print("Could not fetch comments")
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CommentsController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: commentCellId, for: indexPath) as! CommentCell
        cell.comment = comments[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let dummyCellHeight = CGRect(x: 0, y: 0, width: view.frame.width, height: 75)
        let dummyCell = CommentCell(frame: dummyCellHeight)

        dummyCell.comment = comments[indexPath.item]
        dummyCell.layoutIfNeeded()

        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedCell = dummyCell.systemLayoutSizeFitting(targetSize)
        let heightAdjusted = max(48, estimatedCell.height)
        
        return CGSize(width: view.frame.width, height: heightAdjusted)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}











