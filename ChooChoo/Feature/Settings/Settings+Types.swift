//
//  Settings.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 25.10.23.
//

import Foundation

extension JourneySettings {
	static func transferDurationCases(count : Int16?) -> JourneySettings.TransferDurationCases {
			switch count {
			case 5:
				return .five
			case 7:
				return .seven
			case 10:
				return .ten
			case 15:
				return .fifteen
			case 30:
				return .thirty
			case 45:
				return .fourtyfive
			case 60:
				return .sixty
			case 120:
				return .hundredtwenty
			default:
				return .zero
			}
	}
	
	enum TransferDurationCases : Int, Hashable, CaseIterable, Codable {
		case zero = 0
		case five = 5
		case seven = 7
		case ten = 10
		case fifteen = 15
		case twenty = 20
		case thirty = 30
		case fourtyfive = 45
		case sixty = 60
		case ninety = 90
		case hundredtwenty = 120
		
		var string : String {
			NSLocalizedString(
				"min \(self.rawValue) minutes",
				comment: "JourneySettings: TransferDurationCases"
			)
		}
		
		var defaultValue : Self {
			.zero
		}
	}
	
	enum TransferCountCases: Int, Hashable, CaseIterable, Codable {
		case unlimited
		case one
		case two
		case three
		case four
		case five

		var string : String {
			switch self {
			case .unlimited:
				NSLocalizedString("unlimited", comment: "JourneySettings: TransferCountCases")
			case .one:
				NSLocalizedString("max 1", comment: "JourneySettings: TransferCountCases")
			case .two:
				NSLocalizedString("max 2", comment: "JourneySettings: TransferCountCases")
			case .three:
				NSLocalizedString("max 3", comment: "JourneySettings: TransferCountCases")
			case .four:
				NSLocalizedString("max 4", comment: "JourneySettings: TransferCountCases")
			case .five:
				NSLocalizedString("max 5", comment: "JourneySettings: TransferCountCases")
			}
		}
		
		var queryValue : Int? {
			switch self {
			case .unlimited:
				return nil
			case .one:
				return 1
			case .two:
				return 2
			case .three:
				return 3
			case .four:
				return 4
			case .five:
				return 5
			}
		}
		
		var defaultValue : Self {
			.unlimited
		}
	}
	enum TransportMode : Hashable, Codable {
		case regional
		case all
		case custom
		
		var string : String {
			switch self {
			case .all:
				NSLocalizedString("all", comment: "JourneySettings: TransportMode")
			case .regional:
				NSLocalizedString("regional", comment: "JourneySettings: TransportMode")
			case .custom:
				NSLocalizedString("custom", comment: "JourneySettings: TransportMode")
			}
		}
		
		var defaultValue : Self {
			.all
		}
	}
	
	enum TransferTime : Hashable,Codable {
		case direct
		case time(minutes : TransferDurationCases)
		
		var defaultValue : Self {
			.time(minutes: .zero)
		}
	}
	enum Accessiblity: Hashable,Codable, CaseIterable {
		case partial
		case full
		
		var string : String {
			switch self {
			case .full:
				NSLocalizedString("full", comment: "JourneySettings: Accessiblity")
			case .partial:
				NSLocalizedString("partial", comment: "JourneySettings: Accessiblity")
			}
		}
		
		var defaultValue : Self {
			.partial
		}
	}
	enum WalkingSpeed : Hashable, Codable, CaseIterable{
		case fast
		case moderate
		case slow
		
		var string : String {
			switch self {
			case .fast:
				"fast"
			case .moderate:
				"moderate"
			case .slow:
				"slow"
			}
		}
		
		var defaultValue : Self {
			.fast
		}
	}
}
