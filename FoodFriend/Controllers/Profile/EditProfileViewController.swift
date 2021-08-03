//
//  EditProfileViewController.swift
//  FoodFriend
//
//  Created by Karam Ali.
//

import UIKit

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
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
    
    private let editButton: UIButton = {
        let button = UIButton()
        button.setTitle("Edit Profile", for: .normal)
        button.backgroundColor = .red
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
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
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.clipsToBounds = true
        return scroll
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Edit Profile"
        view.backgroundColor = .white
        editButton.addTarget(self, action: #selector(tapEditButton), for: .touchUpInside)
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(preferenceOneField)
        scrollView.addSubview(preferenceTwoField)
        scrollView.addSubview(editButton)
        
        imageView.isUserInteractionEnabled  = true
        scrollView.isUserInteractionEnabled = true
        
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapChangeProfilePic))
        imageView.addGestureRecognizer(gesture)
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
        editButton.frame = CGRect(x: 30, y: preferenceTwoField.bottom + 10, width: scrollView.width-60, height: 52)
    }
    @objc private func tapChangeProfilePic() {
        presentPhotoActionSheet()
    }
    @objc private func tapEditButton() {
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        preferenceOneField.resignFirstResponder()
        preferenceTwoField.resignFirstResponder()
        guard let firstName = firstNameField.text,
              let lastName = lastNameField.text,
              let preferenceOne = preferenceOneField.text,
              let preferenceTwo = preferenceTwoField.text,
              !firstName.isEmpty,
              !lastName.isEmpty else {
            editProfileErrorAlert()
            return
        }
        print(preferenceOne)
        print(preferenceTwo)
        
    }
    
    func editProfileErrorAlert() {
        let alert = UIAlertController(title: "oops", message: "Please enter the correct information needed to create an account!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated:true)
    }
    
    
    
    //MARK: Photo Action Sheet
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
