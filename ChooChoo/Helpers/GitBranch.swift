//
//  GitBranch.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 03.06.24.
//

import Foundation
import OSLog

struct GitBranch {
	private struct Constants {
		static let branchNameKey = "branch"
		static let plistFileName = "Branch"
		static let pattern = "CHOO-\\d+"
	}
	
	static let shared = GitBranch()
	 
	init() {
		self.current = Self.getCurrent()
	}
	
	let current: (branchNumber : String, branchName : String)?
	
	private static func getCurrent() -> (branchNumber : String, branchName : String)? {
		guard let path: String = Bundle.main.path(forResource: Constants.plistFileName, ofType: "plist") else {
			Logger.gitBranch.error("Branch.plist not found")
			return nil
		}
		guard let plist: [String: String] = NSDictionary(contentsOfFile: path) as? [String: String] else {
			Logger.gitBranch.error("Branch.plist: string  not found")
			return nil
		}
		guard let string = plist[Constants.branchNameKey] else {
			return nil
		}
		

		if let range = string.range(of: Constants.pattern, options: .regularExpression) {
			let result = string[range]
			return (String(result),string)
		} else {
			Logger.gitBranch.error("Branch.plist: branch number string  parse error:")
			return ("","main")
		}
	}
}
