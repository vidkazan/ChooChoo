//
//  JourneyFollowView.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 13.10.23.
//

import Foundation
import SwiftUI
import TipKit
import OSLog

struct JourneyFollowView : View {
	@EnvironmentObject var chewVM : ChewViewModel
	@ObservedObject var viewModel : JourneyFollowViewModel = Model.shared.journeyFollowVM
	@ObservedObject var alertVM : TopBarAlertViewModel = Model.shared.topBarAlertVM
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
					Group {
						ErrorView(
							viewType: .alert,
							msg: Text(
								"You have no followed journeys",
								comment: "JourneyFollowView: empty view: msg"
							),
							size: .big,
							action: nil
						)
						.frame(idealWidth: .infinity,idealHeight: .infinity)
						.onTapGesture {
							appSettingsVM.send(event: .didRequestToShowTip(tip: .followJourney))
						}
						if appSettingsVM.state.settings.showTip(tip: .followJourney){
							ChooTip.followJourney.tipLabel
								.padding(.horizontal)
								.onDisappear {
									appSettingsVM.send(event: .didShowTip(tip: .followJourney))
								}
						}
					}
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
			List {
				Section {
					if appSettingsVM.state.settings.showTip(tip: .swipeActions){
						ChooTip.swipeActions.tipLabel
							.onDisappear {
								appSettingsVM.send(event: .didShowTip(tip: .swipeActions))
							}
					}
				}
				Section(content: {
					ForEach(
						viewModel.state.journeys
							.filter({$0.journeyViewData.time.statusOnReferenceTime(chewVM.referenceDate) == .active})
							.sorted(by: {
								if let first = $0.journeyViewData.time.date.departure.actualOrPlannedIfActualIsNil(),
								   let second = $1.journeyViewData.time.date.departure.actualOrPlannedIfActualIsNil() {
									return first < second
								} else {
									return true
								}
							}),
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
							})
							.sorted(by: {
								if let first = $0.journeyViewData.time.date.departure.actualOrPlannedIfActualIsNil(),
								   let second = $1.journeyViewData.time.date.departure.actualOrPlannedIfActualIsNil() {
									return first < second
								} else {
									return true
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
							.filter({$0.journeyViewData.time.statusOnReferenceTime(chewVM.referenceDate) == .past})
							.sorted(by: {
								if let first = $0.journeyViewData.time.date.departure.actualOrPlannedIfActualIsNil(),
								   let second = $1.journeyViewData.time.date.departure.actualOrPlannedIfActualIsNil() {
									return first < second
								} else {
									return true
								}
							}),
						id: \.id) { journey in
							listCell(journey: journey, map: false)
						}
				}, header: {
					Text("Past", comment: "JourneyFollowView: section name")
				})
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
					JourneyViewData.showOnMapOption.action(journey.journeyViewData)
				} label: {
					Label(
						title: {
							Text("Map", comment: "JourneyFollowView: listCell: swipe action item")
						},
						icon: {
							Image(systemName: JourneyViewData.showOnMapOption.icon)
								.chewTextSize(.medium)
								.padding(5)
								.badgeBackgroundStyle(.primary)
								.foregroundColor(.primary)
						}
					)
				}
				.tint(.chewFillBluePrimary)
			}
			.swipeActions(edge: .trailing) {
				Button {
					let now = Date.now
					Task {
						let currentLegs = journey.journeyViewData.legs.filter { leg in
							if let arrival = leg.time.date.arrival.actualOrPlannedIfActualIsNil(),
							   let departure = leg.time.date.departure.actualOrPlannedIfActualIsNil() {
								return now > departure && arrival > now
							}
							return false
						}
						guard 
							!currentLegs.isEmpty,
								currentLegs.count == 1,
								let leg = currentLegs.first else {
							return
						}
						if 
							let stopViewData = leg.legStopsViewData.first(where: {
								if let arrival = $0.time.date.arrival.actualOrPlannedIfActualIsNil() {
									return arrival > now
								}
								return false
							}),
							let stop = stopViewData.stop() {
								chewVM.send(
									event: .didUpdateSearchData(
										dep: .location(stop),
										arr: .location(journey.stops.arrival),
										date: SearchStopsDate(date: .now, mode: .departure)
									)
							)
							return
						}
						
						let nearestStops = leg.legStopsViewData.filter { stop in
							if let arrival = stop.time.date.arrival.actualOrPlannedIfActualIsNil(),
							   let departure = stop.time.date.departure.actualOrPlannedIfActualIsNil() {
								Logger.viewData.debug("\(arrival) - \(now) - \(departure)")
								return now > arrival && departure > now
							}
							return false
						}
						guard 
							!nearestStops.isEmpty,
								nearestStops.count == 1,
								let stopViewData = nearestStops.first,
								let stop = stopViewData.stop() else {
							return
						}
						chewVM.send(
							event: .didUpdateSearchData(
								dep: .location(stop),
								arr: .location(journey.stops.arrival),
								date: SearchStopsDate(date: .now, mode: .departure)
							)
						)
					}
				} label: {
					Label(
						title: {
							Text("Alternatives", comment: "JourneyFollowView: listCell: swipe action item")
						},
						icon: {
							Image(ChooSFSymbols.arrowTriangleBranch)
						}
					)
				}
				.disabled(
					evaluatePastTrip(
						arrivalTime: journey
							.journeyViewData
							.time
							.date
							.arrival
							.actualOrPlannedIfActualIsNil() ?? .now
					)
				)
				.tint(.chewFillMagenta.opacity(0.7))
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
					Model.shared.alertVM.send(event: .didRequestShow(
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
						id: UUID(),
						presentedOn: .base
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

private extension JourneyFollowView {
	func evaluatePastTrip(arrivalTime : Date) -> Bool {
		arrivalTime < Date.now
	}
}

struct FollowPreviews: PreviewProvider {
	static var previews: some View {
		if let mock = Mock.journeyList.journeyNeussWolfsburg.decodedData {
			let data = constructJourneyListViewData(
				journeysData: mock,
				depStop:  .init(coordinates: .init(), type: .stop, stopDTO: nil),
				arrStop:  .init(coordinates: .init(), type: .stop, stopDTO: nil),
				settings: .init()
			)
			let chewVM = ChewViewModel(referenceDate: .specificDate(data.last?.time.timestamp.departure.actualOrPlannedIfActualIsNil() ?? 0),coreDataStore: .preview)
			let jfvm : JourneyFollowViewModel = .init(
				journeys: [],
				initialStatus: .idle,
				coreDataStore: .preview
			)
			JourneyFollowView(viewModel: jfvm)
			.onAppear {
				chewVM.send(event: .didStartViewAppear)
				jfvm.send(event: .didTapEdit(
					action: .adding,
					followId: .max,
					followData: JourneyFollowData(
						id: .random(in: 0...1000),
						journeyViewData: data.first!,
						stops: .init(
							departure: .init(coordinates: .init(), type: .stop, stopDTO: nil),
							arrival: .init(coordinates: .init(), type: .stop, stopDTO: nil))
					),
					sendToJourneyDetailsViewModel: { _ in }))
			}
			.environmentObject(chewVM)
		}
	}
}
