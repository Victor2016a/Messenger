//
//  NewConversationViewController.swift
//  Messenger
//
//  Created by Victor Vieira on 23/05/22.
//

import UIKit

class NewConversationViewController: UIViewController {
  private let newConversationView = NewConversationView()
  
  public var completion: ((NewConversationModel) -> (Void))?
  private var users = [[String: String]]()
  private var results = [NewConversationModel]()
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
    newConversationView.tableView.register(NewConversationTableViewCell.self,
                                           forCellReuseIdentifier: NewConversationTableViewCell.identifier)
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
    let model = results[indexPath.row]
    
    guard let cell = tableView.dequeueReusableCell(withIdentifier: NewConversationTableViewCell.identifier, for: indexPath) as? NewConversationTableViewCell else {
      return .init()
    }
    
    cell.configure(with: model)
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
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 90
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
    
    guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String, hasFetch else {
      return
    }
    
    let safeEmail = DataBaseManager.safeEmail(email: currentUserEmail)
    
    self.newConversationView.spinner.dismiss()
    
    let results: [NewConversationModel] = self.users.filter {
      
      guard let email = $0["email"],
            email != safeEmail else {
        return false
      }
      
      guard let name = $0["name"]?.lowercased() else {
        return false
      }
      
      return name.hasPrefix(term.lowercased())
      
    }.compactMap({
      
      guard let email = $0["email"], let name = $0["name"] else {
        return nil
      }
      
      return NewConversationModel(name: name, email: email)
    })
    
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
