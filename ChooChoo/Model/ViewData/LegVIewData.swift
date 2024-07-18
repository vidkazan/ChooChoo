//
//  ViewData.swift
//  49EuroTravel
//
//  Created by Dmitrii Grigorev on 09.08.23.
//

import Foundation
import SwiftUI
import CoreLocation

struct LegViewData : Hashable,Identifiable {
	let id = UUID()
	var isReachableFromPreviousLeg : Bool
	let legType : LegType
	let tripId : String
	let direction : Prognosed<String>
	let legTopPosition : Double
	let legBottomPosition : Double
	var delayedAndNextIsNotReachable : Bool?
	let remarks : [RemarkViewData]
	let legStopsViewData : [StopViewData]
	let footDistance : Int
	let lineViewData : LineViewData
	let progressSegments : Segments
	let time : TimeContainer
	let polyline : PolylineDTO?
	let legDTO : LegDTO?
}

extension LegViewData {
	func departureAndArrivalNotCancelled() -> Bool {
		if legStopsViewData.count > 1 {
			return self.legStopsViewData.first?.cancellationType() != .fullyCancelled &&
			self.legStopsViewData.last?.cancellationType() != .fullyCancelled
		} else {
			return time.arrivalStatus != .cancelled && time.departureStatus != .cancelled
		}
	}
	
	func departureAndArrivalNotCancelledAndNotReachableFromPreviousLeg() -> Bool {
		return departureAndArrivalNotCancelled() && isReachableFromPreviousLeg
	}
}

extension LegViewData {
	init(){
		self.isReachableFromPreviousLeg = true
		self.legType = .line
		self.tripId = ""
		self.direction = .init()
		self.legTopPosition = 0
		self.legBottomPosition = 0
		self.delayedAndNextIsNotReachable = false
		self.legStopsViewData = []
		self.footDistance = 0
		self.lineViewData = LineViewData(type: .taxi, name: "", shortName: "",id: nil)
		self.progressSegments = Segments(segments: [], heightTotalCollapsed: 0, heightTotalExtended: 0)
		self.time = TimeContainer(plannedDeparture: "", plannedArrival: "", actualDeparture: "", actualArrival: "", cancelled: false)
		self.remarks = []
		self.polyline = nil
		self.legDTO = nil
	}
}

extension LegViewData {
	init(footPathStops : DepartureArrivalPairStop){
		
		let arrival = StopViewData(
			id: nil,
			   locationCoordinates: footPathStops.arrival.coordinates,
			   name: "",
			   platforms: .init(departure: .init(), arrival: .init()),
			   time: .init(),
			   stopOverType: .destination
		   )
		
		self.isReachableFromPreviousLeg = true
		self.legType = .footMiddle
		self.tripId = ""
		self.direction = Prognosed(actual: arrival.name,planned: arrival.name)
		self.legTopPosition = 0
		self.legBottomPosition = 0
		self.delayedAndNextIsNotReachable = false
		self.legStopsViewData = [
			.init(
				id: nil,
				locationCoordinates: footPathStops.departure.coordinates,
				name: "",
				platforms: .init(departure: .init(), arrival: .init()),
				time: .init(),
				stopOverType: .origin
			),
			arrival
		]
		self.footDistance = 0
		self.lineViewData = LineViewData(type: .foot, name: "", shortName: "", id: nil)
		self.progressSegments = Segments(segments: [], heightTotalCollapsed: 0, heightTotalExtended: 0)
		self.time = TimeContainer(plannedDeparture: "", plannedArrival: "", actualDeparture: "", actualArrival: "", cancelled: false)
		self.remarks = []
		self.polyline = nil
		self.legDTO = nil
	}
}
enum LocationDirectionType : Int, Hashable, CaseIterable {
	case departure
	case arrival
	
	var placeholder : String {
		switch self {
		case .departure:
			return NSLocalizedString("from", comment: "LocationDirationType: textFieldPlaceholder")
		case .arrival:
			return NSLocalizedString("to", comment: "LocationDirationType: textFieldPlaceholder")
		}
	}
	
