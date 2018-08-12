//
//  Sword+RoleService.swift
//  App
//
//  Created by Luke Stringer on 15/06/2018.
//

import Foundation
import Sword

extension Sword: RoleService {
    func modify(user userID: UserID, in guildID: GuildID, toHaveRoles roleIDs: [RoleID], then completion: ServiceCompletion?) {
        let options = ["roles": roleIDs]
        modifyMember(Snowflake(userID), in: Snowflake(guildID), with: options) { error in
            completion?(error)
        }
    }
    
    func getRolesIDs(forUser userID: UserID, in guildID: GuildID, then completion: @escaping GetRolesCompletion) {
        getMember(Snowflake(userID), from: Snowflake(guildID)) { memberOrNil, error in
            guard let member = memberOrNil else {
                completion(nil, error)
                return
            }
            
            let roleIDs = member.roles.map { $0.id.rawValue }
            completion(roleIDs, nil)
        }
    }
}
