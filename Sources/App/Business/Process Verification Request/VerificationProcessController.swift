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

class VerificationProcessController {
    
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
        case EmojiReaction.cross.rawValue: deny()
        default: return
        }
        
    }
}

fileprivate extension VerificationProcessController {
    
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
                    }
                }
            }
            
        }
    }
    
    func deny() {
        print("Deny")
    }
}
