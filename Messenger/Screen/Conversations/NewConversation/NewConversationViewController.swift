//
//  NewConversationViewController.swift
//  Messenger
//
//  Created by Victor Vieira on 23/05/22.
//

import UIKit

class NewConversationViewController: UIViewController {
  let newConversationView = NewConversationView()
  
  override func loadView() {
    super.loadView()
    view = newConversationView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    setupNavigation()
  }
  
  private func setupNavigation() {
    newConversationView.searchBar.delegate = self
    navigationController?.navigationBar.topItem?.titleView = newConversationView.searchBar
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                        style: .done,
                                                        target: self,
                                                        action: #selector(dismissSelf))
  }
  
  @objc private func dismissSelf() {
    dismiss(animated: true)
  }
}

extension NewConversationViewController: UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    
  }
}
