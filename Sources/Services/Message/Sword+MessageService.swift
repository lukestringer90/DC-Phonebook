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
		
		print_flush("Sending to \(recepientID)")
		
		
        send(content, to: Snowflake(rawValue: recepientID)) { message, error in

			if let theError = error {
				print_flush("Sending errored: \(theError)")
			}
			
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
		
		print_flush("Adding reaction \(nextReaction.rawValue)")
        
        addReaction(nextReaction.rawValue, to: Snowflake(messageId), in: Snowflake(channelId)) { error in
			print_flush("In reaction completion")
			if let theError = error {
				print_flush("Reaction errored: \(theError)")
			}
			
            guard error == nil else {
				print_flush("Finished adding reactions")
                completion?(nil)
                return
            }
			
            var remaining = reactions
			print_flush("Removing first reaction")
            remaining.removeFirst()
			
			print_flush("Waiting")
			DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
				print_flush("Recursing")
				self.recursivelyAddReaction(remaining, to: messageId, in: channelId, then: completion)
			}

        }
    }
}

