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
        self.verificationProcessController = VerificationProcessController(roleService: self.discord)
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
                
                let reaction = VerificationRequest.Reaction(messageContent: message.content, emojiName: emoji.name)
                self.verificationProcessController.handle(reaction: reaction)
                
            }
        }
    }
}

extension Sword: RoleService {
    func getRolesIDs(forUser userID: SnowflakeID, completion: @escaping ([RoleID]) -> ()) {
        getMember(Snowflake(userID), from: guildID) { memberOrNil, error in
            guard let member = memberOrNil else {
                fatalError("Cannot get member")
            }
            
            let roleIDs = member.roles.map { $0.id.rawValue }
            completion(roleIDs)
        }
    }
    
    func modify(user userID: SnowflakeID, toHaveRoles roleIDs: [RoleID]) {
        let options = ["roles": roleIDs]
        modifyMember(Snowflake(userID), in: guildID, with: options) { error in
            print(error)
        }
    }
    
    private var guildID: Snowflake {
        get {
            guard let guildID = guilds.first?.value.id else {
                fatalError("Cannot get guild")
            }
            return guildID
        }
    }
}

extension VerificationRequest {
    struct Reaction: ReactionToVerificationRequest {
        let messageContent: String
        let emojiName: String
    }
}

