//
//  ChatsViewController.swift
//  Messenger
//
//  Created by Victor Vieira on 31/05/22.
//

import UIKit

class ChatsViewController: UIViewController {
  let chatView = ChatsView()
  var conversations = [ChatModel]()
  
  override func loadView() {
    super.loadView()
    view = chatView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .orange
    startListeningForConversations()
    setupNavigation()
    setupTableView()
  }
  
  private func setupNavigation() {
    title = "Chats"
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                        target: self,
                                                        action: #selector(didTapCompose))
  }
  
  private func startListeningForConversations() {
    guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return }
    
    let safeEmail = DataBaseManager.safeEmail(email: email)
    
    DataBaseManager.shared.getAllConversations(for: safeEmail) { [weak self] result in
      switch result {
      case .success(let conversations):
        guard !conversations.isEmpty else { return }
        self?.conversations = conversations
        
        DispatchQueue.main.async {
          self?.chatView.tableView.reloadData()
        }
      case .failure(let error):
        print(error)
      }
    }
    
  }
  
  @objc private func didTapCompose() {
    let newConversationVC = NewConversationViewController()
    
    newConversationVC.completion = { [weak self] result in
      self?.creatNewConversation(result: result)
    }
    
    let navigationVC = UINavigationController(rootViewController: newConversationVC)
    present(navigationVC, animated: true)
  }
  
  private func creatNewConversation(result: [String: String]) {
    guard let name = result["name"],
          let email = result["email"] else {
      return
    }
    
    let chatsWithPersonVC = ChatWithPersonViewController(email: email, id: nil)
    chatsWithPersonVC.isNewConversation = true
    chatsWithPersonVC.title = name
    chatsWithPersonVC.navigationItem.largeTitleDisplayMode = .never
    navigationController?.pushViewController(chatsWithPersonVC, animated: true)
  }
  
  private func setupTableView() {
    chatView.tableView.register(ChatsTableViewCell.self, forCellReuseIdentifier: ChatsTableViewCell.identifier)
    
    chatView.tableView.delegate = self
    chatView.tableView.dataSource = self
  }
}

extension ChatsViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return conversations.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatsTableViewCell.identifier, for: indexPath) as? ChatsTableViewCell else { return .init() }
      
    let model = conversations[indexPath.row]
    cell.configure(with: model)
      
    return cell
  }
}

extension ChatsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    let model = conversations[indexPath.row]
    
    let chatsWithPersonVC = ChatWithPersonViewController(email: model.otherUserEmail, id: model.id)
    chatsWithPersonVC.title = model.name
    chatsWithPersonVC.navigationItem.largeTitleDisplayMode = .never
    
    navigationController?.pushViewController(chatsWithPersonVC, animated: true)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 120
  }
}
