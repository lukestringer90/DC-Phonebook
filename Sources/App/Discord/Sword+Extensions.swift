//
//  Sword+Extensions.swift
//  App
//
//  Created by Luke Stringer on 12/06/2018.
//

import Foundation
import Sword

extension Sword: SendMessage {
    func send(_ messageText: String, to userID: SnowflakeID, withEmojiReactions reactions: [EmojiReaction]?) {
        send(messageText, to: Snowflake(rawValue: userID)) { message, error in
            guard let reactions = reactions, let message = message else { return }
            
            for reaction in reactions {
                self.addReaction(reaction.rawValue, to: message.id, in: Snowflake(rawValue: userID), then: { reactionError in
                    print(reactionError)
                })
            }
        }
    }
    
    func send(_ messageText: String, to userID: SnowflakeID) {
        send(messageText, to: Snowflake(rawValue: userID)) { message, error in
            print(message)
            print(error)
        }
    }
}

