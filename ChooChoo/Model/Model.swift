//
//  Model.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 29.01.24.
//

import Foundation
import SwiftUI
import OSLog

final class Model {
	static let shared = Model()
	
	private var _journeyDetailsViewModels : [String: JourneyDetailsViewModel] = [:]
	let logStore: OSLogStore? = try? OSLogStore(scope: .currentProcessIdentifier)
	let locationDataManager : ChewLocationDataManager
	let sheetViewModel : SheetViewModel
	let logViewModel : LogViewModel
	let topBarAlertViewModel : TopBarAlertViewModel
	let coreDataStore : CoreDataStore
	let searchStopsViewModel : SearchStopsViewModel
	let journeyFollowViewModel : JourneyFollowViewModel
	let recentSearchesViewModel : RecentSearchesViewModel
	let alertViewModel : AlertViewModel
	let appSettingsVM : AppSettingsViewModel
	
	init(
		sheetVM : SheetViewModel,
		alertVM : TopBarAlertViewModel,
		searchStopsVM : SearchStopsViewModel,
		journeyFollowViewModel : JourneyFollowViewModel,
		recentSearchesViewModel : RecentSearchesViewModel
	) {
		self.searchStopsViewModel = searchStopsVM
		self.topBarAlertViewModel = alertVM
		self.sheetViewModel = sheetVM
		self.journeyFollowViewModel = journeyFollowViewModel
		self.recentSearchesViewModel = recentSearchesViewModel
		self.alertViewModel = .init()
		self.coreDataStore = .init()
		self.locationDataManager = .init()
		self.appSettingsVM = .init()
		self.logViewModel = .init()
	}
	
	init() {
		self.searchStopsViewModel = .init()
		self.topBarAlertViewModel = .init()
		self.sheetViewModel = .init()
		self.journeyFollowViewModel = .init(journeys: [])
		self.recentSearchesViewModel = .init(searches: [])
		self.alertViewModel = .init()
		self.coreDataStore = .init()
		self.locationDataManager = .init()
		self.appSettingsVM = .init()
		self.logViewModel = .init()
	}
}

extension Model {
	func allJourneyDetailViewModels() -> [JourneyDetailsViewModel]{
		return _journeyDetailsViewModels.map({$0.1})
	}
	
	func journeyDetailViewModel(
		followId: Int64,
		for journeyRef: String,
		viewdata : JourneyViewData,
		stops : DepartureArrivalPairStop,
		chewVM : ChewViewModel?
	) -> JourneyDetailsViewModel {
		if let vm = _journeyDetailsViewModels[journeyRef] {
			return vm
		}
		Logger.journeyDetailsViewModel.info("\(#function): vm not found: creating new")
		let vm = JourneyDetailsViewModel(
			followId: followId,
			data: viewdata,
			depStop: stops.departure,
			arrStop: stops.arrival,
			chewVM: chewVM
		)
		_journeyDetailsViewModels[journeyRef] = vm
		return vm
	}
}
