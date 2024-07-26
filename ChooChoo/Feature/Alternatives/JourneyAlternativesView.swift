//
//  AlternativesView.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 13.07.24.
//

import Foundation
import SwiftUI
import OSLog


//#warning("remove this")
//let timer50ms = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
//		.onReceive(timer50ms, perform: { _ in
//			#warning("remove this")
//			chewVM.referenceDate = .specificDate(chewVM.referenceDate.ts + 10)
//		})
//		.onAppear {
//			#warning("remove next")
//			chewVM.referenceDate = .specificDate(jdvm.state.data.viewData.time.timestamp.departure.actual ?? 0)
//		}

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
				if let journeyAlternativeViewData = journeyAlternativeViewData {
					departureStop(alternativeViewData: journeyAlternativeViewData)
				}
				searchButton
//				if let data = journeyAlternativeViewData,
//				let time = Self.getTime(journeyAlternativeViewData: data),
//				   let stop = data.alternativeDeparture.stopViewData.stop(){
//					JourneyListView(
//						stops: .init(departure: stop, arrival: jdvm.state.data.arrStop),
//						date: time,
//						settings: jdvm.state.data.viewData.settings
//					)
//				}
			}
			.background(.secondary)
		}
		.onReceive(chewVM.$referenceDate, perform: { res in
			Task {
				journeyAlternativeViewData = Self.getAlternativeJourneyDepartureStop(journey: jdvm.state.data.viewData, referenceDate: chewVM.referenceDate)
			}
		})
		.onReceive(secondTimer, perform: { _ in
			Task {
				journeyAlternativeViewData = Self.getAlternativeJourneyDepartureStop(journey: jdvm.state.data.viewData, referenceDate: chewVM.referenceDate)
			}
		})
		
		.onReceive(minuteTimer, perform: { _ in
			jdvm.send(event: .didRequestReloadIfNeeded(id: jdvm.state.data.id, ref: jdvm.state.data.viewData.refreshToken, timeStatus: .active))
		})
		.onAppear {
			Task {
				journeyAlternativeViewData = Self.getAlternativeJourneyDepartureStop(journey: jdvm.state.data.viewData,referenceDate: chewVM.referenceDate)
			}
		}
	}
}

extension JourneyAlternativesView {
	var searchButton : some View {
		Button(action: {
			if let depStopViewData = journeyAlternativeViewData?.alternativeDeparture.stopViewData,
			   let depStop = depStopViewData.stop()
			{
				if let leg = journeyAlternativeViewData?.alternativeDeparture.leg,
				   let depStopArrival = depStopViewData.time.timestamp.arrival.actual  {
					chewVM.send(event: .didUpdateSearchData(
						dep: .transport(leg),
						arr: .location(jdvm.state.data.arrStop),
						date: .init(date: .specificDate(depStopArrival), mode: .departure),
						journeySettings: jdvm.state.data.viewData.settings)
					)
				} else {
					chewVM.send(event: .didUpdateSearchData(
						dep: .location(depStop),
						arr: .location(jdvm.state.data.arrStop),
						date: .init(date: .now, mode: .departure),
						journeySettings: jdvm.state.data.viewData.settings)
					)
				}
			}
			Model.shared.sheetVM.send(event: .didRequestHide)
		}, label: {
			HStack {
				Spacer()
				if nil != journeyAlternativeViewData?.alternativeDeparture.stopViewData.stop() {
					Text(NSLocalizedString("Search", comment: "JourneyAlternativesView: button"))
				} else {
					Text(NSLocalizedString("error", comment: "JourneyAlternativesView: button"))
				}
				Spacer()
			}
			.chewTextSize(.big)
		})
		.padding(10)
		.disabled(journeyAlternativeViewData?.alternativeDeparture.stopViewData.stop() == nil)
	}
}

