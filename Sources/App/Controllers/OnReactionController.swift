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
    
    required init(discord: Sword) {
        self.discord = discord
    }
    
    func handle(data: Any) {
        typealias Reaction = (Channel, Snowflake, Snowflake, Emoji)
        
        guard
            let (channel, _, messageID, emoji) = data as? Reaction,
            channel.id.rawValue == Discord.ChannelID.phoneBookRequests
            else { return }
        
        discord.getMessage(messageID, from: channel.id) { messageOrNil, error in
            guard let message = messageOrNil else {
                print(error ?? "Unknown error getting message")
                return
            }
            
            // DO NOT FORECE UNWRAP THESE
            let userID = Snowflake(self.extractUserID(from: message.content))!
            let guildID = self.discord.guilds.values.first!.id
            
            switch emoji.name {
            case EmojiReaction.tick.rawValue:
                self.confirmVerification(in: message, for: userID, inGuild: guildID)
            case EmojiReaction.cross.rawValue: self.deniyVerification()
            default: return
            }
        
        }
    }
}

fileprivate extension OnReactionAddController {
    func confirmVerification(in message: Message, for userID: Snowflake, inGuild guildID: Snowflake) {
        let userID = Snowflake(self.extractUserID(from: message.content))
        
        self.discord.getMember(userID, from: guildID, then: { memberOrNil, error in
            guard let member = memberOrNil else {
                print(error ?? "Unknown error getting member")
                return
            }
            
            let roleIDToAssign = Discord.Role.verified
            var roleIDs = member.roles.map { $0.id.rawValue }
            if !roleIDs.contains(roleIDToAssign) {
                roleIDs.append(roleIDToAssign)
            }
            
            let options = ["roles": roleIDs]
            
            self.discord.modifyMember(userID, in: guildID, with: options, then: { error in
                print(error ?? "Unknown error modifying member")
            })
            
            // Remove message from request
            // Add to phonebook
        })
    }
    
    func deniyVerification() {
        
    }
}

fileprivate extension OnReactionAddController {
    func extractUserID(from string: String) -> SnowflakeID {
        guard
            let at = string.index(of: "@"),
            let closingBracket = string.index(of: ">")
            else {
                fatalError("Cannot get user ID from message content")
        }
        
        let start = string.index(after: at)
        let end = string.index(before: closingBracket)
        
        let userIDString = string[start...end]
        
        guard let userIDDouble = Double(userIDString) else {
            fatalError("Cannot parse string into double for user ID ")
        }
        
        return SnowflakeID(userIDDouble)
    }
}
