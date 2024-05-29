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
	static let preview = Model(
		coreDataStore: CoreDataStore(container: PersistenceController.preview.container)
	)
	
	private var _journeyDetailsViewModels = [String: JourneyDetailsViewModel]()
	
	
	let locationDataManager : ChewLocationDataManager
	let chewVM : ChewViewModel
	let sheetVM : SheetViewModel
	let logVM : LogViewModel
	let topBarAlertVM : TopBarAlertViewModel
	let coreDataStore : CoreDataStore
	let searchStopsVM : SearchStopsViewModel
	let journeyFollowVM : JourneyFollowViewModel
	let recentSearchesVM : RecentSearchesViewModel
	let alertVM : AlertViewModel
	let appSettingsVM : AppSettingsViewModel
	
	init(
		chewVM : ChewViewModel = .init(),
		sheetVM : SheetViewModel = .init(),
		alertVM : TopBarAlertViewModel = .init(),
		searchStopsVM : SearchStopsViewModel = .init(),
		journeyFollowViewModel : JourneyFollowViewModel = .init(journeys: []),
		recentSearchesViewModel : RecentSearchesViewModel = .init(searches: []),
		coreDataStore : CoreDataStore = .init(),
		locationDataManager : ChewLocationDataManager = .init(),
		appSettingsVM : AppSettingsViewModel = .init(),
		logVM : LogViewModel = .init()
	) {
		self.chewVM = chewVM
		self.searchStopsVM = searchStopsVM
		self.topBarAlertVM = alertVM
		self.sheetVM = sheetVM
		self.journeyFollowVM = journeyFollowViewModel
		self.recentSearchesVM = recentSearchesViewModel
		self.alertVM = .init()
		self.coreDataStore = coreDataStore
		self.locationDataManager = locationDataManager
		self.appSettingsVM = appSettingsVM
		self.logVM = logVM
	}
	
	init() {
		self.searchStopsVM = .init()
		self.topBarAlertVM = .init()
		self.sheetVM = .init()
		self.journeyFollowVM = .init(journeys: [])
		self.recentSearchesVM = .init(searches: [])
		self.alertVM = .init()
		self.coreDataStore = .init()
		self.locationDataManager = .init()
		self.appSettingsVM = .init()
		self.logVM = .init()
		self.chewVM = .init()
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
