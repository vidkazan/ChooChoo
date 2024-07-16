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
			Form {
				alternativeFor
				recommendedDepartureStop
//				arrivalStop
//				Spacer()
				Button(action: {
					if let depStopViewData = journeyAlternativeViewData?.alternativeStop.stopViewData,
					   let depStop = depStopViewData.stop(),
					   let depStopArrival = depStopViewData.time.timestamp.arrival.actual
					{
						chewVM.send(event: .didUpdateSearchData(
							dep: .location(depStop),
							arr: .location(jdvm.state.data.arrStop),
							date: .init(date: .specificDate(depStopArrival), mode: .departure),
							journeySettings: jdvm.state.data.viewData.settings)
						)
					}
					Model.shared.sheetVM.send(event: .didRequestHide)
				}, label: {
					HStack {
						Spacer()
						if nil != journeyAlternativeViewData?.alternativeStop.stopViewData.stop() {
							Text(NSLocalizedString("Search", comment: "JourneyAlternativesView: button"))
						} else {
							Text(NSLocalizedString("error", comment: "JourneyAlternativesView: button"))
						}
						Spacer()
					}
					.chewTextSize(.big)
				})
//				.frame(height: 40)
				.padding(10)
//				.badgeBackgroundStyle(.secondary)
				.disabled(journeyAlternativeViewData?.alternativeStop.stopViewData.stop() == nil)
			}
			.background(.secondary)
		}
		.onReceive(chewVM.$referenceDate, perform: { res in
				journeyAlternativeViewData = getAlternativeJourneyDepartureStop(journey: jdvm.state.data.viewData, referenceDate: chewVM.referenceDate)
		})
		.onReceive(secondTimer, perform: { _ in
				journeyAlternativeViewData = getAlternativeJourneyDepartureStop(journey: jdvm.state.data.viewData, referenceDate: chewVM.referenceDate)
		})
		.onReceive(minuteTimer, perform: { _ in
			jdvm.send(event: .didRequestReloadIfNeeded(id: jdvm.state.data.id, ref: jdvm.state.data.viewData.refreshToken, timeStatus: .active))
		})
		.onAppear {
				journeyAlternativeViewData = getAlternativeJourneyDepartureStop(journey: jdvm.state.data.viewData,referenceDate: chewVM.referenceDate)
		}
	}
}


extension JourneyAlternativesView {
	var alternativeFor : some View {
		Section(content: {
			JourneyFollowCellView(journeyDetailsViewModel: jdvm)
				.foregroundStyle(.primary)
				.cornerRadius(10)
		}, header: {
			Text(
				"Alternative For",
				comment: "JourneyAlternativesView: recommendedDepartureStop"
			)
		})
	}
}


extension JourneyAlternativesView {
	var arrivalStop : some View {
		Section(content: {
			HStack {
				Text("\(jdvm.state.data.arrStop.name)")
						.chewTextSize(.big)
						.transition(.move(edge: .top))
			}
		}, header: {
			Text(
				"Arrival",
				comment: "JourneyAlternativesView: arrivalStop"
			)
		})
	}
}


extension JourneyAlternativesView {
	var recommendedDepartureStop : some View {
		Section(content: {
			VStack{
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
				HStack {
					Spacer()
					Group {
						Text(journeyAlternativeViewData?.alternativeCase.description ?? "")
						Text(journeyAlternativeViewData?.alternativeStop.description ?? "")
						Text(journeyAlternativeViewData?.alternativeStopPosition.description ?? "")
					}
					.padding(5)
					.badgeBackgroundStyle(.secondary)
				}
				.chewTextSize(.medium)
			}
		}, header: {
			Text(
				"Start from",
				comment: "JourneyAlternativesView: recommendedDepartureStop"
			)
		})
	}
}


#Preview {
	Group {
		if let journey = Mock.journeys.journeyNeussWolfsburgFirstCancelled.decodedData?.journey.journeyViewData(
			depStop: nil,
			arrStop: nil,
			realtimeDataUpdatedAt: Date.now.timeIntervalSince1970,
			settings: .init()
		) {
			let chewVM = ChewViewModel(referenceDate: .specificDate(journey.time.timestamp.departure.planned! + 	+10000),coreDataStore: .preview)
			let vm = JourneyDetailsViewModel(followId: 0, data: journey, depStop: journey.legs.first!.legStopsViewData.first!.stop()!, arrStop: journey.legs.last!.legStopsViewData.last!.stop()!, chewVM: chewVM)
			JourneyAlternativesView(jdvm: vm)
			.environmentObject(chewVM)
		}
	}
}
