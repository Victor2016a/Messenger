//
//  ChatsModel.swift
//  Messenger
//
//  Created by Victor Vieira on 30/06/22.
//

import Foundation

struct ChatModel {
  let id: String
  let name: String
  let otherUserEmail: String
  let latestMessage: LatestMessage
}

struct LatestMessage {
  let date: String
  let text: String
  let type: String
  let isRead: Bool
}
