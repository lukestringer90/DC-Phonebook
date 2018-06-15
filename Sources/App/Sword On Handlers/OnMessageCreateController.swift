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
    private let verificationRequestCreator: VerificationRequestCreator
	
    required init(discord: Sword) {
        self.discord = discord
        self.verificationRequestCreator = VerificationRequestCreator(messageService: discord)
    }
    
    func handle(data: Any) {
        guard let message = data as? Message else {
            print("Not a message")
            return
        }
        
        guard let user = message.author else {
            print("No author")
            return
        }
        
        print("Channel: \(message.id)")
        print("Username: \(user.username ?? "null")")
        print("User ID: \(user.id)")
        print("Message: \(message.content)")
		
        message.produceVerificationMessage { verificationMessageOrNil in
            guard let verificationMessage = verificationMessageOrNil else { return }
            self.verificationRequestCreator.handle(message: verificationMessage)
        }
	}
}

extension Message {
    
    struct Verification: VerificationMessage {
        let fromBot: Bool
        let authorID: UserID
        let content: String
        let authorDMID: RecepientID
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
            
            let verificationMessage = Message.Verification(fromBot: author.isBot == true, authorID: author.id.rawValue, content: self.content, authorDMID: dm.id.rawValue)
            completion(verificationMessage)
        }
    }
}
