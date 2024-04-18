//
//  SearchLocationVM+state.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 06.09.23.
//

import Foundation

extension SearchStopsViewModel {
	struct State : Equatable {
		var previousStops : [Stop]
		var stops : [Stop]
		var status : Status
		var type : LocationDirectionType?
	}
	
	enum Status : ChewStatus {
		case idle
		case loading(String)
		case loaded
		case updatingRecentStops(Stop?)
		case error(ApiError)
		
		var description : String {
			switch self {
			case .idle:
				return "idle"
			case .loading:
				return "loading"
			case .loaded:
				return "loaded"
			case .error:
				return "error"
			case .updatingRecentStops:
				return "updatingRecentStops"
			}
		}
	}
	
	enum Event : ChewEvent {
		case onSearchFieldDidChanged(String,LocationDirectionType)
		case onDataLoaded([Stop],LocationDirectionType)
		case onDataLoadError(ApiError)
		case onReset(LocationDirectionType)
		case onStopDidTap(ChewViewModel.TextFieldContent, LocationDirectionType)
		case didRecentStopsUpdated(recentStops : [Stop])
		case didRequestDeleteRecentStop(stop : Stop)
		case didChangeFieldFocus(type : LocationDirectionType?)
		
		
		var description : String {
			switch self {
			case .didRequestDeleteRecentStop:
				return "didRequestDeleteRecentStop"
			case .onSearchFieldDidChanged:
				return "onSearchFieldDidChanged"
			case .onDataLoaded:
				return "onDataLoaded"
			case .onDataLoadError:
				return "onDataLoadError"
			case .onReset:
				return "onReset"
			case .onStopDidTap:
				return "onStopDidTap"
			case .didRecentStopsUpdated:
				return "didRecentStopsUpdated"
			case .didChangeFieldFocus:
				return "didChangeFieldFocus"
			}
		}
	}
}
