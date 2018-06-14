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
}

typealias RoleID = UInt64

protocol RoleService {
    func getRolesIDs(forUser userID: SnowflakeID, completion: @escaping ([RoleID]) -> ()) 
    func modify(user: SnowflakeID, toHaveRoles roles: [RoleID])
}

class VerificationProcessController {
    
    let roleService: RoleService
    
    init(roleService: RoleService) {
        self.roleService = roleService
    }
    
    func handle(reaction: ReactionToVerificationRequest) {
        
        let userIDNUmber = extractUserID(from: reaction.messageContent)
        let userID = SnowflakeID(userIDNUmber)
        
        switch reaction.emojiName {
        case EmojiReaction.tick.rawValue:approve(userID: userID)
        case EmojiReaction.cross.rawValue: deny()
        default: return
        }
        
    }
}

fileprivate extension VerificationProcessController {
    func extractUserID(from string: String) -> SnowflakeID {
        guard
            let at = string.index(of: "@"),
            let closingBracket = string.index(of: ">")
            else {
                fatalError("Cannot get user ID from message content")
        }
        
        let start = string.index(after: at)
        let end = string.index(before: closingBracket)
        
        let userIDString = string[start...end]
        
        guard let userIDDouble = Double(userIDString) else {
            fatalError("Cannot parse message string into double for user ID ")
        }
        
        return SnowflakeID(userIDDouble)
    }
    
    func approve(userID: SnowflakeID) {
        roleService.getRolesIDs(forUser: userID) { roleIDs in            
            let roleIDToAssign = Discord.Role.verified
            guard !roleIDs.contains(roleIDToAssign) else {
                print("User already verified")
                return
            }
            var newRoleIDs = roleIDs
            newRoleIDs.append(roleIDToAssign)
            self.roleService.modify(user: userID, toHaveRoles: newRoleIDs)
        }
    }
    
    func deny() {
        print("Deny")
    }
}
