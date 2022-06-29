//
//  NewConversationViewController.swift
//  Messenger
//
//  Created by Victor Vieira on 23/05/22.
//

import UIKit

class NewConversationViewController: UIViewController {
  private let newConversationView = NewConversationView()
  
  public var completion: (([String: String]) -> (Void))?
  private var users = [[String: String]]()
  private var results = [[String: String]]()
  private var hasFetch = false
  
  override func loadView() {
    super.loadView()
    view = newConversationView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    setupNavigation()
    configureTableView()
  }
  
  private func setupNavigation() {
    newConversationView.searchBar.delegate = self
    navigationController?.navigationBar.topItem?.titleView = newConversationView.searchBar
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                        style: .done,
                                                        target: self,
                                                        action: #selector(dismissSelf))
  }
  
  private func configureTableView() {
    newConversationView.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    newConversationView.tableView.dataSource = self
    newConversationView.tableView.delegate = self
  }
  
  @objc private func dismissSelf() {
    dismiss(animated: true)
  }
}

extension NewConversationViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    results.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    cell.textLabel?.text = results[indexPath.row]["name"]
    return cell
  }
}

extension NewConversationViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    let targetUserData = results[indexPath.row]
    
    dismiss(animated: true) { [weak self] in
      self?.completion?(targetUserData)
    }
  }
}

extension NewConversationViewController: UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
      return
    }
    
    results.removeAll()
    newConversationView.spinner.show(in: view)
    self.searchUsers(query: text)
  }
  
  func searchUsers(query: String) {
    
    if hasFetch {
      
      filterUsers(with: query)
      
    } else {
      
      DataBaseManager.shared.getAllUsers { [weak self] result in
        switch result {
        case .success(let usersCollection):
          self?.hasFetch = true
          self?.users = usersCollection
          self?.filterUsers(with: query)
        case .failure(let error):
          print(error)
        }
      }
    }
  }
  
  func filterUsers(with term: String) {
    
    guard hasFetch else {
      return
    }
    
    self.newConversationView.spinner.dismiss()
    
    let results: [[String: String]] = self.users.filter {
      guard let name = $0["name"]?.lowercased() else {
        return false
      }
      
      return name.hasPrefix(term.lowercased())
    }
    
    self.results = results
    updateUI()
  }
  
  func updateUI() {
    if results.isEmpty {
      self.newConversationView.noResultsLabel.isHidden = false
      self.newConversationView.tableView.isHidden = true
      
    } else {
      self.newConversationView.noResultsLabel.isHidden = true
      self.newConversationView.tableView.isHidden = false
      self.newConversationView.tableView.reloadData()
    }
  }
}
