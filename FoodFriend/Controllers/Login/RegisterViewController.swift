//
//  RegisterViewController.swift
//  FoodFriend
//
//  Created by Karam Ali.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class RegisterViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.clipsToBounds = true
        return scroll
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.fill")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2.5
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()
    
    private let firstNameField: UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .continue
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.placeholder = "First Name..."
        textField.backgroundColor = .white
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textField.leftViewMode = .always
        return textField
    }()
    
    private let lastNameField: UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .continue
        textField.layer.cornerRadius = 12
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.borderWidth = 1
        textField.placeholder = "Last Name..."
        textField.backgroundColor = .white
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textField.leftViewMode = .always
        return textField
    }()
    
    private let ageField: UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .continue
        textField.layer.cornerRadius = 12
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.borderWidth = 1
        textField.placeholder = "Age..."
        textField.backgroundColor = .white
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textField.leftViewMode = .always
        return textField
    }()
    
    private let preferenceOneField: UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .continue
        textField.layer.cornerRadius = 12
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.borderWidth = 1
        textField.placeholder = "First Preference..."
        textField.backgroundColor = .white
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textField.leftViewMode = .always
        return textField
    }()
    
    private let preferenceTwoField: UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .continue
        textField.layer.cornerRadius = 15
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.borderWidth = 1
        textField.placeholder = "Second Preference..."
        textField.backgroundColor = .white
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textField.leftViewMode = .always
        return textField
    }()
    
    private let emailField: UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .continue
        textField.layer.cornerRadius = 15
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.borderWidth = 1
        textField.placeholder = "Email... Must be unique"
        textField.backgroundColor = .white
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textField.leftViewMode = .always
        return textField
    }()
    
    private let passwordField: UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .done
        textField.layer.cornerRadius = 15
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.borderWidth = 1
        textField.placeholder = "Password... 6 characters or more"
        textField.backgroundColor = .white
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textField.leftViewMode = .always
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private let createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Create Account", for: .normal)
        button.backgroundColor = .red
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Account Creation"
        view.backgroundColor = .white
        createButton.addTarget(self, action: #selector(tapCreateButton), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(preferenceOneField)
        scrollView.addSubview(preferenceTwoField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(createButton)
        
        imageView.isUserInteractionEnabled  = true
        scrollView.isUserInteractionEnabled = true
        
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapChangeProfilePic))
        imageView.addGestureRecognizer(gesture)
    }
    
    @objc private func tapChangeProfilePic() {
        presentPhotoActionSheet()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (view.width-size)/2, y: 20, width: size, height: size)
        imageView.layer.cornerRadius = imageView.width/2.0
        firstNameField.frame = CGRect(x: 30, y: imageView.bottom + 10, width: scrollView.width-60, height: 52)
        lastNameField.frame = CGRect(x: 30, y: firstNameField.bottom + 10, width: scrollView.width-60, height: 52)
        preferenceOneField.frame = CGRect(x: 30, y: lastNameField.bottom + 10, width: scrollView.width-60, height: 52)
        preferenceTwoField.frame = CGRect(x: 30, y: preferenceOneField.bottom + 10, width: scrollView.width-60, height: 52)
        emailField.frame = CGRect(x: 30, y: preferenceTwoField.bottom + 10, width: scrollView.width-60, height: 52)
        passwordField.frame = CGRect(x: 30, y: emailField.bottom + 10, width: scrollView.width-60, height: 52)
        createButton.frame = CGRect(x: 30, y: passwordField.bottom + 10, width: scrollView.width-60, height: 52)
    }
    
    //Once the tapCreateButton pressed
    @objc private func tapCreateButton() {
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        preferenceOneField.resignFirstResponder()
        preferenceTwoField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        guard let firstName = firstNameField.text,
              let lastName = lastNameField.text,
              let preferenceOne = preferenceOneField.text,
              let preferenceTwo = preferenceTwoField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !firstName.isEmpty,
              !lastName.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              password.count >= 6 else {
            accountCreationErrorAlert()
            return
        }
        
        // check to see if the email provided exists in the database
        FirebaseController.shared.checkExistance(with: email, completion: {[weak self] exists in
            guard let strongSelf = self else {
                return
            }
            guard !exists else {
                return
            }
            // create user if the email does not already exist in the database
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: {authResult, error in
                guard let result = authResult, authResult != nil, error == nil else {
                    print("Account Creation Error")
                    return
                }
                
                // create user and add to firebase database using AppUser Struct
                FirebaseController.shared.createUser(with: AppUser(fName: firstName, lName: lastName, email: email, preferenceOne: preferenceOne, preferenceTwo: preferenceTwo), completion: { success in
                    if success {
                        
                        let user = AppUser(fName: firstName, lName: lastName, email: email, preferenceOne: preferenceOne, preferenceTwo: preferenceTwo)
                        //get pngData of profile image and put that into imageData
                        guard let userProfileImage = strongSelf.imageView.image, let imageData = userProfileImage.pngData() else {
                            return
                        }
                        
                        let imageFileName = user.profilePicture
                        //store image to firebase storage
                        StorageManager.storageManager.storeProfileImage(with: imageData, fileName: imageFileName, completion: {
                            result in
                            switch result {
                            case .success(let downloadUrl):
                                //also save profile picture to user defaults
                                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                print(downloadUrl)
                            case .failure(let error):
                                //any errors when storing profile picture to storage or user defaults and get sent here
                                print("Failure in Storage Manager. Error Code: \(error)")
                                
                            }
                        })
                    }
                })
                print(result.user)
                //dissmiss log in screen
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
        })
    }
    // accountExistsError is a function designed to give a personalised error message if account already exists it occurs
    func accountExistsErrorAlert() {
        let alert = UIAlertController(title: "oops", message: "This email already exists in the system", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated:true)
    }
    
    // accountCreationError is designed to give a personalised error message if there is an error with creating the account
    func accountCreationErrorAlert() {
        let alert = UIAlertController(title: "oops", message: "Please enter the correct information needed to create an account!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated:true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameField {
            lastNameField.becomeFirstResponder()
        }
        if textField == lastNameField {
            emailField.becomeFirstResponder()
        }
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            tapCreateButton()
        }
        
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil )
        guard let selectedImage = info[UIImagePickerController.InfoKey .editedImage] as? UIImage else {
            return
        }
        self.imageView.image = selectedImage
    }
    
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select a picture?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: {[weak self] _ in self?.presentCamera()}))
        actionSheet.addAction(UIAlertAction(title: "Choose", style: .default, handler: {[weak self] _ in self?.presentPhotoPicker()}))
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

