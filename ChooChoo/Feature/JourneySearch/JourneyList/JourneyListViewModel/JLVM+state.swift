//
//  SearchJourneyVM+state.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 06.09.23.
//

import Foundation

extension JourneyListViewModel {

	struct StateData {
		var date : SearchStopsDate
		var stops : DepartureArrivalPairStop
		var settings : JourneySettings
		var journeys :  [JourneyViewData]
		var earlierRef : String?
		var laterRef : String?
		
		init(stops: DepartureArrivalPairStop,date : SearchStopsDate, settings: JourneySettings, journeys: [JourneyViewData], earlierRef: String?, laterRef: String?) {
			self.stops = stops
			self.date = date
			self.settings = settings
			self.journeys = journeys
			self.earlierRef = earlierRef
			self.laterRef = laterRef
		}
	}
	
	struct State {
		var data : StateData
		var status : Status
		
		init(data : StateData,status: Status){
			self.data = data
			self.status = status
		}
		init(journeys: [JourneyViewData],date : SearchStopsDate, earlierRef: String?, laterRef: String?, settings : JourneySettings,stops : DepartureArrivalPairStop, status: Status) {
			self.data = StateData(
				stops: stops,
				date: date,
				settings: settings,
				journeys: journeys,
				earlierRef: earlierRef,
				laterRef: laterRef
			)
			self.status = status
		}
	}
	
	enum JourneyUpdateType {
		case initial
		case earlierRef
		case laterRef
	}
	
	enum Status : ChewStatus {
		case loadingRef(JourneyUpdateType)
		case loadingJourneyList
		case journeysLoaded
		case failedToLoadLaterRef(any ChooError)
		case failedToLoadEarlierRef(any ChooError)
		case failedToLoadJourneyList(any ChooError)
		
		var description : String {
			switch self {
			case .loadingJourneyList:
				return "loadingJourneyList"
			case .failedToLoadJourneyList:
				return "failedToLoadJourneyList"
			case .journeysLoaded:
				return "journeysLoaded"
			case .loadingRef:
				return "loadingRef"
			case .failedToLoadLaterRef:
				return "didFailedToLoadLaterRef"
			case .failedToLoadEarlierRef:
				return "didFailedToLoadEarlierRef"
			}
		}
	}
	
	enum Event : ChewEvent {
		case onNewJourneyListData(JourneyListViewData,JourneyUpdateType)
		case onFailedToLoadJourneyListData(any ChooError)
		case onReloadJourneyList
		case onLaterRef
		case onEarlierRef
		case didFailToLoadLaterRef(any ChooError)
		case didFailToLoadEarlierRef(any ChooError)
		var description : String {
			switch self {
			case .onNewJourneyListData:
				return "onNewJourneyListData"
			case .onFailedToLoadJourneyListData:
				return "onFailedToLoadJourneyListData"
			case .onReloadJourneyList:
				return "onReloadJourneyList"
			case .onLaterRef:
				return "onLaterRef"
			case .onEarlierRef:
				return "onEarlierRef"
			case .didFailToLoadLaterRef:
				return "didFailToLoadLaterRef"
			case .didFailToLoadEarlierRef:
				return "didFailToLoadEarlierRef"
			}
		}
	}
}
