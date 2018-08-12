//
//  VerificationStartMessageController.swift
//  App
//
//  Created by Luke Stringer on 17/06/2018.
//

import Foundation
import Sword

struct VerifyStartMessageController {
    let discord: Sword
    let config: DiscordConfig
    
    func handle(startMessage: Message) {
        guard startMessage.content == config.verifyStartMessage.command else { return }
            startMessage.reply(with: "Check for a DM from me.") { replyMessageOrNil, error in
                guard let replyMessage = replyMessageOrNil else {
                    print_flush("Could not reply to start message. Error: \(String(describing: error))")
                    return
                }
                let seconds = self.config.verifyStartMessage.secondsBeforeDeletion
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                    self.discord.deleteMessage(replyMessage.id, from: replyMessage.channel.id, then: nil)
                    self.discord.deleteMessage(startMessage.id, from: startMessage.channel.id, then: nil)
                }
            }
    }
}
