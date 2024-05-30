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
	static let shared = {
		let coredata = CoreDataStore(container: PersistenceController.shared.container)
		return Model(
			coreDataStore: coredata,
			recentSearchesViewModel: RecentSearchesViewModel(searches: [], coreDataStore: coredata),
			appSettingsVM: AppSettingsViewModel(coreDataStore: coredata)
		)
	}()
	static let preview = {
		let coredata = CoreDataStore(container: PersistenceController.preview.container)
		return Model(
			coreDataStore: coredata,
			recentSearchesViewModel: RecentSearchesViewModel(searches: [], coreDataStore: coredata),
			appSettingsVM: AppSettingsViewModel(coreDataStore: coredata)
		)
	}()
	
	private var _journeyDetailsViewModels = [String: JourneyDetailsViewModel]()
	
	
	let locationDataManager : ChewLocationDataManager

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
		sheetVM : SheetViewModel = .init(),
		alertVM : TopBarAlertViewModel = .init(),
		searchStopsVM : SearchStopsViewModel = .init(),
		journeyFollowViewModel : JourneyFollowViewModel = .init(journeys: []),
		coreDataStore : CoreDataStore,
		recentSearchesViewModel : RecentSearchesViewModel,
		locationDataManager : ChewLocationDataManager = .init(),
		appSettingsVM : AppSettingsViewModel,
		logVM : LogViewModel = .init()
	) {
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
