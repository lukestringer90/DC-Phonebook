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
        
        discord.getDM(for: user.id) { dmOrNil, error in
            defer {
                if message.content == "!verify" {
                    self.discord.deleteMessage(message.id.rawValue, from: message.channel.id.rawValue) { error in
                        print("\(String(describing: error))")
                    }
                }
            }
            
            guard let dm = dmOrNil else {
                print("\(String(describing: error))")
                return
            }
            
            let messageIsDMToBot = message.channel.id == dm.id
            guard message.content == "!verify" || messageIsDMToBot else {
                print("Not a verify message")
                return
            }
            
            self.discord.getRolesIDs(forUser: user.id.rawValue) { roleIDsOrNil, error in
                guard let roleIDs = roleIDsOrNil else {
                    print("Cannot get roles for user. Error: \(String(describing: error))")
                    return
                }
                
                guard !roleIDs.contains(Constants.Discord.Role.verified) else {
                    self.discord.send("You are already verified.", to: dm.id)
                    return
                }
                
                message.produceVerificationMessage { verificationMessageOrNil in
                    guard let verificationMessage = verificationMessageOrNil else { return }
                    self.verificationRequestCreator.handle(message: verificationMessage)
                }
            }
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
