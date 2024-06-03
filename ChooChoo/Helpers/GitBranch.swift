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
		static let plistFileName = "ChooChoo/Branch"
	}
	static var current: String? {
		guard let path: String = Bundle.main.path(forResource: Constants.plistFileName, ofType: "plist") else {
			Logger.gitBranch.error("branch.plist not found")
			return nil
		}
		guard let plist: [String: String] = NSDictionary(contentsOfFile: path) as? [String: String] else {
			Logger.gitBranch.error("branch.plist: string  not found")
			return nil
		}
		return plist[Constants.branchNameKey]
	}
}
