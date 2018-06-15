//
//  VerificationController.swift
//  App
//
//  Created by Luke Stringer on 06/06/2018.
//

import Foundation

protocol VerificationMessage {
    var fromBot: Bool { get }
    var authorDMID: RecepientID { get }
    var authorID: UserID { get }
    var content: String { get }
}

class VerificationRequestCreator {
    
    fileprivate var userIDWizardMap = [UInt64: VerificationRequestWizard]()
    let messageService: MessageService
    
    init(messageService: MessageService) {
        self.messageService = messageService
    }
    
    func handle(message: VerificationMessage) {
        
        guard !message.fromBot else { return }
        let authorID = message.authorID
        let authorDMID = message.authorDMID
        
        print(authorID)
        print(authorDMID)
        
        // Check there isn't already a wizard session open
        if message.content == "!verify" {
            if self.userIDWizardMap[authorID] == nil {
                let wizard = VerificationRequestWizard(userID: authorID)
                wizard.delegate = self
                self.userIDWizardMap[authorID] = wizard
                messageService.sendMessage(wizard.state.userMessage, to: authorDMID) { error in
                    print("\(String(describing: error))")
                }
            }
        }
        else if let wizard = self.userIDWizardMap[authorID] {
            wizard.inputMessage(message.content)
            messageService.sendMessage(wizard.state.userMessage, to: authorDMID) { error in
                print("\(String(describing: error))")
            }
        }
    }
}

extension VerificationRequestCreator: VerificationRequestWizardDelegate {
    func wizard(_ wizard: VerificationRequestWizard, completedWith request: VerificationRequest) {
        print("Verificarion request created: \n\(request)")
        
        messageService.sendMessage(request.messageRepresentation, to: Constants.Discord.ChannelID.phoneBookRequests, withEmojiReactions: [.tick, .cross]) { error in
            print("\(String(describing: error))")
        }
        
        userIDWizardMap[request.userID] = nil
    }
}
