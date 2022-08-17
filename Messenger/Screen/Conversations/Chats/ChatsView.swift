//
//  ChatsView.swift
//  Messenger
//
//  Created by Victor Vieira on 31/05/22.
//

import UIKit
import JGProgressHUD

class ChatsView: UIView {
  let spinner = JGProgressHUD(style: .dark)
  
  var tableView: UITableView = {
    let tableView = UITableView()
    tableView.translatesAutoresizingMaskIntoConstraints = false
    return tableView
  }()
  
  let noConversationsLabel: UILabel = {
    let label = UILabel()
    label.text = "No conversations"
    label.textColor = .gray
    label.font = .systemFont(ofSize: 21, weight: .medium)
    label.textAlignment = .center
    label.isHidden = true
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  override init(frame: CGRect) {
    super.init(frame: .zero)
    setupView()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupView() {
    addSubview(tableView)
    addSubview(noConversationsLabel)
  }
  
  private func setupConstraints() {
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
      
      noConversationsLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      noConversationsLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
      noConversationsLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
      noConversationsLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }
}
