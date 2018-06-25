//
//  VerificationProcessController.swift
//  App
//
//  Created by Luke Stringer on 10/06/2018.
//

import Foundation

protocol ReactionToVerificationRequest {
    var messageContent: String { get }
    var emojiName: String { get }
    var messageID: MessageID { get }
    var channelID: RecepientID { get }
    var reactorID: UserID { get }
    var guildID: GuildID { get }
}

class VerificationRequestProcessor {
    
    let roleService: RoleService
    let messageService: MessageService
    let loggingService: LoggingService
    let verificationRequestStore: VerificationRequest.Store
    
    init(roleService: RoleService, messageService: MessageService, loggingService: LoggingService, verificationRequestStore store: VerificationRequest.Store) {
        self.roleService = roleService
        self.messageService = messageService
        self.loggingService = loggingService
        self.verificationRequestStore = store
    }
    
    func handle(reaction: ReactionToVerificationRequest) {
        
        let userIDNUmber = VerificationRequest.extractUserID(from: reaction.messageContent)
        let userID = UserID(userIDNUmber)
        
        switch reaction.emojiName {
        case EmojiReaction.tick.rawValue: approve(userID: userID, reaction: reaction, then: processorCompleted)
        case EmojiReaction.cross.rawValue: deny(userID: userID, reaction: reaction, then: processorCompleted)
        default: return
        }
    }
}

fileprivate extension VerificationRequestProcessor {
    
    typealias ProcessorCompletion = (UserID, Bool) -> ()
    
    func processorCompleted(for userID: UserID, success: Bool) {
        guard success else { return }
        
        guard let request = verificationRequestStore.getFirst(matching: userID) else {
            print("No request in store")
            return
        }
        self.verificationRequestStore.remove(request)
    }
    
    func approve(userID: UserID, reaction: ReactionToVerificationRequest, then completion: @escaping ProcessorCompletion) {
        roleService.getRolesIDs(forUser: userID, in: reaction.guildID) { roleIDsOrNil, error in
            guard let roleIDs = roleIDsOrNil else {
				print("Failed to get roles for \(userID). Error: \(String(describing: error))")
                completion(userID, false)
                return
            }
            
            let roleIDToAssign = Constants.Discord.Role.verified
            guard !roleIDs.contains(roleIDToAssign) else {
                print("User \(userID) already verified")
                completion(userID, false)
                return
            }
            
            var newRoleIDs = roleIDs
            newRoleIDs.append(roleIDToAssign)
            
            self.roleService.modify(user: userID, in: reaction.guildID, toHaveRoles: newRoleIDs) { modifyError in
                guard modifyError == nil else {
                    print("Failed to modify roles for user \(userID). Error: \(String(describing: error))")
                    completion(userID, false)
                    return
                }
                
                self.loggingService.log(VerificationEvent.requestAccepted(applicant: userID, reviewer: reaction.reactorID, at: Date()))
                
                self.messageService.sendMessage(reaction.messageContent, to: Constants.Discord.ChannelID.phoneBookDirectory) { sendError in
                    guard sendError == nil else {
                        print("Failed to send verification messasge content to phonebook channel. Error: \(String(describing: error))")
                        completion(userID, false)
                        return
                    }
                    
                    self.messageService.deleteMessage(reaction.messageID, from: reaction.channelID) { deleteError in
                        guard deleteError == nil else {
                            print("Failed to delete message \(reaction.messageID). Error: \(String(describing: error))")
                            completion(userID, false)
                            return
                        }
                        
                        self.messageService.getDirectMessageID(forUser: userID) { recepientIDOrNil in
                            guard let recepientID = recepientIDOrNil else {
                                print("Cannot get direct message ID or \(userID)")
                                completion(userID, false)
                                return
                            }
                            
                            let approvedState = VerificationRequest.State.approved
                            
                            self.messageService.sendMessage(approvedState.userMessage, to: recepientID) { sendError in
                                guard sendError == nil else {
									print("Failed to send approved message to \(recepientID). Error: \(String(describing: error))")
                                    completion(userID, false)
                                    return
                                }
                                
                                completion(userID, true)
                            }
                        }
                        
                    }
                }
            }
            
        }
    }
    
    func deny(userID: UserID, reaction: ReactionToVerificationRequest, then completion: @escaping ProcessorCompletion) {
        
        messageService.deleteMessage(reaction.messageID, from: reaction.channelID) { deleteError in
            guard deleteError == nil else {
				print("Failed to delete message \(reaction.messageID). Error: \(String(describing: deleteError))")
                print("\(String(describing: deleteError))")
                completion(userID, false)
                return
            }
            
            
            self.messageService.getDirectMessageID(forUser: userID) { recepientIDOrNil in
                guard let recepientID = recepientIDOrNil else {
                    print("Cannot get direct message ID or \(userID)")
                    completion(userID, false)
                    return
                }
                
                let deniedState = VerificationRequest.State.denied
                
                self.messageService.sendMessage(deniedState.userMessage, to: recepientID) { sendError in
                    guard sendError == nil else {
                        print("Failed to send denied message to \(recepientID). Error: \(String(describing: sendError))")
                        completion(userID, false)
                        return
                    }
                    self.loggingService.log(VerificationEvent.requestDenied(applicant: userID, reviewer: reaction.reactorID, at: Date()))
                    completion(userID, true)
                }
            }   
        }
    }
}
