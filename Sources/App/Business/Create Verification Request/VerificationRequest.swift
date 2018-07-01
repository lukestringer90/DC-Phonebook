//
//  VerificationRequest.swift
//  App
//
//  Created by Luke Stringer on 11/06/2018.
//

import Foundation
import FluentProvider

class VerificationRequest: Model {
	let userID: UserID
	let scrollURL: String
	let forumPage: String
	let creationDate: Date
	let storage = Storage()
	
	init(userID: UserID, scrollURL: String, forumPage: String, creationDate: Date) {
		self.userID = userID
		self.scrollURL = scrollURL
		self.forumPage = forumPage
		self.creationDate = creationDate
	}
	
	required init(row: Row) throws {
		userID = try row.get("userID")
		scrollURL = try row.get("scrollURL")
		forumPage = try row.get("forumPage")
		creationDate = try row.get("creationDate")
	}
	
	func makeRow() throws -> Row {
		var row = Row()
		try row.set("userID", userID)
		try row.set("scrollURL", scrollURL)
		try row.set("forumPage", forumPage)
		try row.set("creationDate", creationDate)
		return row
	}
}

extension VerificationRequest: Equatable {
	static func == (lhs: VerificationRequest, rhs: VerificationRequest) -> Bool {
		return lhs.userID == rhs.userID &&
			lhs.scrollURL == rhs.scrollURL &&
			lhs.forumPage == rhs.forumPage &&
			lhs.creationDate == rhs.creationDate
	}
}

extension VerificationRequest {
	var messageRepresentation: String {
		get {
			return """
			\(userID.asTaggedMessage)
			
			Scroll: <\(scrollURL)>
			Forum: <\(forumPage)>
			"""
		}
	}
	
	static func extractUserID(from string: String) -> UserID {
		guard
			let at = string.index(of: "@"),
			let closingBracket = string.index(of: ">")
			else {
				fatalError("Cannot get user ID from message content")
		}
		
		let start = string.index(after: at)
		let end = string.index(before: closingBracket)
		
		let userIDString = string[start...end]
		
		guard let userIDNumber = UInt64(userIDString) else {
			fatalError("Cannot parse message string into double for user ID ")
		}
		
		return UserID(userIDNumber)
	}
}
