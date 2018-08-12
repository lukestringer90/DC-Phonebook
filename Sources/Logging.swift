//
//  Logging.swift
//  BCrypt
//
//  Created by Luke Stringer on 12/08/2018.
//

import Foundation

func print_flush(_ items: Any...) {
	print(items)
	fflush(stdout)
}

func fataError_flush(_ items: Any...) -> Never {
	print_flush(items)
	fatalError()
}
