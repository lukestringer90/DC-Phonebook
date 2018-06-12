//
//  VerificationRequest.swift
//  App
//
//  Created by Luke Stringer on 11/06/2018.
//

import Foundation

struct VerificationRequest: Equatable {
    let userID: UInt64
    let scrollURL: String
    let forumPage: String
    let creationDate: Date
}
