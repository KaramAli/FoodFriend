//
//  ConversationsViewController.swift
//  FoodFriend
//
//  Created by Karam Ali.
//

import UIKit
import FirebaseAuth

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let isRead: Bool
    let message: String
    
}

class ConversationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var conversations = [Conversation]()
    
    private let tableViewManager: UITableView = {
        let tableManager = UITableView()
        tableManager.isHidden = false
        tableManager.register(MessagesTableViewCell.self, forCellReuseIdentifier: MessagesTableViewCell.indentifier)
        return tableManager
    }()
    
    private let missingConsersationsLabel: UILabel = {
        let missingConversationLabel = UILabel()
        missingConversationLabel.textColor = .gray
        missingConversationLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        missingConversationLabel.text = "*cricket noises*"
        missingConversationLabel.textAlignment = .center
        missingConversationLabel.isHidden = true
        return missingConversationLabel
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        loginAuth()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newConversationButtonPressed))
        title = "Conversations"
        view.backgroundColor = .white
        view.addSubview(tableViewManager)
        view.addSubview(missingConsersationsLabel)
        tableView()
        retrieveMessageLine()
        listenForMessageLines()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableViewManager.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loginAuth()
    }
    
    // code required to listen for any changes in any of the conversations
    private func listenForMessageLines(){
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        //change user email into something firebase allows
        let userEmail = FirebaseController.usableEmail(email: currentUserEmail)
        print(userEmail)
        // retrieving all conversations for a given user
        FirebaseController.shared.retrieveAllMessageLines(for: userEmail, completion: { [weak self] result in
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else {
                    //if conversations in firebase for this user is empty come here
                    print("here")
                    return
                }
                //bring back conversations as an array of conversations on the main thread
                self?.conversations = conversations
                DispatchQueue.main.async {
                    self?.tableViewManager.reloadData()
                }
            // if messagelinesa are not retrieved come here
            case .failure(let errorMessage):
                print("failed. error = \(errorMessage)")
            }
            
            
        })
    }
    
    private func retrieveMessageLine() {
        tableViewManager.isHidden = false
    }
    
    private func tableView() {
        tableViewManager.delegate = self
        tableViewManager.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        //if a cell is selected navigate to messageviewcontroller with corressponding otheruserEmail
        let viewController = MessageViewController(with: model.otherUserEmail, id: model.id)
        viewController.title = model.name
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //set all cells to a corressponding conversation
        let model = conversations[indexPath.row]
        let cell = tableViewManager.dequeueReusableCell(withIdentifier: MessagesTableViewCell.indentifier, for: indexPath) as! MessagesTableViewCell
        cell.configure(with: model)
        //each cell is now associated with a conversation
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    //the newConversation button takes the user to
    @objc private func newConversationButtonPressed(){
        let viewController = MatchingViewController()
        viewController.matchingCompletion = { [weak self] matching in
            self?.createMessagingScreen(result: matching)
            
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
    // fucntion to create the message screen once the user selects a chat
    private func createMessagingScreen(result: [String: String]) {
        //takes a dictionary of strings and takes name from name and email from email from the result dictionary
        guard let name = result["name"], let email = result["email"] else {
            //if name and email is not retrieved come here
            print("not enough data to create messaging line")
            return
        }
        // navigate to messageViewController with the title of the screen being the selected user's name
        let viewController = MessageViewController(with: email, id: nil)
        viewController.isNewMessageLine = true
        viewController.title = name
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    private func loginAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let viewController = LoginViewController()
            let navigation = UINavigationController(rootViewController: viewController)
            navigation.modalPresentationStyle = .fullScreen
            present(navigation, animated: false)
        }
    }

}


