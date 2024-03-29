//
//  JourneyFollowView.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 13.10.23.
//

import Foundation
import SwiftUI
import TipKit

struct JourneyFollowView : View {
	@EnvironmentObject var chewVM : ChewViewModel
	@ObservedObject var viewModel : JourneyFollowViewModel = Model.shared.journeyFollowViewModel
	@ObservedObject var alertVM : TopBarAlertViewModel = Model.shared.topBarAlertViewModel
	@ObservedObject var appSettingsVM = Model.shared.appSettingsVM
	let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
	
	var body: some View {
		VStack {
			switch viewModel.state.status {
			case .updating:
				switch viewModel.state.journeys.count {
				case 0:
					ProgressView()
				default:
					followViewInner
				}
			default:
				switch viewModel.state.journeys.count {
				case 0:
					ErrorView(
						viewType: .info,
						msg: Text(
							"You have no followed journeys",
							comment: "JourneyFollowView: empty view: msg"
						),
						size: .big,
						action: nil
					)
					.frame(idealWidth: .infinity,idealHeight: .infinity)
				default:
					followViewInner
				}
			}
		}
		.onReceive(timer, perform: { _ in
			Task {
				chooseJourneyToUpdate()
			}
		})
		.frame(maxWidth: .infinity,maxHeight: .infinity)
		.navigationBarTitleDisplayMode(.inline)
		.navigationTitle(
			Text("Journey follow", comment: "navigationBarTitle")
		)
		.toolbar {
			ToolbarItem(placement: .topBarLeading, content: {
				if alertVM.state.alerts.contains(.offline) {
					BadgeView(.offlineMode)
						.frame(maxHeight: 40)
						.badgeBackgroundStyle(.blue)
						.animation(.easeInOut, value: alertVM.state.alerts)
				}
			})
			ToolbarItem(placement: .topBarTrailing, content: {
				Button(action: {
					Model.shared.sheetViewModel.send(event: .didRequestShow(.appSettings))
				}, label: {
					ChooSFSymbols.gearshape.view
						.tint(.primary)
						.chewTextSize(.big)
						.frame(maxWidth: 40,maxHeight: 40)
				})
			})
		}
	}
}

extension JourneyFollowView {
	func performCalculation(elem : JourneyFollowData) -> Double {
		let now = Date.now.timeIntervalSince1970
		let basicInterval = elem.journeyViewData.time.statusOnReferenceTime(.now).updateIntervalInMinutes
		let updatedAt = elem.journeyViewData.updatedAt
		return  (basicInterval - (now - updatedAt)/60) / basicInterval
	}
	func chooseJourneyToUpdate()  {
		let elems = viewModel.state.journeys.filter({$0.journeyViewData.time.statusOnReferenceTime(.now) != .past})
		if let elem = elems.min(by: {
			performCalculation(elem: $0) < performCalculation(elem: $1)
		}) {
			if performCalculation(elem: elem) < 0.2 {
				Model.shared.allJourneyDetailViewModels().first(where: {
					$0.state.data.id == elem.id
				})?.send(event: .didRequestReloadIfNeeded(
					id: elem.id,
					ref: elem.journeyViewData.refreshToken,
					timeStatus: elem.journeyViewData.time.statusOnReferenceTime(.now)
				))
			}
		}
	}
}

extension JourneyFollowView {
	var followViewInner : some View {
		VStack {
			Section {
				if appSettingsVM.state.settings.showTip(tip: .swipeActions){
					AppSettings.ChooTip.swipeActions.tipLabel
				}
			}
			.onDisappear {
				appSettingsVM.send(event: .didShowTip(tip: .swipeActions))
			}
			.onTapGesture {
				appSettingsVM.send(event: .didShowTip(tip: .swipeActions))
			}
//			.swipeActions(edge: .trailing, content: {
//				Button("", role: .destructive, action: {
//					appSettingsVM.send(event: .didShowTip(tip: .swipeActions))
//				})
//			})
			.padding()
			List {
				Section(content: {
					ForEach(
						viewModel.state.journeys
							.filter({$0.journeyViewData.time.statusOnReferenceTime(chewVM.referenceDate) == .active}),
						id: \.id) { journey in
							listCell(journey: journey, map: true)
						}
				}, header: {
					Text("Active", comment: "JourneyFollowView: section name")
				})
				.chewTextSize(.big)
				Section(content: {
					ForEach(
						viewModel.state.journeys
							.filter({
								switch $0.journeyViewData.time.statusOnReferenceTime(chewVM.referenceDate){
								case .ongoing,.ongoingFar,.ongoingSoon:
									return true
								default:
									return false
								}
							}),
						id: \.id) { journey in
							listCell(journey: journey, map: false)
						}
				}, header: {
					Text("Ongoing", comment: "JourneyFollowView: section name")
				})
				.chewTextSize(.big)
				Section(content: {
					ForEach(
						viewModel.state.journeys
							.filter({$0.journeyViewData.time.statusOnReferenceTime(chewVM.referenceDate) == .past}),
						id: \.id) { journey in
							listCell(journey: journey, map: false)
						}
				}, header: {
					Text("Past", comment: "JourneyFollowView: section name")
				})
			}
		}
		.onAppear{
			UITableView.appearance().separatorStyle = .singleLine
			UITableView.appearance().backgroundColor = UIColor(Color.chewFillPrimary)
		}
		.chewTextSize(.big)
		.listStyle(.insetGrouped)
		
	}
}

