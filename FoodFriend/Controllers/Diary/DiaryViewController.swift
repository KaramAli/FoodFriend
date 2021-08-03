//
//  DiaryViewController.swift
//  FoodFriend
//
//  Created by Karam Ali.
//

import UIKit
import FirebaseAuth

class DiaryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var diaryEntries = [String]()
    var updateTable: (() -> Void)?

    private let tableViewManager: UITableView = {
        let tableManager = UITableView()
        tableManager.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableManager
    }()
    
    private let missingEntryLabel: UILabel = {
        let missingEntryLabel = UILabel()
        missingEntryLabel.textColor = .gray
        missingEntryLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        missingEntryLabel.text = "*cricket noises*"
        missingEntryLabel.textAlignment = .center
        missingEntryLabel.isHidden = true
        return missingEntryLabel
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(newEntryButtonPressed))

        if !UserDefaults().bool(forKey: "instantiate") {
            UserDefaults().setValue(true, forKey: "instantiate")
            UserDefaults().setValue(0, forKey: "entryCount")
        }

        view.addSubview(tableViewManager)
        view.addSubview(missingEntryLabel)
        tableView()
        retrieveEntry()

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableViewManager.frame = view.bounds
    }

    override func viewDidAppear(_ animated: Bool) {
        loginAuth()
    }

    @objc private func newEntryButtonPressed(){
        let viewController = NewEntryViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func retrieveEntry() {
        tableViewManager.isHidden = false
    }
    private func tableView() {
        tableViewManager.delegate = self
        tableViewManager.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diaryEntries.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewManager.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = diaryEntries[indexPath.row]
        return cell
    }
    //Code relating to the profile image goes here
    func downloadImg(imageView: UIImageView, url: URL){
        URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            guard let imgData = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                let imgData = UIImage(data: imgData)
                imageView.image = imgData
            }
        }).resume()
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