	var description : String {
		switch self {
		case .departure:
			return NSLocalizedString("Departure", comment: "LocationDirationType: description")
		case .arrival:
			return NSLocalizedString("Arrival", comment: "LocationDirationType: description")
		}
	}
	
	func sendEvent(send : @escaping (ChewViewModel.Event)->Void)  {
		switch self {
		case .departure:
			send(.didLocationButtonPressed(send: send))
		case .arrival:
			send(.onStopsSwitch)
		}
	}
	
	var baseImage : Image {
		switch self {
		case .departure:
			return Image(.location)
		case .arrival:
			return Image(.arrowUpArrowDown)
		}
	}
}

struct LineViewData : Hashable, Codable {
	let type : LineType
	let name : String
	let shortName : String
	let id: String?
}

extension LegViewData {
	static func direction(stops : [StopViewData], plannedDirectionName : String?) -> Prognosed<String> {
		let lastAvailable = stops.reversed().first(where: {
			$0.cancellationType() == .exitOnly || $0.cancellationType() == .notCancelled
		})
		let stopNameIfLastStopsAreCancelled = {
			lastAvailable == stops.last ? nil : lastAvailable?.name
		}()
		
		if let stopNameIfLastStopsAreCancelled = stopNameIfLastStopsAreCancelled {
			return Prognosed<String>(actual: stopNameIfLastStopsAreCancelled,planned: plannedDirectionName)
		} else {
			return Prognosed<String>(actual: plannedDirectionName,planned: plannedDirectionName)
		}
	}
}

extension LegViewData {
	static func lastReachableStop(stops : [StopViewData]) -> StopViewData? {
		let lastAvailable = stops.reversed().first(where: {
			$0.cancellationType() == .exitOnly || $0.cancellationType() == .notCancelled
		})
		
		return lastAvailable == stops.last ? stops.last : lastAvailable
	}
}

extension LegViewData {
	enum LegType : Equatable,Hashable, Codable {
		case footStart(startPointName : String)
		case footMiddle
		case footEnd(finishPointName : String)
		case transfer
		case line
		
		var caseDescription : String {
			switch self {
			case .footStart:
				return "footStart"
			case .footMiddle:
				return "footMiddle"
			case .footEnd:
				return "footEnd"
			case .transfer:
				return "transfer"
			case .line:
				return "line"
			}
		}
	}
}
extension LegViewData {
	var options : [Option] {
		#if DEBUG
		switch legType {
			case .line: [
				Self.showOnMapOption,
				Self.routeOption,
				Self.debug
			]
			default: [Self.showOnMapOption]
		}
		#else
		switch legType {
			case .line: [
				Self.showOnMapOption,
				Self.routeOption
			]
			default: [Self.showOnMapOption]
		}
		#endif
	}
}

extension LegViewData {
	struct Option {
		let action : (LegViewData)->()
		let icon : String
		let text : String
	}
	
	static let showOnMapOption = Option(
		action: { leg in
			switch leg.legType {
			case .line,.transfer:
				Model.shared.sheetVM.send(event: .didRequestShow(.mapDetails(.lineLeg(leg))))
			default:
				Model.shared.sheetVM.send(event: .didRequestShow(.mapDetails(.footDirection(leg))))
			}
		},
		icon: "map",
		text : NSLocalizedString(
			"Show on map",
			comment: "LegDetailsView: menu item"
		)
	)
	
	static let debug = Option(
		action: { leg in
			if let dto = leg.legDTO {
				Model.shared.sheetVM.send(event: .didRequestShow(.journeyDebug(legs: [dto])))
			} else {
				Model.shared.topBarAlertVM.send(event: .didRequestShow(.generic(msg: "Debug error : legDTO is nil")))
			}
		},
		icon: "ant",
		text : NSLocalizedString(
			"Debug leg",
			comment: "Debug"
		)
	)
	static let routeOption = Option(
		action: { leg in
			Model.shared.sheetVM.send(
				event: .didRequestShow(.route(leg: leg))
			)
		},
		icon: ChooSFSymbols.trainSideFrontCar.rawValue,
		text: NSLocalizedString(
			"Show whole route",
			comment: "LegDetailsView: menu item"
		)
	)
}
