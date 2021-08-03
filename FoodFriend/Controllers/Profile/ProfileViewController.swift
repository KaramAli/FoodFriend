//
//  ProfileViewController.swift
//  FoodFriend
//
//  Created by Karam Ali.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()

    private let logOutButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log Out", for: .normal)
        button.backgroundColor = .red
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        loginAuth()
        logOutButton.addTarget(self, action: #selector(tapLogOutButton), for: .touchUpInside)
        view.addSubview(scrollView)
        
        scrollView.addSubview(logOutButton)
        scrollView.isUserInteractionEnabled = true

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        logOutButton.frame = CGRect(x: 30, y: 300, width: scrollView.width-60, height: 52)
    }
    
    @objc private func tapLogOutButton(){
        do {
            //code to log user out of firebase and to naviagte them back to the login screen
            try FirebaseAuth.Auth.auth().signOut()
            let viewController = LoginViewController()
            let navigation = UINavigationController(rootViewController: viewController)
            navigation.modalPresentationStyle = .fullScreen
            present(navigation, animated: true)
        }
        catch {
            print("Log out failed")
        }
    }
    private func loginAuth(){
        // whenever the app is run and the user is on the profile screen it will check to see if the user is logged in to an account
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let viewController = LoginViewController()
            let navigation = UINavigationController(rootViewController: viewController)
            navigation.modalPresentationStyle = .fullScreen
            present(navigation, animated: false)
        }
    }
}

