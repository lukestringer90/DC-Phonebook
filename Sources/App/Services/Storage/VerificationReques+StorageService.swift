//
//  VerificationReques+Storage.swift
//  App
//
//  Created by Luke Stringer on 16/06/2018.
//

import Foundation


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
    
    func encode() -> Data {
        return try! JSONEncoder().encode(self)
    }
    static func decode(from data: Data) -> VerificationRequest {
        return try! JSONDecoder().decode(VerificationRequest.self, from: data)
    }
}
