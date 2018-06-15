//
//  Constants.swift
//  App
//
//  Created by Luke Stringer on 06/06/2018.
//

import Foundation

// TODO: Wrap in Constants namespace
struct Discord {
    struct Username {
        static let phonebookBot = "DC-Phonebook"
    }
    
    struct ChannelID {
        static let general = UInt64(452225589978464267)
        static let botDebug = UInt64(452229749927051278)
        static let dm_lukestringer90 = UInt64(452225869667368960)
        static let phoneBookRequests = UInt64(450397327295905803)
        static let phoneBookDirectory = UInt64(454020185104580608)
        static let phoneBookTesting = UInt64(454020308228374559)
    }
    
    struct Role {
        static let mod = UInt64(454020308228374559)
        static let verified = UInt64(455104920673058817)
    }
}
