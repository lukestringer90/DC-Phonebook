//
//  OnMessageController.swift
//  App
//
//  Created by Luke Stringer on 01/06/2018.
//

import Foundation
import Sword

class OnMessageController {
	let discord: Sword
    private let verificationController: VerificationController
	
    init(discord: Sword) {
        self.discord = discord
        self.verificationController = VerificationController(messageSender: discord)
    }
    
    func handler(data: Any) {
        guard let message = data as? Message else {
            print("Not a message")
            return
        }
		
		guard let user = message.author else {
			print("No author")
			return
		}
		
		print("Channel: \(message.id)")
        print("From: \(user.username ?? "null")")
		print("Message: \(message.content)")
		
        message.produceVerificationMessage { verificationMessageOrNil in
            guard let verificationMessage = verificationMessageOrNil else { return }
            self.verificationController.handler(message: verificationMessage)
        }
	}
}

extension Message {
    
    struct Verification: VerificationMessage {
        let fromBot: Bool
        let authorID: UserID
        let content: String
    }
    
    func produceVerificationMessage(completion: @escaping (_ message: VerificationMessage?) -> ())  {
        guard let author = author else {
            print("No author")
            completion(nil)
            return
        }
        
        author.getDM { dmOrNil, requestError in
            guard let dm = dmOrNil else {
                print("No DM")
                completion(nil)
                return
            }
            
            let verificationMessage = Message.Verification(fromBot: author.isBot == true, authorID: dm.id.rawValue, content: self.content)
            completion(verificationMessage)
        }
    }
}

extension Sword: SendMessage {
    func send(_ messageText: String, to userID: UserID, withReactions reactions: [Reaction]?) {
        send(messageText, to: Snowflake(rawValue: userID)) { message, error in
            guard let reactions = reactions, let message = message else { return }
            
            for reaction in reactions {
                self.addReaction(reaction.rawValue, to: message.id, in: Snowflake(rawValue: userID), then: { reactionError in
                    print(reactionError)
                })
            }
        }
    }
    
    func send(_ messageText: String, to userID: UserID) {
        send(messageText, to: Snowflake(rawValue: userID)) { message, error in
            print(message)
            print(error)
        }
    }
}

