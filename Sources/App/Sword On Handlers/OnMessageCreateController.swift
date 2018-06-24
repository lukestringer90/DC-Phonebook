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
    private let verificationRequestStore = VerificationRequest.Store.shared
    private let verifyStartMessageController: VerifyStartMessageController
    private let verifyStartSignalStore = VerifyStartSignal.Store.shared
    
    required init(discord: Sword) {
        self.discord = discord
        self.verificationRequestCreator = VerificationRequestCreator(messageService: discord, roleService: discord, loggingService: self.discord, verificationRequestStore: verificationRequestStore, verifyStartSignalStore: verifyStartSignalStore)
        self.verifyStartMessageController = VerifyStartMessageController(discord: self.discord)
    }
    
    func handle(data: Any) {
        guard let message = data as? Message else {
            return
        }
        
        guard let user = message.author else {
            print("Message has no author")
            return
        }
        
        discord.getDM(for: user.id) { dmOrNil, dmError in
            defer {
                if message.content == Constants.Discord.VerifyStartMessage.command {
                    self.verifyStartMessageController.handle(startMessage: message)
                }
            }
            
            guard let dm = dmOrNil else {
                // DM is nil if message is from a bot
                return
            }
            
            let userID = user.id.rawValue
            let messageIsDMToBot = message.channel.id == dm.id
            let mesageIsVerifyStart = message.content == Constants.Discord.VerifyStartMessage.command
            guard mesageIsVerifyStart || messageIsDMToBot else { return }
            
            // Check to see if user is using the verify start command for the first time
            if mesageIsVerifyStart && self.verifyStartSignal(for: userID) == nil {
                /*
                When user starts the verification process we need to capture the UserID and the GuildID.
                This is so that once the wizard has finished the DM conversation with the user
                we know which Guild to send messages back to.
                During a DM conversation it cannot be determined which Guild the original verify start command
                was called from.
                */
                guard let guildID = message.member?.guild?.id.rawValue else { return }
                self.verifyStartSignalStore.add(VerifyStartSignal(userID: userID, guildID: guildID))
            }
            
            guard let guildID = self.verifyStartSignal(for: userID)?.guildID else { return }
            
            message.produceVerificationMessage(in: guildID) { verificationMessageOrNil in
                guard let verificationMessage = verificationMessageOrNil else { return }
                self.verificationRequestCreator.handle(message: verificationMessage)
            }
        }
    }
}

fileprivate extension OnMessageController {
    func verifyStartSignal(for userID: UserID) -> VerifyStartSignal? {
        return self.verifyStartSignalStore.getFirst(matching: userID)
    }
}

extension Message {
    
    struct Verification: VerificationMessage {
        let guildID: GuildID
        let fromBot: Bool
        let authorID: UserID
        let content: String
        let authorDMID: RecepientID
    }
    
    func produceVerificationMessage(in guildID: GuildID, completion: @escaping (_ message: VerificationMessage?) -> ())  {
        guard let author = author else {
            print("Message has no author")
            completion(nil)
            return
        }
        
        author.getDM { dmOrNil, requestError in
            guard let dm = dmOrNil else {
                print("Cannot get DM for author: \(author.id)")
                completion(nil)
                return
            }
            
            let verificationMessage = Message.Verification(guildID: guildID, fromBot: author.isBot == true, authorID: author.id.rawValue, content: self.content, authorDMID: dm.id.rawValue)
            completion(verificationMessage)
        }
    }
}
