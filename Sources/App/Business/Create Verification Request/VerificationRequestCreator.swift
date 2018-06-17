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
    let roleService: RoleService
    let loggingService: LoggingService
    let verificationRequestStore: VerificationRequest.Store
    
    init(messageService: MessageService, roleService: RoleService, loggingService: LoggingService, verificationRequestStore store: VerificationRequest.Store) {
        self.messageService = messageService
        self.verificationRequestStore = store
        self.loggingService = loggingService
        self.roleService = roleService
    }
    
    func handle(message: VerificationMessage) {
        
        guard !message.fromBot else { return }
        let authorID = message.authorID
        let authorDMID = message.authorDMID
        
        guard !self.verificationRequestStore.all().contains(where: { return $0.userID == authorID} ) else {
            messageService.sendMessage("You alredy have a verification request waiting to be processed by the mods.", to: authorDMID)
            return
        }
        
        roleService.getRolesIDs(forUser: authorID) { roleIDsOrNil, error in
            guard let roleIDs = roleIDsOrNil else {
                print("Cannot get roles for user. Error: \(String(describing: error))")
                return
            }
            
            guard !roleIDs.contains(Constants.Discord.Role.verified) else {
                self.messageService.sendMessage("You are already verified.", to: authorDMID)
                return
            }
            
            if message.content == Constants.Discord.VerifyStartMessage {
                if self.userIDWizardMap[authorID] == nil {
                    self.loggingService.log(VerificationEvent.started(applicantID: authorID, at: Date()))
                    let wizard = VerificationRequestWizard(userID: authorID)
                    wizard.delegate = self
                    self.userIDWizardMap[authorID] = wizard
                    self.messageService.sendMessage(wizard.state.userMessage, to: authorDMID) { error in
                        print("\(String(describing: error))")
                    }
                }
                else {
                    self.loggingService.log(VerificationEvent.startedDuplicate(applicantID: authorID, at: Date()))
                }
            }
            else if let wizard = self.userIDWizardMap[authorID] {
                wizard.inputMessage(message.content)
                self.messageService.sendMessage(wizard.state.userMessage, to: authorDMID) { error in
                    print("\(String(describing: error))")
                }
            }
        }
    }
}

extension VerificationRequestCreator: VerificationRequestWizardDelegate {
    func wizard(_ wizard: VerificationRequestWizard, completedWith request: VerificationRequest) {
        print("Verificarion request created: \n\(request)")
        
        messageService.sendMessage(request.messageRepresentation, to: Constants.Discord.ChannelID.phoneBookRequests, withEmojiReactions: [.tick, .cross]) { errorOrNil in
            if let error = errorOrNil {
                print("Error posting verification request message: \(error)")
            }
            self.loggingService.log(VerificationEvent.requestSubmitted(request: request, at: Date()))
        }
        
        verificationRequestStore.add(request)
        userIDWizardMap[request.userID] = nil
    }
}
