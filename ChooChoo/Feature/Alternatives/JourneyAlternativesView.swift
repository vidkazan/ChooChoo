//
//  AlternativesView.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 13.07.24.
//

import Foundation
import SwiftUI
import OSLog

struct JourneyAlternativesView: View {
	let secondTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
	let minuteTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
	@EnvironmentObject var chewVM : ChewViewModel
	@ObservedObject var jdvm : JourneyDetailsViewModel
	@State var alternativeJourneyDepartureStop : StopViewData?
	@State var currentLeg : LegViewData?
	
	init(jdvm: JourneyDetailsViewModel) {
		self.jdvm = jdvm
	}
	
	var body : some View {
		VStack {
			JourneyFollowCellView(journeyDetailsViewModel: jdvm)
				.padding(10)
				.foregroundStyle(.primary)
				.badgeBackgroundStyle(.secondary)
				.cornerRadius(10)
			GroupBox {
				Section(content: {
					HStack {
						if let currentLeg = currentLeg {
							BadgeView(.lineNumber(
								lineType: currentLeg.lineViewData.type,
								num: currentLeg.lineViewData.name)
							)
						} else {
							
						}
						if let alternativeJourneyDepartureStop = alternativeJourneyDepartureStop {
							if let time = alternativeJourneyDepartureStop.time.date.arrival.actualOrPlannedIfActualIsNil() {
								HStack(spacing: 0) {
									Text(NSLocalizedString("in ", comment: "JourneyAlternativesView: next stop view: time to stop")
									)
									Text(time, style: .relative)
										.frame(minWidth: 50)
								}
								.chewTextSize(.medium)
								.padding(5)
								.badgeBackgroundStyle(.secondary)
							}
							Text("\(alternativeJourneyDepartureStop.name)")
								.chewTextSize(.big)
						} else {
							
						}
						Spacer()
					}
				})
			}
			Spacer()
		}
		.onReceive(secondTimer, perform: { _ in
			let res = getAlternativeJourneyDepartureStop(journey: jdvm.state.data.viewData)
			alternativeJourneyDepartureStop = res?.1
			currentLeg = res?.0
		})
		.onReceive(minuteTimer, perform: { _ in
			jdvm.send(event: .didRequestReloadIfNeeded(id: jdvm.state.data.id, ref: jdvm.state.data.viewData.refreshToken, timeStatus: .active))
		})
		.onAppear {
			let res = getAlternativeJourneyDepartureStop(journey: jdvm.state.data.viewData)
			alternativeJourneyDepartureStop = res?.1
			currentLeg = res?.0
		}
		.padding(10)
	}
}

extension JourneyAlternativesView {
	func getAlternativeJourneyDepartureStop(journey : JourneyViewData) -> (LegViewData,StopViewData)? {
		let now = Date.now
		let currentLegs = journey.legs.filter { leg in
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
			return nil
		}
		if
			let stopViewData = leg.legStopsViewData.first(where: {
				if let arrival = $0.time.date.arrival.actualOrPlannedIfActualIsNil() {
					return arrival > now
				}
				return false
			}) {
			return (leg,stopViewData)
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
			let stopViewData = nearestStops.first
			else {
			return nil
		}
		return (leg,stopViewData)
	}
}

extension JourneyAlternativesView {
	static func update(_ refTime : Double) -> Text? {
		let minutes = DateParcer.getTwoDateIntervalInMinutes(
			date1: .now,
			date2: Date(timeIntervalSince1970: .init(floatLiteral: refTime))
		)
		
		switch minutes {
		case .none:
			return nil
		case .some(let wrapped):
			switch wrapped {
			case 0..<1:
				return Text("updated now", comment: "badge: updated at")
			default:
				if let dur = DateParcer.timeDuration(wrapped) {
					return Text("updated \(dur) ago", comment: "badge")
				}
				return nil
			}
		}
	}
}

#Preview {
	Group {
		let chewVM = ChewViewModel(coreDataStore: .preview)
		if let journey = Mock.journeys.journeyNeussWolfsburg.decodedData?.journey.journeyViewData(
			depStop: nil,
			arrStop: nil,
			realtimeDataUpdatedAt: Date.now.timeIntervalSince1970,
			settings: .init()
		) {
			let vm = JourneyDetailsViewModel(followId: 0, data: journey, depStop: journey.legs.first!.legStopsViewData.first!.stop()!, arrStop: journey.legs.last!.legStopsViewData.last!.stop()!, chewVM: chewVM)
			JourneyAlternativesView(jdvm: vm)
			.environmentObject(chewVM)
		}
	}
}
