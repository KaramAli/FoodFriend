//
//  NewEntryViewController.swift
//  FoodFriend
//
//  Created by Karam Ali.
//

import UIKit
class NewEntryViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let titleTextField: UITextField = {
        let title = UITextField()
        title.autocapitalizationType = .none
        title.autocorrectionType = .no
        title.returnKeyType = .continue
        title.layer.cornerRadius = 15
        title.layer.borderWidth = 1
        title.layer.borderColor = UIColor.gray.cgColor
        title.placeholder = "Title..."
        title.backgroundColor = .white
        title.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        title.leftViewMode = .always
        return title
    }()
    
    private let diaryTextView: UITextView = {
        let diary = UITextView()
        diary.autocapitalizationType = .none
        diary.autocorrectionType = .no
        diary.returnKeyType = .continue
        diary.layer.cornerRadius = 15
        diary.text = "Your story goes here..."
        diary.backgroundColor = .white
        diary.isEditable = true
        diary.isSelectable = true
        diary.isScrollEnabled = true
        return diary
    }()
    
    private let imageViewOne: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "plus.circle.fill")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2.5
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()
    private let newEntryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.backgroundColor = .red
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        newEntryButton.addTarget(self, action: #selector(tapNewEntryButton), for: .touchUpInside)
        
        view.addSubview(scrollView)
        scrollView.addSubview(titleTextField)
        scrollView.addSubview(imageViewOne)
        scrollView.addSubview(diaryTextView)
        scrollView.addSubview(newEntryButton)
        
        imageViewOne.isUserInteractionEnabled  = true
        scrollView.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapAddPic))
        imageViewOne.addGestureRecognizer(gesture)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        titleTextField.frame = CGRect(x: 30, y: 0, width: scrollView.width-60, height: 52)
        imageViewOne.frame = CGRect(x: 0, y: titleTextField.bottom + 10, width: size, height: size)
        diaryTextView.frame = CGRect(x: 30, y: imageViewOne.bottom + 10, width: scrollView.width-60, height: 300)
        imageViewOne.layer.cornerRadius = imageViewOne.width/2.0
        newEntryButton.frame = CGRect(x: 30, y: diaryTextView.bottom + 10, width: scrollView.width-60, height: 52)
    }
    @objc private func tapNewEntryButton(){
        titleTextField.resignFirstResponder()
        diaryTextView.resignFirstResponder()
        guard let titleText = titleTextField.text, let diaryText = diaryTextView.text, !titleText.isEmpty, !diaryText.isEmpty else {
            return
        }
    }
    
    @objc private func tapAddPic() {
        presentPhotoActionSheet()
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil )
        guard let selectedImage = info[UIImagePickerController.InfoKey .editedImage] as? UIImage else {
            return
        }
        self.imageViewOne.image = selectedImage
    }
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Picture One", message: "How would you like to select a picture?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: {[weak self] _ in self?.presentCamera()}))
        actionSheet.addAction(UIAlertAction(title: "Choose", style: .default, handler: {[weak self] _ in self?.presentPhotoPicker()}))
        present(actionSheet, animated: true)
    }
    func presentCamera() {
        let viewController = UIImagePickerController()
        viewController.sourceType = .camera
        viewController.delegate = self
        viewController.allowsEditing = true
        present(viewController, animated: true)
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
