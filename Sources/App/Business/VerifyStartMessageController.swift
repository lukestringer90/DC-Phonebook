//
//  VerificationStartMessageController.swift
//  App
//
//  Created by Luke Stringer on 17/06/2018.
//

import Foundation
import Sword

struct VerifyStartMessageController {
    let verificationRequestStore: VerificationRequest.Store
    let discord: Sword
    
    func handle(startMessage: Message) {
        guard startMessage.content == Constants.Discord.VerifyStartMessage.command, let userID = startMessage.author?.id else { return }
        
        if self.verificationRequestStore.all().contains(where: { return $0.userID == userID.rawValue } ) {
            discord.deleteMessage(startMessage.id, from: userID, then: nil)
        }
        else {
            startMessage.reply(with: "Check for a DM from me to start the verification process.") { replyMessageOrNil, error in
                guard let replyMessage = replyMessageOrNil else {
                    print("Could not reply to start message. Error: \(String(describing: error))")
                    return
                }
                let seconds = Constants.Discord.VerifyStartMessage.secondsBeforeDeletion
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                    self.discord.deleteMessage(replyMessage.id, from: replyMessage.channel.id, then: nil)
                    self.discord.deleteMessage(startMessage.id, from: startMessage.channel.id, then: nil)
                }
            }
        }
    }
}