extension JourneyFollowView {
	func list(data : [JourneyFollowData], map : Bool) -> some View {
		let sorted = data.sorted(by: {
			$0.journeyViewData.time.timestamp.departure.planned ?? 0 < $1.journeyViewData.time.timestamp.departure.planned ?? 0
		   })
		return ForEach(sorted, id: \.id) { journey in
			listCell(journey: journey,map: journey.id == sorted.first?.id)
		}
	}
}

extension JourneyFollowView {
	@ViewBuilder func listCell(journey : JourneyFollowData, map : Bool) -> some View {
		let vm = Model.shared.journeyDetailViewModel(
			followId: journey.id,
			for: journey.journeyViewData.refreshToken,
			viewdata: journey.journeyViewData,
			stops: journey.stops,
			chewVM: chewVM
		)
		Group {
//			if map == true {
//				JourneyFollowViewMapCell(journeyDetailsViewModel: vm)
//			} else {
				JourneyFollowCellView(journeyDetailsViewModel: vm)
//			}
		}
			.swipeActions(edge: .leading) {
				Button {
					vm.send(event: .didTapReloadButton(
						id: journey.id,
						ref: journey.journeyViewData.refreshToken)
					)
				} label: {
					Label(
						title: {
							Text("Reload", comment: "JourneyFollowView: listCell: swipe action item")
						},
						icon: {
							ChooSFSymbols.arrowClockwise.view
						}
					)
				}
				.tint(.chewFillGreenPrimary)
			}
			.swipeActions(edge: .leading) {
				Button {
					chewVM.send(
						event: .didUpdateSearchData(
							dep: .location(journey.stops.departure),
							arr: .location(journey.stops.arrival),
							date: SearchStopsDate(date: .now, mode: .departure)
						)
					)
				} label: {
					Label(
						title: {
							Text("Search now", comment: "JourneyFollowView: listCell: swipe action item")
						},
						icon: {
							Image(systemName: "magnifyingglass")
						}
					)
				}
				.tint(.chewFillYellowPrimary)
			}
			.swipeActions(edge: .trailing) {
				Button {
					Model.shared.alertViewModel.send(event: .didRequestShow(
						.destructive(
							destructiveAction: {
								vm.send(event: .didTapSubscribingButton(
									id: journey.id,
									ref: journey.journeyViewData.refreshToken,
									journeyDetailsViewModel: vm
								))
						},
						description: NSLocalizedString("Unfollow journey?", comment: "alert: description"),
						actionDescription: NSLocalizedString("Unfollow", comment: "alert: actionDescription"),
						id: UUID()
					)))
				} label: {
					Label(
						title: {
							Text("Unfollow", comment: "JourneyFollowView: listCell: swipe action item")
						},
						icon: {
							Image(systemName: "xmark.bin.circle")
						}
					)
				}
				.tint(.chewFillRedPrimary)
			}
	}
}
//
//struct FollowPreviews: PreviewProvider {
//	static var previews: some View {
//		if let mock = Mock.journeyList.journeyNeussWolfsburg.decodedData {
//			let data = constructJourneyListViewData(
//				journeysData: mock,
//				depStop:  .init(),
//				arrStop:  .init(),
//				settings: .init()
//			)
//			JourneyFollowView(viewModel: .init(
//				journeys: data.map {
//					JourneyFollowData(id: 0, journeyViewData: $0,stops: .init(departure: .init(), arrival: .init()))
//				},
//				initialStatus: .idle
//			))
//			.environmentObject(ChewViewModel(referenceDate: .specificDate(data.last?.time.timestamp.departure.actualOrPlannedIfActualIsNil() ?? 0)))
//		}
//	}
//}
