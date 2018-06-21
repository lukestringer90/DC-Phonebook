//
//  VerifyStartSignal.swift
//  App
//
//  Created by Luke Stringer on 19/06/2018.
//

import Foundation

struct VerifyStartSignal: Codable {
    let userID: UserID
    let guildID: GuildID
}

extension VerifyStartSignal {
    struct Store: StorageService {
        typealias Entity = VerifyStartSignal
        static var key = "verify-start-signal"
        static let shared = Store()
    }
}

extension VerifyStartSignal: Storable {
    typealias UniqueIDType = UserID
    
    func encode() -> Data {
        return try! JSONEncoder().encode(self)
    }
    static func decode(from data: Data) -> VerifyStartSignal {
        return try! JSONDecoder().decode(VerifyStartSignal.self, from: data)
    }
    
    var uniqueID: UserID {
        return userID
    }
}
