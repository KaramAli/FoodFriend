//
//  MessageViewController.swift
//  FoodFriend
//
//  Created by Karam Ali.
//


import UIKit
import MessageKit
import InputBarAccessoryView
// MARK: Structures
struct Message: MessageType {
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}

extension MessageKind {
    var messageKindAsString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributedText"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
    }
}

struct Sender: SenderType {
    public var senderId: String
    public var senderPhotoURL: String
    public var displayName: String
    
}

class MessageViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
    
    public var isNewMessageLine = false
    
    public let otherUser: String
    private let conversationID: String?
    
    private var conversations = [Message]()
    
    private var sendingUser: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let useableEmail = FirebaseController.usableEmail(email: email)
        return Sender(senderId: useableEmail, senderPhotoURL: "", displayName: "display name")
    }

    public static var date: DateFormatter = {
        let dateFormat = DateFormatter()
        dateFormat.locale = .current
        dateFormat.dateStyle = .medium
        dateFormat.timeStyle = .long
        return dateFormat
    }()
    
    // MARK: Init
    init(with email: String, id: String?) {
        self.otherUser = email
        self.conversationID = id
        super.init(nibName: nil, bundle: nil)
        if let conversationID = conversationID {
            messageListener(messageID: conversationID, shouldScrollToBottom: true)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: viewDid
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        
    }
    // using messageId parameter retrieve associated messages
    private func messageListener(messageID: String, shouldScrollToBottom: Bool){
        FirebaseController.shared.retrieveAllMessages(with: messageID, completion: { [weak self] result in
            switch result {
            // add messages to messageLine
            case .success(let messageLine):
                guard !messageLine.isEmpty else {
                    //if messageLine is empty come here
                    return
                }
                // if message line is not empty come here
                self?.conversations = messageLine
                //bring back messages on main thread
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToLastItem()
                    }
                }
                case .failure(let errorMessage):
                print("\(errorMessage)")
            }
            
        } )
    }
    
    func currentSender() -> SenderType {
        if let sender = sendingUser {
            return sender
        }
        return Sender(senderId: "5341341", senderPhotoURL: "", displayName: "Dummy Sender")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return conversations[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return conversations.count
    }
    
    // Function to create unique messageID using the date, user email and other user email
    private func uniqueMessageId() -> String? {
        let date = Self.date.string(from: Date())
        guard let currentUser = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let useableUserEmail = FirebaseController.usableEmail(email: currentUser)
        let uniqueMessageID = "\(date)_\(otherUser)_\(useableUserEmail)"
        return uniqueMessageID
    }
    
    
    //MARK: Input Bar
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty, let uniqueMessageID = uniqueMessageId(), let sendingUser = self.sendingUser else {
            // if the message is empty come here
            return
        }
        let message = Message(sender: sendingUser, messageId: uniqueMessageID, sentDate: Date(), kind: .text(text))
        //Only if the message will be sent
        if isNewMessageLine {
            //if isNewMessageLine == true, new create message line first
            FirebaseController.shared.createNewMessagingLine(with: otherUser, firstMessage: message, otherUserName: self.title ?? "User", completion: { [weak self] success in
                if success {
                    self?.isNewMessageLine = false
                    print("success: message sent")
                } else {
                    print("failure: message did not send")
                }
            })
        } else {
            guard let conversationID = conversationID, let currentUserName = self.title else {
                return
            }
            //append to existing message line
            FirebaseController.shared.continueWithMessagingLine(to: conversationID, newMessage: message, userName: currentUserName, completion: {result in
                if result {
                    print("message sent successfully")
                } else {
                    print("message not sent")
                }
            })
        }
        
    }
}
