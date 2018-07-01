//
//  VerifyStartSignal.swift
//  App
//
//  Created by Luke Stringer on 19/06/2018.
//

import Foundation
import FluentProvider

// A Verify Start Signal capture the point at which a user (with an UserID) from a guild (with a GuildID) starts the verification process.
class VerifyStartSignal: Storable {
    let userID: UserID
    let guildID: GuildID
	
	init(userID: UserID, guildID: GuildID) {
		self.userID = userID
		self.guildID = guildID
	}
	
	// MARK: - Storable
	
	var uniqueID: UserID {
		return userID
	}
	typealias UniqueIDType = UserID
	
	// MARK: - Model
	
	let storage = Storage()
	
	required init(row: Row) throws {
		userID = try row.get("userID")
		guildID = try row.get("guildID")
	}
	
	func makeRow() throws -> Row {
		var row = Row()
		try row.set("userID", userID)
		try row.set("guildID", guildID)
		return row
	}
	
	// MARK: - Preperation
	
	static func prepare(_ database: Database) throws {
		try database.create(self) { signals in
			signals.id()
			// TODO: Make sure these work for UInt64
			signals.int("userID")
			signals.int("guildID")
		}
	}
	
	static func revert(_ database: Database) throws {
		try database.delete(self)
	}
}

extension VerifyStartSignal {
	struct Store: StorageService {
		typealias Entity = VerifyStartSignal
		static let shared = Store()
	}
}

