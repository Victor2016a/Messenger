//
//  NewConversationView.swift
//  Messenger
//
//  Created by Victor Vieira on 13/06/22.
//

import UIKit
import JGProgressHUD

class NewConversationView: UIView {
  let spinner = JGProgressHUD(style: .dark)
  
  let searchBar: UISearchBar = {
    let searchBar = UISearchBar()
    searchBar.placeholder = "Search Users..."
    return searchBar
  }()
  
  let noResultsLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.isHidden = true
    label.text = "No Results"
    label.textAlignment = .center
    label.textColor = .gray
    label.font = .systemFont(ofSize: 21, weight: .medium)
    return label
  }()
  
  let tableView: UITableView = {
    let tableView = UITableView()
    tableView.translatesAutoresizingMaskIntoConstraints = false
    return tableView
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
    addSubview(noResultsLabel)
  }
  
  private func setupConstraints() {
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
      
      noResultsLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      noResultsLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
      noResultsLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
      noResultsLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
  }
}
