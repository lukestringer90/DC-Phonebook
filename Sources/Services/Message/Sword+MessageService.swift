//
//  Sword+Extensions.swift
//  App
//
//  Created by Luke Stringer on 12/06/2018.
//

import Foundation
import Sword

extension Sword: MessageService {
    func sendMessage(_ content: String, to recepientID: RecepientID, withEmojiReactions reactions: [EmojiReaction], then completion: ServiceCompletion?) {
        send(content, to: Snowflake(rawValue: recepientID)) { message, error in
            guard let message = message else {
                completion?(error)
                return
            }
            
            guard reactions.count > 0 else {
                completion?(nil)
                return
            }
            
            self.recursivelyAddReaction(reactions, to: message.id.rawValue, in: recepientID, then: completion)
        }
    }
    
    func sendMessage(_ content: String, to recepientID: RecepientID, then completion: ServiceCompletion?) {
        sendMessage(content, to: recepientID, withEmojiReactions: [], then: completion)
    }
    
    func deleteMessage(_ messageID: MessageID, from recepientID: RecepientID, then completion: ServiceCompletion?) {
        deleteMessage(Snowflake(messageID), from: Snowflake(recepientID)) { error in
            completion?(error)
        }
    }
    
    func getDirectMessageID(forUser userID: UserID, then completion: @escaping GetDirectMessageIDCompletion) {
        getDM(for: Snowflake(userID)) { dmOrNil, error in
            guard let dm = dmOrNil else {
                completion(nil)
                return
            }
            
            let directMessageID = dm.id.rawValue
            completion(directMessageID)
        }
    }
}

fileprivate extension Sword {
    func recursivelyAddReaction(_ reactions: [EmojiReaction], to messageId: MessageID, in channelId: RecepientID, then completion: ServiceCompletion?) {
        guard let nextReaction = reactions.first else {
            completion?(nil)
            return
        }
        
        addReaction(nextReaction.rawValue, to: Snowflake(messageId), in: Snowflake(channelId)) { error in
            guard error == nil else {
                completion?(nil)
                return
            }
            
            var remaining = reactions
            remaining.removeFirst()
            self.recursivelyAddReaction(remaining, to: messageId, in: channelId, then: completion)
        }
    }
}

