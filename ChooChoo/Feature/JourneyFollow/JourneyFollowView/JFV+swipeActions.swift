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
		jdvm : JourneyDetailsViewModel
	) -> some View {
		Button {
			Model.shared.sheetVM.send(event: .didRequestShow(.alternatives(for: jdvm)))
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
				arrivalTime: jdvm
					.state.data.viewData
					.time.date.arrival
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
