//
//  LoggingService.swift
//  App
//
//  Created by Luke Stringer on 17/06/2018.
//

import Foundation

// Conform String to Event so it can be logged
protocol Event {
    func message() -> String
}

protocol LoggingService {
    func log(_ event: Event)
}
