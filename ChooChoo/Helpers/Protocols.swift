//
//  Protocols.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 18.04.24.
//

import Foundation
import OSLog

protocol ChewEvent {
	var description : String { get }
}


protocol ChewStatus {
	var description : String { get }
}

protocol ChewViewModelProtocol {
	
}

extension ChewViewModelProtocol {
	static func log(_ status : any ChewStatus) {
		Logger.status("\(Self.self)", status: status)
	}
	static func log(_ event : any ChewEvent,_ status : any ChewStatus) {
		Logger.event("\(Self.self)", event: event,status: status)
	}
	static func logReducer(_ event : any ChewEvent,_ status : any ChewStatus) {
		Logger.reducer("\(Self.self)", event: event,status: status)
	}
}
