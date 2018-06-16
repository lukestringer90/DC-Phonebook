//
//  MessageService.swift
//  App
//
//  Created by Luke Stringer on 15/06/2018.
//

import Foundation

enum EmojiReaction: String {
    case cross = "❌"
    case tick = "✅"
}

typealias GetDirectMessageIDCompletion = (RecepientID?) -> ()

protocol MessageService {
    func sendMessage(_ content: String, to recepientID: RecepientID, then completion: ServiceCompletion?)
    
    func sendMessage(_ content: String, to recepientID: RecepientID, withEmojiReactions reactions: [EmojiReaction], then completion: ServiceCompletion?)
    
    func deleteMessage(_ messageID: MessageID, from recepientID: RecepientID, then completion: ServiceCompletion?)
    
    func getDirectMessageID(forUser userID: UserID, then completion: @escaping GetDirectMessageIDCompletion)
}

extension MessageService {
    func sendMessage(_ content: String, to recepientID: RecepientID, then completion: ServiceCompletion? = nil) {
        sendMessage(content, to: recepientID, then: completion)
    }
    
    func sendMessage(_ content: String, to recepientID: RecepientID, withEmojiReactions reactions: [EmojiReaction], then completion: ServiceCompletion? = nil) {
        sendMessage(content, to: recepientID, withEmojiReactions: reactions, then: completion)
    }
    
    func deleteMessage(_ messageID: MessageID, from recepientID: RecepientID, then completion: ServiceCompletion?) {
        deleteMessage(messageID, from: recepientID, then: completion)
    }
}
