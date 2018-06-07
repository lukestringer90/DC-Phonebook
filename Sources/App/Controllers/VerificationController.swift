//
//  VerificationController.swift
//  App
//
//  Created by Luke Stringer on 06/06/2018.
//

import Foundation

typealias SnowflakeID = UInt64

protocol VerificationMessage {
    var fromBot: Bool { get }
    var authorDMID: SnowflakeID { get }
    var authorID: SnowflakeID { get }
    var content: String { get }
}

enum Reaction: String {
    case cross = "❌"
    case tick = "✅"
}

protocol SendMessage {
 
    func send(_ messageText: String, to userID: SnowflakeID)
    func send(_ messageText: String, to userID: SnowflakeID, withReactions: [Reaction]?)
}

class VerificationController {
    
    fileprivate var userIDWizardMap = [UInt64: VerificationRequestWizard]()
    let messageSender: SendMessage
    
    init(messageSender: SendMessage) {
        self.messageSender = messageSender
    }
    
    func handler(message: VerificationMessage) {
        
        guard !message.fromBot else { return }
        let authorID = message.authorID
        let authorDMID = message.authorDMID
        
        if message.content == "!verify" {
            if self.userIDWizardMap[authorID] == nil {
                let wizard = VerificationRequestWizard(userID: authorID)
                wizard.delegate = self
                self.userIDWizardMap[authorID] = wizard
                messageSender.send(wizard.state.userMessage, to: authorDMID)
            }
        }
        else if let wizard = self.userIDWizardMap[authorID] {
            wizard.inputMessage(message.content)
            messageSender.send(wizard.state.userMessage, to: authorDMID)
        }
    }
}

extension VerificationController: VerificationRequestWizardDelegate {
    func wizard(_ wizard: VerificationRequestWizard, completedWith request: VerificationRequest) {
        print("Verificarion request created: \n\(request)")
        
        let message = """
        <@\(request.userID)>

        Scroll: <\(request.scrollName)>
        Forum: <\(request.forumPage)>
        """
        
        messageSender.send(message, to: Discord.ChannelID.phoneBookRequests, withReactions: [.tick, .cross])
        
        userIDWizardMap[request.userID] = nil
    }
}
