//
//  ChatsViewController.swift
//  Messenger
//
//  Created by Victor Vieira on 31/05/22.
//

import UIKit

class ChatsViewController: UIViewController {
  let chatView = ChatsView()
  
  override func loadView() {
    super.loadView()
    view = chatView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .orange
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
  
  @objc private func didTapCompose() {
    let newConversationVC = NewConversationViewController()
    let navigationVC = UINavigationController(rootViewController: newConversationVC)
    present(navigationVC, animated: true)
  }
  
  private func setupTableView() {
    chatView.tableView.register(ChatsTableViewCell.self, forCellReuseIdentifier: ChatsTableViewCell.identifier)
    
    chatView.tableView.delegate = self
    chatView.tableView.dataSource = self
  }
}

extension ChatsViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ChatsTableViewCell.identifier, for: indexPath)
    cell.textLabel?.text = "Hello"
    return cell
  }
}

extension ChatsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    let chatsWithPersonVC = ChatWithPersonViewController()
    
    chatsWithPersonVC.title = "Yan"
    chatsWithPersonVC.navigationItem.largeTitleDisplayMode = .never
    navigationController?.pushViewController(chatsWithPersonVC, animated: true)
  }
}
