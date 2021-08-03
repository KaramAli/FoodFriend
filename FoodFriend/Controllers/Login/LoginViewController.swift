//
//  LoginViewController.swift
//  FoodFriend
//
//  Created by Karam Ali.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate{
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 15
        field.layer.borderColor = UIColor.gray.cgColor
        field.layer.borderWidth = 1
        field.placeholder = "Email..."
        field.backgroundColor = .white
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 15
        field.layer.borderColor = UIColor.gray.cgColor
        field.layer.borderWidth = 1
        field.placeholder = "Password..."
        field.backgroundColor = .white
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.isSecureTextEntry = true
        return field
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log In"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(registerButtonPressed))
        loginButton.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)

        
        emailField.delegate = self
        passwordField.delegate = self
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (view.width-size)/2, y: 120, width: size, height: size)
        emailField.frame = CGRect(x: 30, y: imageView.bottom + 75, width: scrollView.width-60, height: 50)
        passwordField.frame = CGRect(x: 30, y: emailField.bottom + 20, width: scrollView.width-60, height: 50)
        loginButton.frame = CGRect(x: 30, y: passwordField.bottom + 50, width: scrollView.width-60, height: 50)
    }
    
    @objc private func registerButtonPressed(){
        let viewController = RegisterViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func loginButtonPressed() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            loginErrorAlert()
            return
        }
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self ] authResult, error in
            guard let strongSelf = self else {
                return
            }
            guard error == nil, authResult != nil else {
                print("User Log In Error")
                return
            }
            // convert email to useable email
            let useableEmail = FirebaseController.usableEmail(email: email)
            // use useable email to get user infromation
            FirebaseController.shared.getInfo(path: useableEmail, completion: { result in
                switch result {
                case .success(let retrievedInfo):
                    //if successful get data from path and set it in retrievedInfo
                    guard let userInfo = retrievedInfo as? [String: Any], let firstName = userInfo["firstName"] as? String, let lastName = userInfo["lastName"] as? String else {
                        return
                    }
                    // use first name and last name to create constant name
                    let name = "\(firstName) \(lastName)"
                    // add name to user defaults
                    UserDefaults.standard.set(name, forKey: "name")
                    
                case .failure(let error):
                    print("\(error)")
                }
            })
            
            UserDefaults.standard.set(email, forKey: "email")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    func loginErrorAlert(){
        let alert = UIAlertController(title: "oops", message: "Please eneter the correct information to log in!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated:true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            loginButtonPressed()
        }
        return true
    }
    
}
