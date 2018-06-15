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
}

class VerificationRequestProcessor {
    
    let roleService: RoleService
    let messageService: MessageService
    
    init(roleService: RoleService, messageService: MessageService) {
        self.roleService = roleService
        self.messageService = messageService
    }
    
    func handle(reaction: ReactionToVerificationRequest) {
        
        let userIDNUmber = VerificationRequest.extractUserID(from: reaction.messageContent)
        let userID = UserID(userIDNUmber)
        
        switch reaction.emojiName {
        case EmojiReaction.tick.rawValue:approve(userID: userID, reaction: reaction)
        case EmojiReaction.cross.rawValue: deny(userID: userID, reaction: reaction)
        default: return
        }
        
    }
}

fileprivate extension VerificationRequestProcessor {
    
    func approve(userID: UserID, reaction: ReactionToVerificationRequest) {
        roleService.getRolesIDs(forUser: userID) { roleIDsOrNil, error in
            guard let roleIDs = roleIDsOrNil else {
                print("\(String(describing: error))")
                return
            }
            
            let roleIDToAssign = Constants.Discord.Role.verified
            guard !roleIDs.contains(roleIDToAssign) else {
                print("User already verified")
                return
            }
            
            var newRoleIDs = roleIDs
            newRoleIDs.append(roleIDToAssign)
            
            self.roleService.modify(user: userID, toHaveRoles: newRoleIDs) { modifyError in
                guard modifyError == nil else {
                    print("\(String(describing: modifyError))")
                    return
                }
                
                self.messageService.sendMessage(reaction.messageContent, to: Constants.Discord.ChannelID.phoneBookDirectory) { sendError in
                    guard sendError == nil else {
                        print("\(String(describing: sendError))")
                        return
                    }
                    
                    self.messageService.deleteMessage(reaction.messageID, from: reaction.channelID) { deleteError in
                        guard deleteError == nil else {
                            print("\(String(describing: deleteError))")
                            return
                        }
                        
                        self.messageService.getDirectMessageID(forUser: userID) { recepientIDOrNil in
                            guard let recepientID = recepientIDOrNil else {
                                print("Cannot get direct message ID or \(userID)")
                                return
                            }
                            
                            let approvedState = VerificationRequest.State.approved
                            
                            self.messageService.sendMessage(approvedState.userMessage, to: recepientID) { sendError in
                                guard sendError == nil else {
                                    print("\(String(describing: sendError))")
                                    return
                                }
                            }
                        }
                        
                    }
                }
            }
            
        }
    }
    
    func deny(userID: UserID, reaction: ReactionToVerificationRequest) {
        
        messageService.deleteMessage(reaction.messageID, from: reaction.channelID) { deleteError in
            guard deleteError == nil else {
                print("\(String(describing: deleteError))")
                return
            }
            
            
            self.messageService.getDirectMessageID(forUser: userID) { recepientIDOrNil in
                guard let recepientID = recepientIDOrNil else {
                    print("Cannot get direct message ID or \(userID)")
                    return
                }
                
                let deniedState = VerificationRequest.State.denied
                
                self.messageService.sendMessage(deniedState.userMessage, to: recepientID) { sendError in
                    guard sendError == nil else {
                        print("\(String(describing: sendError))")
                        return
                    }
                }
            }   
        }
    }
}
