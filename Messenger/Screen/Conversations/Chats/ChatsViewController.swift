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
    view.backgroundColor = .systemBackground
    startListeningForConversations()
    setupNavigation()
    setupTableView()
    setupNotification()
  }
  
  private var loginObserver: NSObjectProtocol?
  
  private func setupNotification() {
    let nameNotification = Notification.Name("didLogInNotification")
    loginObserver = NotificationCenter.default.addObserver(forName: nameNotification,
                                                           object: nil,
                                                           queue: .main, using: { [weak self] _ in
      self?.navigationController?.dismiss(animated: true)
    })
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
    
    if let loginObserver = loginObserver {
      NotificationCenter.default.removeObserver(loginObserver)
    }
    
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
      
      if let targetConversation = self?.conversations.first(where: {
        $0.otherUserEmail == DataBaseManager.safeEmail(email: result.email)
      }) {
        let chatsWithPersonVC = ChatWithPersonViewController(email: targetConversation.otherUserEmail,
                                                             id: targetConversation.id)
        chatsWithPersonVC.isNewConversation = true
        chatsWithPersonVC.title = targetConversation.name
        chatsWithPersonVC.navigationItem.largeTitleDisplayMode = .never
        self?.navigationController?.pushViewController(chatsWithPersonVC, animated: true)
        
      } else {
        self?.creatNewConversation(result: result)
      }
    }
    
    let navigationVC = UINavigationController(rootViewController: newConversationVC)
    present(navigationVC, animated: true)
  }
  
  private func creatNewConversation(result: NewConversationModel) {
    let name = result.name
    let email = DataBaseManager.safeEmail(email: result.email)
    
    DataBaseManager.shared.conversationExists(with: email) { [weak self] result in
      switch result {
      case.success(let conversationId):
        let chatsWithPersonVC = ChatWithPersonViewController(email: email, id: conversationId)
        chatsWithPersonVC.isNewConversation = false
        chatsWithPersonVC.title = name
        chatsWithPersonVC.navigationItem.largeTitleDisplayMode = .never
        self?.navigationController?.pushViewController(chatsWithPersonVC, animated: true)
        
      case.failure(_):
        let chatsWithPersonVC = ChatWithPersonViewController(email: email, id: nil)
        chatsWithPersonVC.isNewConversation = true
        chatsWithPersonVC.title = name
        chatsWithPersonVC.navigationItem.largeTitleDisplayMode = .never
        self?.navigationController?.pushViewController(chatsWithPersonVC, animated: true)
      }
    }
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
    guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatsTableViewCell.identifier, for: indexPath) as? ChatsTableViewCell else {
      return .init()
    }
      
    let model = conversations[indexPath.row]
    cell.configure(with: model)
      
    return cell
  }
}

extension ChatsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    let model = conversations[indexPath.row]
    openConversation(with: model)
  }
  
  private func openConversation(with model: ChatModel) {
    let chatsWithPersonVC = ChatWithPersonViewController(email: model.otherUserEmail, id: model.id)
    chatsWithPersonVC.title = model.name
    chatsWithPersonVC.navigationItem.largeTitleDisplayMode = .never
    navigationController?.pushViewController(chatsWithPersonVC, animated: true)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 120
  }
  
  func tableView(_ tableView: UITableView,
                 editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
    return .delete
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    
    if editingStyle == .delete {
      let conversationId = conversations[indexPath.row].id
      tableView.beginUpdates()
      
      DataBaseManager.shared.deleteConversation(conversationId: conversationId) { [weak self] success in
        if success {
          self?.conversations.remove(at: indexPath.row)
          tableView.deleteRows(at: [indexPath], with: .left)
        }
      }
      
      tableView.endUpdates()
    }
  }
}
