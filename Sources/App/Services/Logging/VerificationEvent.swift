//
//  VerificationEvent.swift
//  App
//
//  Created by Luke Stringer on 17/06/2018.
//

import Foundation

enum VerificationEvent: Event {
    case requestAccepted(applicant: UserID, reviewer: UserID, at: Date)
    case requestDenied(applicant: UserID, reviewer: UserID, at: Date)
    case requestSubmitted(request: VerificationRequest, at: Date)
    case roleApplied(userID: UserID, at: Date)
    
    func message() -> String {
        switch self {
        case .requestAccepted(let applicantID, let reviewerID, let date):
            return "\(date.asLogFormat): \(reviewerID.asTaggedMessage) **APPROVED** request for \(applicantID.asTaggedMessage)"
        case .requestDenied(let applicantID, let reviewerID,  let date):
            return "\(date.asLogFormat): \(reviewerID.asTaggedMessage) **DENIED** request for \(applicantID.asTaggedMessage)"
        case .requestSubmitted(let request, let date):
            return "\(date.asLogFormat): \(request.userID.asTaggedMessage) **SUBMITTED** request:\n\n\(request.messageRepresentation)"
        case .roleApplied(let userID,  let date):
            return "\(date.asLogFormat): \(userID.asTaggedMessage) became `Verified`"
        }
    }
}

fileprivate extension Date {
    var asLogFormat: String {
        get {
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .long
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            return "`[\(formatter.string(from: self))]`"
        }
    }
}
