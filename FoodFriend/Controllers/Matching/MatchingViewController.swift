//
//  MatchingViewController.swift
//  FoodFriend
//
//  Created by Karam Ali.
//

import UIKit

class MatchingViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    private var users = [[String: String]]()
    private var usersFetched = false
    private var resultingUsers = [[String: String]]()
    public var matchingCompletion: (([String: String]) -> (Void))?
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let searchBar: UISearchBar = {
        let bar = UISearchBar()
        return bar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        view.addSubview(scrollView)
        scrollView.addSubview(searchBar)
        scrollView.addSubview(tableView)
        searchBar.becomeFirstResponder()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        searchBar.frame = CGRect(x: (view.width-(size*2)-50)/2, y: 10, width: scrollView.width-60, height: 50)
        tableView.frame = CGRect(x: (view.width-(size*2)-50)/2, y: searchBar.bottom, width: scrollView.width-60, height: 50)
    }
    // whenever the search bar button is clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.replacingOccurrences(of: " ", with: "").isEmpty, !searchText.isEmpty else {
            return
        }
        // if there were any users before the search
        resultingUsers.removeAll()
        // search the firebase using searchText as the search query
        self.searchQuery(query: searchText)
    }
    
    // the function to search the firebase database for users that match the search query
    func searchQuery(query: String){
        if usersFetched {
            queryUsers(with: query)
        } else {
            //retrieve from firebase a list of users that match the query
            FirebaseController.shared.fetchUserList(completion: {[weak self] result in
                    switch result {
                    case .success(let users):
                        self?.usersFetched = true
                        self?.users = users
                        self?.queryUsers(with: query)
                    case .failure(let error):
                        print("failed: \(error)")
                }
            })
        }
    }
    // the function that will bring back a collection of users that are a result of the searched query
    func queryUsers(with term: String) {
        guard usersFetched else {
            return
        }
        let resultUsers: [[String: String]] = self.users.filter({guard let resultUserNames = $0["name"]?.lowercased() else {
            return false
        }
        // return a list of names from users that match query
        return resultUserNames.hasPrefix(term.lowercased())
        
        })
        //let the resulting users array equal the array of names from resultUsers
        self.resultingUsers = resultUsers
        updateSearch()
    }
    
    // show table with data if resultingUsers is not empty else hide table
    func updateSearch() {
        if resultingUsers.isEmpty {
            self.tableView.isHidden = true
        } else {
            self.tableView.reloadData()
            self.tableView.isHidden = false
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultingUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = resultingUsers[indexPath.row]["name"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //once the user selects a person, they are taken to the messaging screen
        let selectedUserInfo = resultingUsers[indexPath.row]
        dismiss(animated: true, completion: { [weak self] in
            self?.matchingCompletion?(selectedUserInfo)
        })
    }
    
}
