//
//  +state.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 11.09.23.
//

import Foundation
import CoreLocation
import CoreData
import SwiftUI


extension ChewViewModel {
	enum TextFieldContent : Equatable,Hashable {
		case textOnly(String)
		case location(Stop)
		case transport(LegViewData)
		
		var text : String {
			switch self {
			case .textOnly(let text):
				return text
			case .location(let stop):
				return stop.name
			case .transport(let leg):
				return "\(leg.lineViewData.name) \(leg.lineViewData.id ?? "") \(JourneyAlternativesView.getCurrentLegAlternativeJourneyDepartureStop(leg: leg, referenceDate: .now)?.alternativeDeparture.leg?.direction.actual?.name ?? "" )"
			}
		}
		
		var stop : Stop? {
			switch self {
			case .textOnly:
				return nil
			case .location(let stop):
				return stop
			case .transport(let leg):
				return JourneyAlternativesView.getCurrentLegAlternativeJourneyDepartureStop(leg: leg, referenceDate: .now)?.alternativeDeparture.stopViewData.stop()
			}
		}
		
		var leg : LegViewData? {
			switch self {
			case .textOnly:
				return nil
			case .location:
				return nil
			case .transport(let leg):
				return leg
			}
		}
	}
	
	struct StateData : Equatable {
		let  depStop : TextFieldContent
		let arrStop : TextFieldContent
		let journeySettings : JourneySettings
		let date : SearchStopsDate
		
		func getStop(type : LocationDirectionType) -> TextFieldContent {
			switch type {
			case .departure:
				return depStop
			case .arrival:
				return arrStop
			}
		}
	}
	
	struct State : Equatable {
		let data : StateData
		let status : Status
	}
	
	
	enum Status : ChewStatus {
		case start
		case loadingInitialData
		case idle
		case checkingSearchData
		case journeys(_ stops : DepartureArrivalPairStop)
		case editingStop(LocationDirectionType)
		case loadingLocation(send : (ChewViewModel.Event)->Void)
		
		
		var description : String {
			switch self {
			case .editingStop(let type):
				return "editingStop \(type)"
			case .idle:
				return "idle"
			case .checkingSearchData:
				return "checkingSearchData"
			case .journeys:
				return "journeys"
			case .loadingLocation:
				return "loadingLocation"
			case .start:
				return "start"
			case .loadingInitialData:
				return "loadingInitialData"
			}
		}
	}
	enum Event : ChewEvent {
		case didStartViewAppear
		case didLoadInitialData(JourneySettings)
		case onStopEdit(LocationDirectionType)
		case didUpdateSearchData(
			dep: TextFieldContent?  = nil,
			arr: TextFieldContent?  = nil,
			date: SearchStopsDate?  = nil,
			journeySettings : JourneySettings?  = nil
		)
		
		case onJourneyDataUpdated(_ stops : DepartureArrivalPairStop)
		
		
		case onStopsSwitch
		case onNotEnoughSearchData
		case didCancelEditStop
		case didTapCloseJourneyList
		case didLocationButtonPressed(send : (ChewViewModel.Event)->Void)
		case didReceiveLocationData(Stop)
		case didFailToLoadLocationData
		
		var description : String {
			switch self {
			case .didUpdateSearchData:
				return "didUpdateSearchData"
			case .didCancelEditStop:
				return "didCancelEditStop"
			case .onStopEdit(let type):
				return "onStopEdit \(type)"
			case .onNotEnoughSearchData:
				return "onNotEnoughSearchData"
			case .didTapCloseJourneyList:
				return "didTapCloseJourneyList"
			case .onStopsSwitch:
				return "onStopsSwitch"
			case .onJourneyDataUpdated:
				return "onJourneyDataUpdated"
			case .didReceiveLocationData:
				return "didReceiveLocaitonData"
			case .didFailToLoadLocationData:
				return "didFailToLoadLocationData"
			case .didLocationButtonPressed:
				return "didLocationButtonPressed"
			case .didLoadInitialData:
				return "didLoadInitialData"
			case .didStartViewAppear:
				return "didStartViewAppear"
			}
		}
	}
}

extension ChewViewModel.State {
	init(){
		self.data = ChewViewModel.StateData(
			depStop: .textOnly(""),
			arrStop: .textOnly(""),
			journeySettings: JourneySettings(),
			date: SearchStopsDate(date: .now, mode: .departure)
		)
		self.status = .start
	}
	init(
		state : Self,
		data : ChewViewModel.StateData? = nil,
		status : ChewViewModel.Status
	){
		self.data = data ?? state.data
		self.status = status
	}
}

extension ChewViewModel.StateData {
	init(
		data : Self,
		depStop: ChewViewModel.TextFieldContent? = nil,
		arrStop: ChewViewModel.TextFieldContent? = nil,
		journeySettings: JourneySettings? = nil,
		appSettings: AppSettings? = nil,
		date: SearchStopsDate? = nil
	) {
		self.depStop = depStop ?? data.depStop
		self.arrStop = arrStop ?? data.arrStop
		self.journeySettings = journeySettings ?? data.journeySettings
		self.date = date ?? data.date
	}
}
