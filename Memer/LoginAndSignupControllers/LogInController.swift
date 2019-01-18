//
//  SignInController.swift
//  Memer
//
//  Created by Nuri Chun on 5/9/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import UIKit
import Firebase

class LogInController: UIViewController
{
    // MARK: - UIBUTTON PROPERTIES
    
    let forgotPasswordButton: UIButton =
    {
        let button = UIButton(type: .system)
        
        let attributetedText = NSMutableAttributedString(string: "Forgot Password?  ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        
        attributetedText.append(NSAttributedString(string: "Reset", attributes: [NSAttributedString.Key.foregroundColor : UIColor.rgb(r: 240, g: 237, b: 237), NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)]))
        
        button.setAttributedTitle(attributetedText, for: .normal)
        
        button.addTarget(self, action: #selector(handleForgotPasswordButton), for: .touchUpInside)
        
        return button
    }()
    
    let signUpButton: UIButton =
    {
        let button = UIButton(type: .system)
        
        let attributedText = NSMutableAttributedString(string: "No Account?  ", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        
        attributedText.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor.rgb(r: 240, g: 237, b: 237)]))
        
        button.setAttributedTitle(attributedText, for: .normal)
        
        button.addTarget(self, action: #selector(handleSignUpButton), for: .touchUpInside)
        
        return button
    }()
    
