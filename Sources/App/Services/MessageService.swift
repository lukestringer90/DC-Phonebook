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

protocol MessageService {
    func sendMessage(_ content: String, to recepientID: RecepientID, then completion: @escaping ServiceCompletion)
    
    func sendMessage(_ content: String, to recepientID: RecepientID, withEmojiReactions reactions: [EmojiReaction], then completion: @escaping ServiceCompletion)
    
    func deleteMessage(_ messageID: MessageID, from recepientID: RecepientID, then completion: @escaping ServiceCompletion)
}
