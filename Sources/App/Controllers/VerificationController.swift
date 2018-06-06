//
//  VerificationController.swift
//  App
//
//  Created by Luke Stringer on 06/06/2018.
//

import Foundation

typealias UserID = UInt64

protocol VerificationMessage {
    var fromBot: Bool { get }
    var authorID: UserID { get }
    var content: String { get }
}

protocol SendMessage {
    func send(_ messageText: String, to userID: UserID)
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
        
        if message.content == "!verify" {
            if self.userIDWizardMap[authorID] == nil {
                let wizard = VerificationRequestWizard(userID: authorID)
                wizard.delegate = self
                self.userIDWizardMap[authorID] = wizard
                messageSender.send(wizard.state.userMessage, to: authorID)
            }
        }
        else if let wizard = self.userIDWizardMap[authorID] {
            wizard.inputMessage(message.content)
            messageSender.send(wizard.state.userMessage, to: authorID)
        }
    }
}

extension VerificationController: VerificationRequestWizardDelegate {
    func wizard(_ wizard: VerificationRequestWizard, completedWith request: VerificationRequest) {
        print("Verificarion request created: \n\(request)")
        userIDWizardMap[request.userID] = nil
    }
}
