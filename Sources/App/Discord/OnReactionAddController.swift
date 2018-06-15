//
//  OnReactionController.swift
//  App
//
//  Created by Luke Stringer on 07/06/2018.
//

import Foundation
import Sword

class OnReactionAddController {
    
    let discord: Sword
    let verificationProcessController: VerificationProcessController
    
    required init(discord: Sword) {
        self.discord = discord
        self.verificationProcessController = VerificationProcessController(roleService: self.discord, messageService: self.discord)
    }
    
    func handle(data: Any) {
        typealias Reaction = (Channel, Snowflake, Snowflake, Emoji)
        
        guard
            let (channel, userID, messageID, emoji) = data as? Reaction,
            channel.id.rawValue == Discord.ChannelID.phoneBookRequests
            else { return }
        
        discord.getUser(userID) { userOrNil, error in
            guard let user = userOrNil else {
                print(error ?? "Unknown error getting user")
                return
            }
            
            guard user.isBot == false || user.isBot == nil else { return }
            
            self.discord.getMessage(messageID, from: channel.id) { messageOrNil, error in
                guard let message = messageOrNil else {
                    print(error ?? "Unknown error getting message")
                    return
                }
                
                let reaction = VerificationRequest.Reaction(messageID: messageID.rawValue, messageContent: message.content, emojiName: emoji.name)
                self.verificationProcessController.handle(reaction: reaction)
                
            }
        }
    }
}

extension VerificationRequest {
    struct Reaction: ReactionToVerificationRequest {
        let messageID: MessageID
        let messageContent: String
        let emojiName: String
    }
}

