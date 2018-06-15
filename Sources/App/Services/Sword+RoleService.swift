//
//  Sword+RoleService.swift
//  App
//
//  Created by Luke Stringer on 15/06/2018.
//

import Foundation
import Sword

extension Sword: RoleService {
    func getRolesIDs(forUser userID: UserID, then completion: @escaping ([RoleID]) -> ()) {
        getMember(Snowflake(userID), from: guildID) { memberOrNil, error in
            guard let member = memberOrNil else {
                fatalError("Cannot get member")
            }
            
            let roleIDs = member.roles.map { $0.id.rawValue }
            completion(roleIDs)
        }
    }
    
    func modify(user userID: UserID, toHaveRoles roleIDs: [RoleID], then completion: @escaping (Error?) -> ()) {
        let options = ["roles": roleIDs]
        modifyMember(Snowflake(userID), in: guildID, with: options) { error in
            completion(error)
        }
        
    }
    
    private var guildID: Snowflake {
        get {
            guard let guildID = guilds.first?.value.id else {
                fatalError("Cannot get guild")
            }
            return guildID
        }
    }
}
