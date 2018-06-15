//
//  Sword+Extensions.swift
//  App
//
//  Created by Luke Stringer on 12/06/2018.
//

import Foundation
import Sword

extension Sword: MessageService {
    func sendMessage(_ content: String, to recepientID: RecepientID, withEmojiReactions reactions: [EmojiReaction], then completion: @escaping ServiceCompletion) {
        send(content, to: Snowflake(rawValue: recepientID)) { message, error in
            guard let message = message else {
                completion(error)
                return
            }
            
            guard reactions.count > 0 else {
                completion(nil)
                return
            }
            
            for reaction in reactions {
                self.addReaction(reaction.rawValue, to: message.id, in: Snowflake(recepientID), then: { reactionError in
                    completion(error)
                })
            }
        }
    }
    
    func sendMessage(_ content: String, to recepientID: RecepientID, then completion: @escaping ServiceCompletion) {
        sendMessage(content, to: recepientID, withEmojiReactions: [], then: completion)
    }
    
    func deleteMessage(_ messageID: MessageID, then completion: @escaping ServiceCompletion) {
        // TODO: Implement me
    }
}

