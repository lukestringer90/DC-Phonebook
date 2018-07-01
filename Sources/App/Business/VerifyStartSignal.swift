//
//  VerifyStartSignal.swift
//  App
//
//  Created by Luke Stringer on 19/06/2018.
//

import Foundation
import FluentProvider

// A Verify Start Signal capture the point at which a user (with an UserID) from a guild (with a GuildID) starts the verification process.
class VerifyStartSignal: Model {
    let userID: UserID
    let guildID: GuildID
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
}