extension JourneyAlternativesView {
	private static func getTime(journeyAlternativeViewData : JourneyAlternativeViewData?) -> SearchStopsDate? {
		if let depStopViewData = journeyAlternativeViewData?.alternativeDeparture.stopViewData,
		   let depStop = depStopViewData.stop()
		{
			if let leg = journeyAlternativeViewData?.alternativeDeparture.leg,
			   let depStopArrival = depStopViewData.time.timestamp.arrival.actual  {
					return .init(date: .specificDate(depStopArrival), mode: .departure)
			} else {
					return .init(date: .now, mode: .departure)
			}
		}
		return nil
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
	func departureStop(alternativeViewData : JourneyAlternativeViewData) -> some View {
		Section(content: {
			VStack(spacing: 2) {
				HStack {
					if let leg = alternativeViewData.alternativeDeparture.leg {
						BadgeView(.lineNumberWithDirection(leg: leg))
							.badgeBackgroundStyle(.secondary)
					}
					Spacer()
				}
				HStack {
					if case .headingToStop = alternativeViewData.alternativeStopPosition {
						Group {
							Image(systemName: "arrow.turn.down.right")
							Text(localisedString("heading to",comment:""))
						}
						.foregroundStyle(.secondary)
					}
					Text(verbatim: "\(alternativeViewData.alternativeDeparture.stopViewData.name)")
					if let text = alternativeViewData.alternativeStopPosition.timeBadge(referenceDate: chewVM.referenceDate) {
						text
						.padding(5)
						.badgeBackgroundStyle(.secondary)
					}
					Spacer()
				}
				.chewTextSize(.medium)
//				#if DEBUG
//				HStack {
//					Spacer()
//					Group {
//						Text(alternativeViewData.alternativeCase.description)
//						Text(alternativeViewData.alternativeDeparture.description)
//						Text(alternativeViewData.alternativeStopPosition.description)
//					}
//					.padding(5)
//					.badgeBackgroundStyle(.secondary)
//				}
//				.chewTextSize(.medium)
//				#endif
			}
		}, header: {
			Text(
				"Start from",
				comment: "JourneyAlternativesView: recommendedDepartureStop"
			)
		})
	}
}

@available(iOS 16.0,*)
#Preview {
	Group {
		 let journeys =  [
			Mock.journeys.alternativasMoks
				.alternativesPrelastLegArrivalIsLaterThanLastLegArrival
				.decodedData?.journey.journeyViewData(
			depStop: .init(),
			arrStop: .init(),
			realtimeDataUpdatedAt: 0,
			settings: .init()),
//			Mock.journeys.alternativasMoks
//				.alternativesJourneyNeussWolfsburg
//				.decodedData?.journey.journeyViewData(
//			depStop: .init(),
//			arrStop: .init(),
//			realtimeDataUpdatedAt: 0,
//			settings: .init()),
//			Mock.journeys.alternativasMoks
//				.alternativesJourneyNeussWolfsburgRE6LateAndNextIsNotAvailable
//				.decodedData?.journey.journeyViewData(
//			depStop: .init(),
//			arrStop: .init(),
//			realtimeDataUpdatedAt: 0,
//			settings: .init()),
//			Mock.journeys.alternativasMoks
//				.alternativesJourneyNeussWolfsburgS1FirstStopCancelled
//				.decodedData?.journey.journeyViewData(
//			depStop: .init(),
//			arrStop: .init(),
//			realtimeDataUpdatedAt: 0,
//			settings: .init()),
//			Mock.journeys.alternativasMoks
//				.alternativesJourneyNeussWolfsburgS1LastStopCancelled
//				.decodedData?.journey.journeyViewData(
//			depStop: .init(),
//			arrStop: .init(),
//			realtimeDataUpdatedAt: 0,
//			settings: .init()),
		 ].filter {
			 $0 != nil
		 }
		if !journeys.isEmpty {
			let chewVM = ChewViewModel(referenceDate: .specificDate(journeys.first!!.time.timestamp.departure.planned!+12000),coreDataStore: .preview)
			VStack {
				ScrollView(.horizontal) {
					FlowLayout {
						ForEach(journeys, id: \.hashValue) { journey in
							let vm = JourneyDetailsViewModel(
								followId: 0,
								data: journey!,
								depStop: .init(),
								arrStop: .init(),
								chewVM: chewVM
							)
							JourneyAlternativesView(jdvm: vm)
								.frame(width: 400,height: 450)
						}
					}
					.frame(width:900,height: 1000)
				}
				ReferenceTimeSliderView()
			}
			.environmentObject(chewVM)
		}
	}
}

extension View {
	func localisedString( _ key: String,
		comment: String) -> String {
		NSLocalizedString(key, comment: "\(Self.self) \(comment)")
	}
}
