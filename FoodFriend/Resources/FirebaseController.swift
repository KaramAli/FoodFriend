//
//  FirebaseController.swift
//  FoodFriend
//
//  Created by Karam Ali.
//

import Foundation
import FirebaseDatabase


final class FirebaseController {
    static let shared = FirebaseController()
    private let database = Database.database().reference()
    //Firebase does not like "@" and "."
    static func usableEmail(email: String) -> String {
        var useableEmail = email.replacingOccurrences(of: ".", with: " ")
        useableEmail = useableEmail.replacingOccurrences(of: "@", with: "-")
        return useableEmail
    }

// MARK: User Management
    //Function to create user in firebase
    public func createUser(with appUser: AppUser, completion: @escaping (Bool) -> Void){
        // Create user using the email as identifier with the following values
        database.child(appUser.useableEmail).setValue(["firstName": appUser.fName, "lastName": appUser.lName, "preferenceOne": appUser.preferenceOne, "preferenceTwo": appUser.preferenceTwo], withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            //also append the user under the users array if users array already exists
            self.database.child("users").observeSingleEvent(of: .value, with: {
                snapshot in
                if var users = snapshot.value as? [[String: String]] {
                    let newUser = ["name": appUser.fName + " " + appUser.lName, "email": appUser.useableEmail]
                    // new user is added into array here
                    users.append(newUser)
                    self.database.child("users").setValue(users, withCompletionBlock: { errors, _ in
                        guard errors == nil else {
                            // if instance of user in users is not created return completion false
                            completion(false)
                            return
                        }
                        // if user is added under users in database come here
                        completion(true)
                    })
                    
                }
                else {
                //create user collection if it does not already exist and add the first user into the user collection
                    let newCollection: [[String: String]] = [["name": appUser.fName + " " + appUser.lName, "email": appUser.useableEmail]]
                    self.database.child("users").setValue(newCollection, withCompletionBlock: { errors, _ in
                        guard errors == nil else {
                            // if users collection is not created come here
                            completion(false)
                            return
                        }
                        //user collection successfully created in firebase and first user is added
                        completion(true)
                    })
                }
            })
            
        })
    }
    
    // Function to check to see if a user already exists in firebase
    public func checkExistance(with email: String, completion: @escaping ((Bool) -> Void)) {
        // firebase does not like "@" or "."
        var usuableEmail = email.replacingOccurrences(of: ".", with: " ")
        usuableEmail = usuableEmail.replacingOccurrences(of: "@", with: "-")
        // search in firebase using the unique email identifier
        database.child(usuableEmail).observeSingleEvent(of: .value, with: { instance in
            guard instance.value as? String != nil else {
                // if a user already exists with the same email return false
                completion(false)
                return
            }
            //if there is no instance of email in firebase completion is true
            completion(true)
        })
    }
    
    
    // Fetch a list of users from users collection
    public func fetchUserList(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let results = snapshot.value as? [[String: String]] else {
                // if the result is anything except collection of a collection come into this guard and fail
                completion(.failure(Errors.fetchFailed))
                return
            }
            // if user collection from firebase is collected come here
            completion(.success(results))
        })
    }
    
    // a function to get info from the database colelction using a path
    public func getInfo(path: String, completion: @escaping (Result<Any, Error>) -> Void) {
        //go to the collection that is under the path given and set its contents as dataSnapshot
        self.database.child("\(path)").observeSingleEvent(of: .value){ dataSnapshot in
            guard let result = dataSnapshot.value else {
                // if result does not have a value then come here
                completion(.failure(Errors.fetchFailed))
                return
            }
            //if result now equals the data from the database in path come here
            completion(.success(result))
            
        }
    }
    
    
    // MARK: Message Management
    // Create new convesation if one does not already exist
    public func createNewMessagingLine(with otherUser: String, firstMessage: Message, otherUserName: String, completion: @escaping (Bool) -> Void){
        // save the current user's email and the current user's name in user defaults
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String, let currentUserName = UserDefaults.standard.value(forKey: "name") as? String else {
            // if user defaults save cannot occur come here
                return
        }
        // change current user's email to a useable email so that it can be used in Firebase
        let useableEmail = FirebaseController.usableEmail(email: currentEmail)
        // set reference to the path to the current users collection
        let reference = database.child("\(useableEmail)")
        // set result as the data under path
        reference.observeSingleEvent(of: .value, with: { [weak self] result in
            //give variable the data from result as a collection
            guard var node = result.value as? [String: Any] else {
                completion(false)
                return
            }
            var messageDetail  = ""
            switch firstMessage.kind {
            
            case .text(let messageText):
                messageDetail = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let date = firstMessage.sentDate
            let dateToString = MessageViewController.date.string(from: date)
            //let newConversation array and with the following data
            //this will be added to the current user conversations collection
            let newConversation: [String: Any] = ["id": "conversations_\(firstMessage.messageId)", "other_user_email": otherUser, "other_user_name": otherUserName, "latest_message": ["date": dateToString, "message": messageDetail, "is_read": false]]
            
            //let otherUserConversation array and with the following data
            //this will be added to the other users conversation collection
            let otherUserNewConversation: [String: Any] = ["id": "conversations_\(firstMessage.messageId)", "other_user_email": useableEmail, "other_user_name": currentUserName, "latest_message": ["date": dateToString, "message": messageDetail, "is_read": false]]
            
            //set path as the other user's conversation collection
            self?.database.child("\(otherUser)/conversations").observeSingleEvent(of: .value, with: { [weak self] result in
                if var messageLine = result.value as? [[String: Any]] {
                    //append to the conversation for other user
                    messageLine.append(otherUserNewConversation)
                    self?.database.child("\(otherUser)/conversations").setValue("conversations_\(firstMessage.messageId)")
                } else {
                    //create conversation for the other user
                    self?.database.child("\(otherUser)/conversations").setValue([otherUserNewConversation])
                    print([[otherUserNewConversation]])
                }
            })
            
            if var conversationArray = node["conversations"] as? [[String: Any]] {
                // conversation array exists and we append here
                conversationArray.append(newConversation)
                print(newConversation)
                node["conversations"] = conversationArray
                reference.setValue(node, withCompletionBlock: {[weak self] error, _ in
                    guard error == nil else {
                        //
                        completion(false)
                        return
                    }
                    //finishCreateMessageLine function called
                    self?.finishCreateMessageLine(messageID: "conversations_\(firstMessage.messageId)", userName: currentUserName, firstMessage: firstMessage, completion: completion)
                })
                
            } else {
                //create conversation array since it does not exist
                node["conversations"] = [newConversation]
                reference.setValue(node, withCompletionBlock: {[weak self] error, _ in
                    guard error == nil else {
                        //if an error occurs in adding newConversation to reference come here
                        completion(false)
                        return
                    }
                    //
                    self?.finishCreateMessageLine(messageID: "conversations_\(firstMessage.messageId)", userName: currentUserName, firstMessage: firstMessage, completion: completion)
                    
                })
                
            }
        })
    }
    
    // Continue with current conversation if it already exists
    public func continueWithMessagingLine(to conversation: String, newMessage: Message, userName: String, completion: @escaping (Bool) -> Void){
        // three steps: Add new message to message line
        // then update sender
        // then update recipient
        database.child("\(conversation)/messages").observeSingleEvent(of: .value, with: {[weak self] dataSnapshot in
            guard let strongSelf = self else {
                return
            }
            guard var currentMessageLine = dataSnapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            var messageDetail  = ""
            switch newMessage.kind {
            
            case .text(let messageText):
                messageDetail = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            let date = newMessage.sentDate
            let dateToString = MessageViewController.date.string(from: date)
            guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String, let currentUserName = UserDefaults.standard.value(forKey: "name") else {
                print("looking for me")
                completion(false)
                return
            }
            let useableUserEmail = FirebaseController.usableEmail(email: currentUserEmail)
            let newMessage: [String: Any] = ["messageID": newMessage.messageId, "messagetype": newMessage.kind.messageKindAsString, "messageContent": messageDetail, "messageDate": dateToString, "sender_email": useableUserEmail, "is_read": false, "name": currentUserName]
            currentMessageLine.append(newMessage)
            strongSelf.database.child("\(conversation)/messages").setValue(currentMessageLine) { error, _ in
                guard error == nil else {
                    print("looking for me")
                    completion(false)
                    return
                }
                completion(true)
            }
        })
    }
    // MARK: BIG ERROR HERE
    // Retrieves all user conversations
    public func retrieveAllMessageLines(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        print("here")
        database.child("\(email)/conversations").observe(.value, with: { dataSnapshot in
            guard let result = dataSnapshot.value as? [[String: Any]] else {
                print("\(email)/conversations")
                print(dataSnapshot)
                print("1")
                completion(.failure(Errors.fetchFailed))
                return
            }
            let conversations: [Conversation] = result.compactMap({ dictionary in
                guard let conversationID = dictionary["id"] as? String, let name = dictionary["other_user_name"] as? String,
                      let otherUser = dictionary["other_user_email"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let sentDate = latestMessage["date"] as? String,
                      let sentMessage = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else {return nil}
                let currentMessage = LatestMessage(date: sentDate,  isRead: isRead, message: sentMessage)
                return Conversation(id: conversationID, name: name, otherUserEmail: otherUser, latestMessage: currentMessage)
            })
            completion(.success(conversations))
        })
    }
    // Retrieves all messages for each conversation
    public func retrieveAllMessages(with id: String, completion: @escaping (Result<[Message], Error>) -> Void){
        database.child("\(id)/messages").observe(.value, with: { snapshot in
            guard let result = snapshot.value as? [[String: Any]] else {
                completion(.failure(Errors.fetchFailed))
                return
            }
            let messages: [Message] = result.compactMap({ dictionary in
                guard let isRead = dictionary["is_read"] as? Bool,
                      let messageContent = dictionary["messageContent"] as? String,
                      let messageDate = dictionary["messageDate"] as? String,
                      let dateForm = MessageViewController.date.date(from: messageDate),
                      let messageID = dictionary["messageID"] as? String,
                      let messageType = dictionary["messagetype"] as? String,
                      let name = dictionary["name"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String else {
                    return nil
                }
                print(isRead)
                print(messageType)
                let messageSender = Sender(senderId: senderEmail, senderPhotoURL: "", displayName: name)
                return Message(sender: messageSender, messageId: messageID, sentDate: dateForm, kind: .text(messageContent))
            })
            completion(.success(messages))
        })
        
    }
    
    private func finishCreateMessageLine(messageID: String, userName: String, firstMessage: Message, completion: @escaping (Bool) -> Void){
        var messageDetail  = ""
        switch firstMessage.kind {
        
        case .text(let messageText):
            messageDetail = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        //changing the date from the firstMessage.sent date from type date to type string
        let date = firstMessage.sentDate
        let dateToString = MessageViewController.date.string(from: date)
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            //if current user does not become a user default value under email come here
            completion(false)
            return
        }
        //change currentEmail into an email that can be used by firebase
        let useableUserEmail = FirebaseController.usableEmail(email: currentUserEmail)
        // create message collection here
        let messageCollection: [String: Any] = ["messageID": firstMessage.messageId, "messagetype": firstMessage.kind.messageKindAsString, "messageContent": messageDetail, "messageDate": dateToString, "sender_email": useableUserEmail, "is_read": false, "name": userName]
        let value: [String: Any] = ["messages": [messageCollection]]
        //in path add a message into the collection
        database.child("conversations_\(firstMessage.messageId)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else {
                //if message collection was not added
                completion(false)
                return
            }
            completion(true)
        })
    }
    
        
    // MARK: Error Management
    public enum Errors: Error {
        case fetchFailed
    }
}

// MARK: Struct Management
//create an app user with the following parameters
struct AppUser {
    let fName: String
    let lName: String
    let email: String
    let preferenceOne: String
    let preferenceTwo: String
    
    var useableEmail: String {
        var usuableEmail = email.replacingOccurrences(of: ".", with: " ")
        usuableEmail = usuableEmail.replacingOccurrences(of: "@", with: "-")
        return usuableEmail
    }
    var profilePicture: String {
        return "\(useableEmail)_profile_image.png"
    }
}

struct DiaryEntry {
    let entryTitle: String
    let entryText: String
    let entryID: String
    let email: String
    var useableEmail: String {
        var usuableEmail = email.replacingOccurrences(of: ".", with: " ")
        usuableEmail = usuableEmail.replacingOccurrences(of: "@", with: "-")
        return usuableEmail
    }
    var randomInt: Int {
        var randomInt = Int.random(in: 1..<10000)
        let secondInt = Int.random(in: 1..<30)
        randomInt = randomInt + secondInt
        return randomInt
    }
    var pictureOne: String {
        return "\(useableEmail)_diary_entry_\(entryID)_image_one.png"
    }
}
