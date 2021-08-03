//
//  MessagesTableViewCell.swift
//  FoodFriend
//
//  Created by Karam Ali.
//

import UIKit
import SDWebImage

class MessagesTableViewCell: UITableViewCell {
    
    static let indentifier = "MessagesTableViewCell"
    
    private let otherUserImage: UIImageView = {
        let image = UIImageView()
        image.layer.masksToBounds = true
        image.layer.cornerRadius = 40
        image.contentMode = .scaleAspectFill
        return image
        
    }()
    
    private let otherUserName: UILabel = {
        let userName = UILabel()
        userName.numberOfLines = 0
        userName.font = .systemFont(ofSize: 32, weight: .medium)
        return userName
    }()
    
    private let otherUserMessage: UILabel = {
        let userMessage = UILabel()
        userMessage.font = .systemFont(ofSize: 20, weight: .medium)
        return userMessage
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(otherUserImage)
        contentView.addSubview(otherUserName)
        //contentView.addSubview(otherUserMessage)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        otherUserImage.frame = CGRect(x: 9, y: 9, width: 80, height: 80)
        otherUserName.frame = CGRect(x: otherUserImage.right + 10, y: 10, width: contentView.width - 20 - otherUserImage.width, height: (contentView.height - 20)/3)
    }
    // the following code is to get the other user's profile picture and name to appear
    public func configure(with model: Conversation) {
        self.otherUserName.text = model.name
        self.otherUserMessage.text = model.latestMessage.message
        
        let path = "images/\(model.otherUserEmail)_profile_image.png"
        //all download image url from storage using path above
        StorageManager.storageManager.downloadURL(for: path, completion: {[weak self] photoResult in
            switch photoResult {
            case .success(let photURL):
                //if successful return image URL on main thread
                DispatchQueue.main.async {
                    self?.otherUserImage.sd_setImage(with: photURL, completed: nil)
                }
            case .failure(let errorMessage):
                print("Failure. error= \(errorMessage)")
            }
        })
    }
}
