//
//  VerificationReques+Storage.swift
//  App
//
//  Created by Luke Stringer on 16/06/2018.
//

import Foundation
import FluentProvider

extension VerificationRequest {
    struct Store: StorageService {
        typealias Entity = VerificationRequest
        static var key = "verification-request"
        static let shared = Store()
    }
}

extension VerificationRequest: Storable {
    typealias UniqueIDType = UInt64
    
    var uniqueID: UInt64 {
        return userID
    }
}

extension VerificationRequest: Preparation {
	static func prepare(_ database: Database) throws {
		try database.create(self) { signals in
			signals.id()
			// TODO: Make sure these work for UInt64
			signals.int("userID")
			signals.string("scrollURL")
			signals.string("forumPage")
			signals.date("creationDate")
		}
	}
	
	static func revert(_ database: Database) throws {
		try database.delete(self)
	}
}
