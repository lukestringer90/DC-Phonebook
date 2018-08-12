//
//  Driver+Helpers.swift
//  BCrypt
//
//  Created by Luke Stringer on 04/08/2018.
//

import Foundation
import Vapor
import URI
import PostgreSQLDriver

extension PostgreSQLDriver.Driver {
	/// See PostgreSQLDriver.init(host: String, ...)
	public convenience init(url: String) throws {
		let uri = try URI(url)
		guard
			let user = uri.userInfo?.username,
			let pass = uri.userInfo?.info
			else {
				throw ConfigError.missing(key: ["url(userInfo)"], file: "postgresql", desiredType: URI.self)
		}
		
		let db = uri.path
			.characters
			.split(separator: "/")
			.map { String($0) }
			.joined(separator: "")
		
		try self.init(
			masterHostname: uri.hostname,
			readReplicaHostnames: [],
			user: user,
			password: pass,
			database: db,
			port: uri.port.flatMap { Int($0) } ?? 5432
		)
	}
}
