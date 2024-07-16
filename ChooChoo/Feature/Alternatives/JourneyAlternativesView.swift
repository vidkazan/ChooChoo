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
	@Namespace private var journeyAlternativesViewNamespace
	let secondTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
	let minuteTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
	@EnvironmentObject var chewVM : ChewViewModel
	@ObservedObject var jdvm : JourneyDetailsViewModel
	@State var journeyAlternativeViewData : JourneyAlternativeViewData?
	
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
						Text(journeyAlternativeViewData?.alternativeCase.description ?? "")
						Text(journeyAlternativeViewData?.alternativeStop.description ?? "")
						Text(journeyAlternativeViewData?.alternativeStopPosition.description ?? "")
					}
					.chewTextSize(.medium)
					HStack {
						if let line = journeyAlternativeViewData?.alternativeStop.line {
							BadgeView(.lineNumber(
								lineType: line.type,
								num: line.name)
							)
						}
						if let alternativeJourneyDepartureStop = journeyAlternativeViewData?.alternativeStop.stopViewData {
							Text("\(alternativeJourneyDepartureStop.name) ")
								.matchedGeometryEffect(id: "name", in: self.journeyAlternativesViewNamespace)
								.chewTextSize(.big)
								.transition(.move(edge: .top))
							Spacer()
							if let text = journeyAlternativeViewData?.alternativeStopPosition.timeBadge(referenceDate: chewVM.referenceDate) {
								text
								.frame(minWidth: 50)
								.padding(5)
								.badgeBackgroundStyle(.secondary)
								.chewTextSize(.medium)
							}
						}
					}
				})
			}
			Spacer()
		}
		.onReceive(chewVM.$referenceDate, perform: { res in
			withAnimation(.easeInOut, {
				journeyAlternativeViewData = getAlternativeJourneyDepartureStop(journey: jdvm.state.data.viewData, referenceDate: chewVM.referenceDate)
			})
		})
		.onReceive(secondTimer, perform: { _ in
			withAnimation(.easeInOut, {
				journeyAlternativeViewData = getAlternativeJourneyDepartureStop(journey: jdvm.state.data.viewData, referenceDate: chewVM.referenceDate)
			})
		})
		.onReceive(minuteTimer, perform: { _ in
			jdvm.send(event: .didRequestReloadIfNeeded(id: jdvm.state.data.id, ref: jdvm.state.data.viewData.refreshToken, timeStatus: .active))
		})
		.onAppear {
			withAnimation(.easeInOut, {
				journeyAlternativeViewData = getAlternativeJourneyDepartureStop(journey: jdvm.state.data.viewData,referenceDate: chewVM.referenceDate)
			})
		}
		.padding(10)
	}
}

extension JourneyAlternativesView {
	func getAlternativeJourneyDepartureStop(journey : JourneyViewData,referenceDate: ChewDate) -> JourneyAlternativeViewData? {
		let now = referenceDate.date
		
		if let departureTime = journey.time.date.departure.actualOrPlannedIfActualIsNil(),
		   departureTime > now,
		   let stop  = journey.legs.first?.legStopsViewData.first
		{
			return JourneyAlternativeViewData(
				alternativeCase: .nowBeforeDeparture,
				alternativeStop: .stop(stop: stop),
				alternativeStopPosition: .onStop
			)
		}
		
		
		let currentLegs = journey.legs.filter { leg in
			if let arrival = leg.time.date.arrival.actualOrPlannedIfActualIsNil(),
			   let departure = leg.time.date.departure.actualOrPlannedIfActualIsNil(),
			   leg.isReachable {
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
		
		let nearestStops = leg.legStopsViewData.filter { stop in
			if let arrival = stop.time.date.arrival.actualOrPlannedIfActualIsNil(),
			   let departure = stop.time.date.departure.actualOrPlannedIfActualIsNil() {
				Logger.viewData.debug("\(arrival) - \(now) - \(departure)")
				return now > arrival && departure > now
			}
			return false
		}
		if
			!nearestStops.isEmpty,
			nearestStops.count == 1,
			let stopViewData = nearestStops.first {
			return JourneyAlternativeViewData(
				alternativeCase: .currentLeg,
				alternativeStop: .stopWithLine(stop: stopViewData, line: leg.lineViewData),
				alternativeStopPosition: .onStop
			)
		}
		
		if
			let stopViewData = leg.legStopsViewData.first(where: {
				if let arrival = $0.time.date.arrival.actualOrPlannedIfActualIsNil() {
					return arrival > now
				}
				return false
			}),
			let time = stopViewData.time.date.arrival.actualOrPlannedIfActualIsNil() {
			return JourneyAlternativeViewData(
				alternativeCase: .currentLeg,
				alternativeStop: .stopWithLine(stop: stopViewData, line: leg.lineViewData),
				alternativeStopPosition: .headingToStop(time: time)
			)
		}
		return nil
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
