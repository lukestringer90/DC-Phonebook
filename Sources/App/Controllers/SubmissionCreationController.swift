//
//  SubmissionCreationController.swift
//  App
//
//  Created by Luke Stringer on 02/06/2018.
//

import Foundation

struct Submission {
	let userID: String
	let scrollName: String
	let forumPage: String
	let creationDate: Date
}

protocol SubmissionCreationControllerDelegate {
	func sendMessage(_ message: String, to user: MessageAuthor)
	func controller(_ controller: SubmissionCreationController, didCreateSubmission: Submission)
}

typealias Username = String

protocol MessageAuthor {
	var id: String { get }
	var username: String { get }
}

class SubmissionCreationController {
	
	let author: MessageAuthor
	
	init(author: MessageAuthor) {
		self.author = author
	}
	
	func input(message: String) {
		
	}
}
