//
//  ChatWithPersonModel.swift
//  Messenger
//
//  Created by Victor Vieira on 13/06/22.
//

import MessageKit

struct Message: MessageType {
  var sender: SenderType
  var messageId: String
  var sentDate: Date
  var kind: MessageKind
}

struct Sender: SenderType {
  var photoURL: String
  var senderId: String
  var displayName: String
}
