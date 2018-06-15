//
//  Sword+RoleService.swift
//  App
//
//  Created by Luke Stringer on 15/06/2018.
//

import Foundation
import Sword

extension Sword: RoleService {
    func modify(user userID: UserID, toHaveRoles roleIDs: [RoleID], then completion: @escaping ServiceCompletion) {
        let options = ["roles": roleIDs]
        modifyMember(Snowflake(userID), in: guildID, with: options) { error in
            completion(error)
        }
    }
    
    func getRolesIDs(forUser userID: UserID, then completion: @escaping GetRolesCompletion) {
        getMember(Snowflake(userID), from: guildID) { memberOrNil, error in
            guard let member = memberOrNil else {
                completion(nil, error)
                return
            }
            
            let roleIDs = member.roles.map { $0.id.rawValue }
            completion(roleIDs, nil)
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
