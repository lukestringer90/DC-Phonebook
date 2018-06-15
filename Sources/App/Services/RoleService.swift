//
//  ServiceProtocols.swift
//  App
//
//  Created by Luke Stringer on 15/06/2018.
//

import Foundation

typealias GetRolesCompletion = ([RoleID]?, Error?) -> ()

protocol RoleService {
    
    func getRolesIDs(forUser userID: UserID, then completion: @escaping GetRolesCompletion)
    
    func modify(user userID: UserID, toHaveRoles roleIDs: [RoleID], then completion: @escaping ServiceCompletion)
}
