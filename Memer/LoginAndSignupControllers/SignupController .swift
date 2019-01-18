//
//  SignupController .swift
//  Memer
//
//  Created by Nuri Chun on 5/8/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import UIKit
import Firebase

class SignupController: UIViewController, UITextFieldDelegate
{
    // MARK: - IMPORTANT PROPERTIES
    
    var containerView = UIView()
    var gradientLayer: CAGradientLayer!
    var activeTextField: UITextField?

    let scrollView: UIScrollView =
    {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        
        sv.alwaysBounceVertical = true
        
        return sv
    }()

    // MARK: - BUTTON PROPERTIES
    
    let haveAccountButton: UIButton =
    {
        let button = UIButton(type: .system)
        
        let attributedText = NSMutableAttributedString(string: "Have Account?  ", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: "Login", attributes: [NSAttributedString.Key.foregroundColor : UIColor.rgb(r: 240, g: 237, b: 237), NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)]))
        
        button.setAttributedTitle(attributedText, for: .normal)
        button.addTarget(self, action: #selector(handleHaveAccountButton), for: .touchUpInside)
        
        return button
    }()
    
    let signupButton: UIButton =
    {
        let button = UIButton(type: .system)
        
        button.setTitle("Sign Up", for: .normal) 
        
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        button.layer.borderColor = UIColor.rgb(r: 86, g: 86, b: 86).cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 10
        button.isEnabled = false
        
        button.addTarget(self, action: #selector(handleSignUpButton), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - IMAGEVIEW PROPERTIES
    
    let memeLogoImageView: UIImageView =
    {
        let iv = UIImageView(image: #imageLiteral(resourceName: "MemeLogo").withRenderingMode(.alwaysOriginal))
        iv.contentMode = .scaleAspectFit

        return iv
    }()
    
    let downArrowImageView: UIImageView =
    {
        let iv = UIImageView(image: #imageLiteral(resourceName: "downArrowIcon").withRenderingMode(.alwaysOriginal))
        iv.contentMode = .scaleAspectFit
        
        return iv
    }()
    
    // MARK: - TEXTFIELD PROPERTIES
    
    let usernameTextField: UITextField =
    {
        let tf = UITextField()
        
        if let image = UIImage(named: "usernameIcon") {
            setupIconAndTextField(image: image, textField: tf)
        }
        
        setupTextFieldAttributes(tf: tf, placeholderText: "username")
        
        tf.addTarget(self, action: #selector(handleInfo), for: .editingChanged)
        
        return tf
    }()
    
    let fullnameTextField: UITextField =
    {
        let tf = UITextField()
        
        if let image = UIImage(named: "fullnameIcon") {
            setupIconAndTextField(image: image, textField: tf)
        }
        
        setupTextFieldAttributes(tf: tf, placeholderText: "full-name")
        tf.addTarget(self, action: #selector(handleInfo), for: .editingChanged)
        
        return tf
    }()
    
    let emailTextField: UITextField =
    {
        let tf = UITextField()
        
        if let image = UIImage(named: "emailIcon") {
            setupIconAndTextField(image: image, textField: tf)
        }
        
        setupTextFieldAttributes(tf: tf, placeholderText: "SteveJobs@Gmail.com")
        tf.addTarget(self, action: #selector(handleInfo), for: .editingChanged)
        
        return tf
    }()
    
    let passwordTextField: UITextField =
    {
        let tf = UITextField()
    
        if let image = UIImage(named: "passwordIcon") {
            setupIconAndTextField(image: image, textField: tf)
        }
        
        setupTextFieldAttributes(tf: tf, placeholderText: "password")
        tf.addTarget(self, action: #selector(handleInfo), for: .editingChanged)
        
        tf.isSecureTextEntry = true

        return tf
    }()
    
    let passwordConfirmationTextField: UITextField =
    {
        let tf = UITextField()
        
        if let image = UIImage(named: "passwordIcon") {
            setupIconAndTextField(image: image, textField: tf)
        }
        
        setupTextFieldAttributes(tf: tf, placeholderText: "confirm password")
        tf.addTarget(self, action: #selector(handleInfo), for: .editingChanged)
        
        tf.isSecureTextEntry = true
        
        return tf
    }()
    
    // MARK: - handleInfo()
    
    @objc func handleInfo()
    {
        let isFormValid = usernameTextField.text?.count ?? 0 > 0
            && fullnameTextField.text?.count ?? 0 > 0
            && emailTextField.text?.count ?? 0 > 0
            && passwordTextField.text?.count ?? 0 > 0
            && passwordConfirmationTextField.text?.count ?? 0 > 0
        
        if isFormValid
        {
            signupButton.isEnabled = true
            signupButton.setTitleColor(UIColor.rgb(r: 230, g: 216, b: 216), for: .normal)
        } else {
            signupButton.isEnabled = false
            signupButton.setTitleColor(UIColor.black, for: .normal)
        }
    }
    
    // MARK: - handleHaveAccountButton()
    
    @objc func handleHaveAccountButton()
    {
        print("Have Account button has been pressed")
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - handleSignUpButton()
    
    @objc func handleSignUpButton()
    {
        guard let email = emailTextField.text, email.count > 0 else { return }
        guard let password = passwordTextField.text, password.count > 5 else { return }
        guard let username = usernameTextField.text, username.count > 5 else { return }
        guard let fullname = fullnameTextField.text, fullname.count > 1 else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error
            {
                print("Error: ", error)
                return
            }
            
            
            guard let uid = user?.user.uid else { return }
            
            let dictionaryValues = ["email" : email, "username" : username, "fullname" : fullname]
            
            let values = [uid : dictionaryValues]
            
            Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (error, ref) in
                if let error = error
                {
                    print("Failed to save to users database: ", error)
                    return
                }
                
                guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
                
                mainTabBarController.setupNavigationControllers()
                
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    // MARK: - preferredStatusBarStyle
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardByTap()
    
        // ScrollView Implement?
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.width)
        
//         Set the notification to listen to any possible event triggers.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        setupTextFieldDelegate()
        createGradientLayer()
        setupUI()
    }
    
    // MARK: - deinit
    
    deinit
    {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    
    // MARK: - keyboardWillChange()
    
    @objc func keyboardWillChange(notification: Notification)
    {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        let keyboardHeight = keyboardRect.height
        
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification
        {
            UIView.animate(withDuration: 0.5) {
                if self.activeTextField == self.usernameTextField || self.activeTextField == self.fullnameTextField
                {
                    self.view.frame.origin.y = 0
                } else {
                    self.view.frame.origin.y = -keyboardHeight + 150
                }
            }
        } else {
            UIView.animate(withDuration: 0.5) {
                self.view.frame.origin.y = 0
            }
        }
    }

    // MARK: - setupTextFields()
    
    private func setupUI()
    {
        let divider = UIView()
        let stackView = UIStackView(arrangedSubviews: [usernameTextField, fullnameTextField])
        let stackView2 = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, passwordConfirmationTextField])
        
        // DIVIDER
        divider.backgroundColor = .black
        
        // FIRST STACK
        stackView.distribution = .fillEqually
        stackView.spacing = 2
        stackView.axis = .vertical
        
        // SECOND STACK
        stackView2.distribution = .fillEqually
        stackView2.spacing = 2
        stackView2.axis = .vertical
        
        // MainView ==> scrollView ==> subViews inside scrollView (UIs)
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        
        containerView.addSubview(memeLogoImageView)
        containerView.addSubview(divider)
        containerView.addSubview(stackView)
        containerView.addSubview(stackView2)
        containerView.addSubview(downArrowImageView)
        containerView.addSubview(signupButton)
        containerView.addSubview(haveAccountButton)
        
        scrollView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topPad: 0, leftPad: 0, bottomPad: 0, rightPad: 0, width: 0, height: 0)
        
        containerView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        containerView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor, topPad: 0, leftPad: 0, bottomPad: 0, rightPad: 0, width: view.frame.width, height: view.frame.height)
        
        // ANCHORING
        memeLogoImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        memeLogoImageView.anchor(top: containerView.topAnchor, left: nil, bottom: nil, right: nil, topPad: 35, leftPad: 0, bottomPad: 10, rightPad: 0, width: 120, height: 120)
        
        divider.anchor(top: stackView.bottomAnchor, left: containerView.leftAnchor, bottom: stackView2.topAnchor, right: containerView.rightAnchor, topPad: 20, leftPad: 40, bottomPad: 20, rightPad: 40, width: 0, height: 2)
    
        stackView.anchor(top: memeLogoImageView.bottomAnchor, left: containerView.leftAnchor, bottom: divider.topAnchor, right: containerView.rightAnchor, topPad: 30, leftPad: 40, bottomPad: 20, rightPad: 40, width: 0, height: 100)
        
        stackView2.anchor(top: divider.bottomAnchor, left: containerView.leftAnchor, bottom: downArrowImageView.topAnchor, right: containerView.rightAnchor, topPad: 20, leftPad: 40, bottomPad: 20, rightPad: 40, width: containerView.frame.width, height: 150)
        
        downArrowImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        downArrowImageView.anchor(top: stackView2.bottomAnchor, left: nil, bottom: nil, right: nil, topPad: 20, leftPad: 0, bottomPad: 0, rightPad: 0, width: 40, height: 40)
        
        signupButton.anchor(top: downArrowImageView.bottomAnchor, left: containerView.leftAnchor, bottom: haveAccountButton.topAnchor, right: containerView.rightAnchor, topPad: 10, leftPad: 40, bottomPad: 20, rightPad: 40, width: 0, height: 50)
        
        haveAccountButton.anchor(top: signupButton.bottomAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, topPad: 20, leftPad: 40, bottomPad: 0, rightPad: 40, width: 0, height: 10)
    }
    
    // MARK: - setupIconsAndTextField()
    
    class func setupIconAndTextField(image: UIImage, textField: UITextField)
    {
        // CREATE A VIEW && set image rendering mode to .alwaysOriginal
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        image.withRenderingMode(.alwaysOriginal)
        
        // Set the textField to have a left view mode always && set imageView width and height.
        textField.leftViewMode = .always
        let imageView = UIImageView(frame: CGRect(x: 0, y: 6, width: 26, height: 24))
        let image = image
        imageView.image = image
        
        // (1) Add imageView inside View
        // (2) Add View inside textField
        view.addSubview(imageView)
        textField.addSubview(view)
        
        // Then constraint the view to the left view, which is view.
        textField.leftView = view
        textField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0)
    }
    
    // MARK: - setupTextFieldAttributes()
    
    class func setupTextFieldAttributes(tf: UITextField, placeholderText: String)
    {
        tf.font = UIFont.boldSystemFont(ofSize: 14)
        tf.layer.borderWidth = 1.0
        tf.textAlignment = .left
        tf.textColor = .white
        tf.layer.borderColor = UIColor.rgb(r: 86, g: 86, b: 86).cgColor
        tf.layer.cornerRadius = 10
        tf.placeholder = "\(placeholderText)"
    }
    
    // MARK: - GradientLayer
    
    private func createGradientLayer()
    {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor.lightGray.cgColor, UIColor.rgb(r: 86, g: 86, b: 86).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        view.layer.addSublayer(gradientLayer)
    }
}

// MARK: - TextFieldDelegate Methods

extension SignupController
{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        activeTextField = textField
        
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        activeTextField?.resignFirstResponder()
        activeTextField = nil

        return true
    }

    private func setupTextFieldDelegate()
    {
        usernameTextField.delegate = self
        fullnameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        passwordConfirmationTextField.delegate = self
    }
}





