//
//  ServiceProtocols.swift
//  App
//
//  Created by Luke Stringer on 15/06/2018.
//

import Foundation

typealias GetRolesCompletion = ([RoleID]?, Error?) -> ()

protocol RoleService {
    
    func getRolesIDs(forUser userID: UserID, in guildID: GuildID, then completion: @escaping GetRolesCompletion)
    
    func modify(user userID: UserID, in guildID: GuildID, toHaveRoles roleIDs: [RoleID], then completion: ServiceCompletion?)
}

extension RoleService {
    func modify(user userID: UserID, in guildID: GuildID, toHaveRoles roleIDs: [RoleID], then completion: ServiceCompletion? = nil) {
        modify(user: userID, in: guildID, toHaveRoles: roleIDs, then: completion)
    }
}
