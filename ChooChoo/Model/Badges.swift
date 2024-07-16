//
//  Badges.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 21.09.23.
//

import Foundation
import SwiftUI

struct BadgeData : Equatable {
	static func == (lhs: BadgeData, rhs: BadgeData) -> Bool {
		lhs.text == rhs.text
	}
	
	var style : Color = Color.chewFillTertiary
	let text : Text
	
	init(style : Color, text : Text){
		self.init(text)
		self.style = style
	}
	init(style : Color){
		self.init()
		self.style = style
	}
	init(_ text : Text){
		self.text = text
	}
	init(){
		self.text = Text(verbatim: "")
	}
}

enum StopsCountBadgeMode {
	case hideShevron
	case showShevronUp
	case showShevronDown
	
	var angle : Double {
		switch self {
		case .hideShevron:
			return 0
		case .showShevronUp:
			return 0
		case .showShevronDown:
			return 180
		}
	}
}

enum Badges : Identifiable,Hashable {
	var id: Int {
		switch self {
		case .generic:
			return 0
		case .routeError:
			return 1
		case .followError:
			return 2
		case .locationError:
			return 3
		case .offlineMode:
			return 4
		case .departureArrivalStops:
			return 5
		case .changesCount:
			return 6
		case .timeDepartureTimeArrival:
			return 7
		case .date:
			return 8
		case .price:
			return 9
		case .cancelled:
			return 10
		case .connectionNotReachable:
			return 11
		case .remarkImportant:
			return 12
		case .lineNumber:
			return 13
		case .stopsCount:
			return 14
		case .legDirection:
			return 15
		case .legDuration:
			return 16
		case .walking:
			return 17
		case .transfer:
			return 18
		case .distance:
			return 19
		case .updatedAtTime:
			return 20
		case .updateError:
			return 21
		case .prognosedlegDirection:
			return 22
		}
	}
	
	case generic(msg : String)
	case updateError
	case routeError
	case followError(_ action : JourneyFollowViewModel.Action)
	case locationError
	case offlineMode
	case departureArrivalStops(departure: String,arrival: String)
	case changesCount(_ count : Int)
	case timeDepartureTimeArrival(timeContainer : TimeContainer)
	case date(date : Date)
	case price(_ price: Float)
	case cancelled
	case connectionNotReachable
	case remarkImportant(remarks : [RemarkViewData])
	case lineNumber(lineType:LineType,num : String)
	case stopsCount(_ count : Int,_ mode : StopsCountBadgeMode)
	case legDirection(dir : String, strikethrough : Bool,multiline : Bool)
	case prognosedlegDirection(dir : Prognosed<StopViewData>, strikethrough : Bool,multiline : Bool)
	case legDuration(_ timeContainer : TimeContainer)
	case walking(_ timeContainer : TimeContainer)
	case transfer(_ timeContainer : TimeContainer)
	case distance(dist : Double)
	case updatedAtTime(referenceTime : Double, isLoading : Bool = false)
	
	var badgeAction : ()->Void {
		switch self{
		case .remarkImportant(remarks: let remark):
			return {
				Model.shared.sheetVM.send(event: .didRequestShow(.remark(remarks: remark)))
			}
		default:
			return {}
		}
	}
	
	var badgeDefaultStyle : BadgeBackgroundBaseStyle {
		switch self {
		case .cancelled,
			 .connectionNotReachable,
			 .remarkImportant:
			return .red
		default:
			return .primary
		}
	}
	
	var badgeData : BadgeData {
		switch self {
		case .generic(let msg):
			return BadgeData(Text(verbatim: msg))
		case .updateError:
			return BadgeData(
				Text(
					"unable to update",
					comment: "badge"
				)
			)
		case .routeError:
			return BadgeData(
				Text(
					"The entire route could not be loaded",
					comment: "badge"
				)
			)
		case .followError(let action):
			return BadgeData(
				Text(
					"Failed to \(action.text) this journey",
					comment: "badge: followError"
				)
			)
		case .locationError:
			return BadgeData(
				Text(
					"Failed to get location",
					comment: "badge"
				)
			)
		case .offlineMode:
			return BadgeData(
				Text(
					"Offline",
					comment: "badge"
				)
			)
		case .price:
			return BadgeData()
		case .cancelled:
			return BadgeData(
				style: Color.chewFillRedPrimary,
				text: Text(
					"cancelled",
					comment: "badge"
				)
			)
		case .connectionNotReachable:
			return BadgeData(
				style: Color.chewFillRedPrimary,
				text: Text(
					"not reachable",
					comment: "badge"
				)
			)
		case .remarkImportant:
			return BadgeData(
				style: Color.chewFillRedPrimary,
				text: Text(verbatim: "!")
			)
		case .lineNumber(_, num: let num):
			return BadgeData(
				style: .chewGrayScale10,
				text: Text(verbatim: "\(num.replacingOccurrences(of: " ", with: ""))")
			)
		case let .legDirection(dir,_,_):
			return BadgeData(
				Text(verbatim: dir)
			)
		case .prognosedlegDirection:
			return BadgeData()
		case .stopsCount(let num, _):
			return BadgeData(
				Text(
					"\(num) stop",
					comment: "badge: stopsCount"
				)
			)
		case .distance:
			return BadgeData()
		case .walking(let time):
			return BadgeData(
				Text(
					"walk \(time.durationInMinutes) min",
					comment: "badge: walking"
				)
			)
		case .legDuration:
			return BadgeData()
		case .transfer(let time):
			let dur = DateParcer.timeDuration(time.durationInMinutes) ?? ""
				return BadgeData(
					Text(
						"transfer \(dur)",
						comment: "badge"
					)
				)
		case .departureArrivalStops:
			return BadgeData()
		case .changesCount:
			return BadgeData()
		case .timeDepartureTimeArrival:
			return BadgeData(style: Color.chewFillSecondary)
		case .date:
			return BadgeData(style: Color.chewFillSecondary)
		case .updatedAtTime:
			return BadgeData(style: Color.chewFillSecondary)
		}
	}
}