    let facebookButton: UIButton =
    {
        let button = UIButton(type: .system)
        
        button.setImage(#imageLiteral(resourceName: "FLogo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.contentMode = .scaleAspectFit
        button.clipsToBounds = true
        
        button.addTarget(self, action: #selector(handleFBButton), for: .touchUpInside)
        
        return button
    }()
    
    let logInButton: UIButton =
    {
        let button = UIButton(type: .system)
        
        button.setTitle("Log In", for: UIControl.State.normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        button.layer.borderColor = UIColor.rgb(r: 86, g: 86, b: 86).cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 10
        button.isEnabled = false
        
        button.addTarget(self, action: #selector(handleLogInButton), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - UIIMAGEVIEW PROPERTIES
    
    let memeLogoImageView: UIImageView =
    {
        let iv = UIImageView(image: #imageLiteral(resourceName: "MemeLogo").withRenderingMode(.alwaysOriginal))
        
        iv.contentMode = .scaleAspectFit
        
        return iv
    }()
    
    // MARK: - TEXTFIELD PROPERTIES
    
    let emailTextField: UITextField =
    {
        let tf = UITextField()
        
        if let image = UIImage(named: "usernameIcon") {
           SignupController.setupIconAndTextField(image: image, textField: tf)
        }
        
         SignupController.setupTextFieldAttributes(tf: tf, placeholderText: "email")
        
        tf.addTarget(self, action: #selector(handleInfo), for: .editingChanged)
        
        return tf
    }()
    
    let passwordTextField: UITextField =
    {
        let tf = UITextField()
        
        tf.isSecureTextEntry = true
        
        if let image = UIImage(named: "passwordIcon") {
            SignupController.setupIconAndTextField(image: image, textField: tf)
        }
        
        SignupController.setupTextFieldAttributes(tf: tf, placeholderText: "password")
        
        tf.addTarget(self, action: #selector(handleInfo), for: .editingChanged)
        
        return tf
    }()
    
    // MARK: - handleInfo()
    
    @objc func handleInfo()
    {
        print("Handling Info")
        
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        
        if isFormValid
        {
            logInButton.isEnabled = true
            logInButton.setTitleColor(UIColor.rgb(r: 230, g: 216, b: 216), for: .normal)
            
        } else
        {
            logInButton.isEnabled = false
            logInButton.setTitleColor(UIColor.black, for: .normal)
        }
    }
    
    // MARK: - handleForgotPasswordButton()
    
    @objc func handleForgotPasswordButton()
    {
        print("Reset Password button has been pressed")
    }
    
    // MARK: - handleSignUpButton()
    
    @objc func handleSignUpButton()
    {
        print("Sign Up button has been pressed")
        
        let signUpController = SignupController()
        
        navigationController?.pushViewController(signUpController, animated: true)
    }
    
    // MARK: - handleFBButton()
    
    @objc func handleFBButton()
    {
        print("Facebook button has been pressed")
    }
    
    // MARK: - handleLogInButton()
    
    @objc func handleLogInButton()
    {
        print("Login button has been pressed")
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if let error = error
            {
                print("Login unsucessful: ", error)
                return
            }
            
            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
            
            mainTabBarController.setupNavigationControllers()
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - SETUP STATUS BAR STYLE
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - viewDidLoad()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        self.hideKeyboardByTap()
        
        createGradientLayer()
        setupUI()
        
        // Listen for keyboard events
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
 
    }
    
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
        
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification 
        {
            view.frame.origin.y = -keyboardRect.height
        } else {
            view.frame.origin.y = 0
        }
    }
    
    // MARK: - setupUI()
    
    private func setupUI()
    {
        // CREATING OBJECTS OF CLASSES
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField])
        let leftHalfDivider = UIView()
        let rightHalfDivider = UIView()
        
        // STACKVIEW SET PROPERTIES
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 2
        
        // DIVIDERS SET PROPERTIES
        leftHalfDivider.backgroundColor = UIColor.rgb(r: 240, g: 237, b: 237).withAlphaComponent(0.5)
        leftHalfDivider.isOpaque = false
        rightHalfDivider.backgroundColor = UIColor.rgb(r: 240, g: 237, b: 237).withAlphaComponent(0.5)
        rightHalfDivider.isOpaque = false
        
        // ADD SUBVIEWS FOR PARENT VIEW
        view.addSubview(memeLogoImageView)
        view.addSubview(stackView)
        view.addSubview(logInButton)
        view.addSubview(facebookButton)
        view.addSubview(leftHalfDivider)
        view.addSubview(rightHalfDivider)
        view.addSubview(signUpButton)
        view.addSubview(forgotPasswordButton)
        
        // ANCHOR THE SUBVIEWS
        memeLogoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        memeLogoImageView.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, topPad: 100, leftPad: 0, bottomPad: 0, rightPad: 0, width: 120, height: 120)
        
        stackView.anchor(top: memeLogoImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topPad: 100, leftPad: 40, bottomPad: 0, rightPad: 40, width: 0, height: 100)
        
        logInButton.anchor(top: stackView.bottomAnchor, left: view.leftAnchor, bottom: facebookButton.topAnchor, right: view.rightAnchor, topPad: 20, leftPad: 40, bottomPad: 30, rightPad: 40, width: 0, height: 45)
        
        facebookButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        facebookButton.anchor(top: logInButton.bottomAnchor, left: nil, bottom: signUpButton.topAnchor, right: nil, topPad: 30, leftPad: 0, bottomPad: 20, rightPad: 0, width: 50, height: 50)
        
        leftHalfDivider.anchor(top: logInButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: facebookButton.leftAnchor, topPad: 55, leftPad: 40, bottomPad: 0, rightPad: 10, width: 0, height: 1)
        
        rightHalfDivider.anchor(top: logInButton.bottomAnchor, left: facebookButton.rightAnchor, bottom: nil, right: view.rightAnchor, topPad: 55, leftPad: 10, bottomPad: 0, rightPad: 40, width: 0, height: 1)
        
        signUpButton.anchor(top: facebookButton.bottomAnchor, left: view.leftAnchor, bottom: forgotPasswordButton.topAnchor, right: view.rightAnchor, topPad: 20, leftPad: 40, bottomPad: 20, rightPad: 40, width: 0, height: 10)
        
        forgotPasswordButton.anchor(top: signUpButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topPad: 20, leftPad: 40, bottomPad: 0, rightPad: 40, width: 0, height: 10)
    }
    
    // MARK: - GradientLayer
    
    var gradientLayer: CAGradientLayer!
    
    private func createGradientLayer()
    {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor.lightGray.cgColor, UIColor.rgb(r: 86, g: 86, b: 86).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        self.view.layer.addSublayer(gradientLayer)
    }
    
    
}
