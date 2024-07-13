//
//  JFV+swipeActions.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 13.07.24.
//

import Foundation
import SwiftUI
import OSLog

extension JourneyFollowView {
	func alternativesActionButton(
		journey : JourneyFollowData
	) -> some View {
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
}

extension JourneyFollowView {
	func searchNowActionButton(
		journey : JourneyFollowData
	) -> some View {
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
}

extension JourneyFollowView {
	func unfollowSwipeActionButton(
		vm : JourneyDetailsViewModel,
		journey : JourneyFollowData
	) -> some View {
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

extension JourneyFollowView {
	func reloadActionButton(
		journey : JourneyFollowData,
		vm : JourneyDetailsViewModel
	) -> some View {
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
}

extension JourneyFollowView {
	func mapActionButton(
		journey : JourneyFollowData
	) -> some View {
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
}



private extension JourneyFollowView {
	func evaluatePastTrip(arrivalTime : Date) -> Bool {
		arrivalTime < Date.now
	}
}
