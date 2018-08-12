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
    let verificationProcessor: VerificationRequestProcessor
    let config: DiscordConfig
    
    required init(discord: Sword, config: DiscordConfig) {
        self.discord = discord
        self.config = config
        let logger = self.discord.logger(forChannel: self.config.channelIDs.logs)
        self.verificationProcessor = VerificationRequestProcessor(roleService: self.discord, messageService: self.discord, loggingService: logger, verificationRequestStore: VerificationRequest.Store.shared, config: config)
    }
    
    func handle(data: Any) {
		print_flush("Handling reaction")
		
        typealias Reaction = (Channel, Snowflake, Snowflake, Emoji)
        
        guard
            let (channel, userID, messageID, emoji) = data as? Reaction,
            channel.id.rawValue == config.channelIDs.phoneBookRequests
            else { return }
        
        discord.getUser(userID) { userOrNil, error in
            guard let user = userOrNil else {
				print_flush("Failed to get user \(userID). Error: \(String(describing: error))")
				fflush(stdout)
                return
            }
            
            guard user.isBot == false || user.isBot == nil else { return }
            
            self.discord.getMessage(messageID, from: channel.id) { messageOrNil, error in
                guard let message = messageOrNil else {
                    print_flush("Failed to get user \(messageID). Error: \(String(describing: error))")
					fflush(stdout)
                    return
                }
                
                guard let guildID = message.member?.guild?.id.rawValue else {
                    print_flush("Cannot get Guild ID")
					fflush(stdout)
                    return
                }

                let reaction = VerificationRequest.Reaction(guildID: guildID
                    , channelID: message.channel.id.rawValue, messageID: messageID.rawValue, messageContent: message.content, emojiName: emoji.name, reactorID: userID.rawValue)
                self.verificationProcessor.handle(reaction: reaction)
                
            }
        }
    }
}

extension VerificationRequest {
    struct Reaction: ReactionToVerificationRequest {
        let guildID: GuildID
        let channelID: RecepientID
        let messageID: MessageID
        let messageContent: String
        let emojiName: String
        var reactorID: UserID
    }
}

