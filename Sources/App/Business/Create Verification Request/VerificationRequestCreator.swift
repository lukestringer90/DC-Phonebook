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
    var guildID: GuildID { get }
    var content: String { get }
}

class VerificationRequestCreator {
    
    fileprivate var userIDWizardMap = [UInt64: VerificationRequestWizard]()
    let messageService: MessageService
    let roleService: RoleService
    let loggingService: LoggingService
    let verificationRequestStore: VerificationRequest.Store
//    let verifyStartSignalStore: VerifyStartSignal.Store

    let config: DiscordConfig
    
    init(messageService: MessageService, roleService: RoleService, loggingService: LoggingService, verificationRequestStore requestStore: VerificationRequest.Store, config: DiscordConfig) {
        self.messageService = messageService
        self.verificationRequestStore = requestStore
        self.loggingService = loggingService
        self.roleService = roleService
//        self.verifyStartSignalStore = signalStore
        self.config = config
    }
    
    func handle(message: VerificationMessage) {
        
        guard !message.fromBot else { return }
        let authorID = message.authorID
        let authorDMID = message.authorDMID
        
        guard verificationRequestStore.getFirst(matching: authorID) == nil else {
            messageService.sendMessage("You already have a verification request waiting to be processed by the mods.", to: authorDMID)
            return
        }
        
        roleService.getRolesIDs(forUser: authorID, in: message.guildID) { roleIDsOrNil, error in
            guard let roleIDs = roleIDsOrNil else {
                print("Cannot get roles for user. Error: \(String(describing: error))")
                return
            }
            
            guard !roleIDs.contains(self.config.roleIDs.verified) else {
                self.messageService.sendMessage("You are already verified.", to: authorDMID)
                return
            }
            
            if message.content == self.config.verifyStartMessage.command {
                if self.userIDWizardMap[authorID] == nil {
                    self.loggingService.log(VerificationEvent.started(command: self.config.verifyStartMessage.command, applicantID: authorID, at: Date()))
                    let wizard = VerificationRequestWizard(userID: authorID)
                    wizard.delegate = self
                    self.userIDWizardMap[authorID] = wizard
                    self.messageService.sendMessage(wizard.state.userMessage, to: authorDMID) { error in
						if let error = error {
							print("Failed to send wizard state \(wizard.state) to \(authorID). Error: \(String(describing: error))")
						}
                    }
                }
                else {
                    self.loggingService.log(VerificationEvent.startedDuplicate(command: self.config.verifyStartMessage.command, applicantID: authorID, at: Date()))
                }
            }
            else if let wizard = self.userIDWizardMap[authorID] {
                wizard.inputMessage(message.content)
                self.messageService.sendMessage(wizard.state.userMessage, to: authorDMID) { error in
					if let error = error {
						print("Failed to send wizard state \(wizard.state) to \(authorID). Error: \(String(describing: error))")
					}
                }
            }
        }
    }
}

extension VerificationRequestCreator: VerificationRequestWizardDelegate {
    func wizard(_ wizard: VerificationRequestWizard, completedWith request: VerificationRequest) {
        
        messageService.sendMessage(request.messageRepresentation, to: config.channelIDs.phoneBookRequests, withEmojiReactions: [.tick, .cross]) { error in
            defer {
                self.userIDWizardMap[request.userID] = nil
            }
            
            guard error == nil else {
                print("Failed to post verification request message. Error: \(String(describing: error))")
                return
            }
            
            self.verificationRequestStore.add(request)
//            self.verifyStartSignalStore.remove(matching: request.userID)
			
            self.loggingService.log(VerificationEvent.requestSubmitted(request: request, at: Date()))
        }
    }
}
