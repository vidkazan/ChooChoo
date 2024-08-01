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
	@ObservedObject var javm : JourneyAlternativeDepartureStopViewModel
	@ObservedObject var jajlvm : JourneyAlternativeJourneysListViewModel
	
	init(jdvm: JourneyDetailsViewModel, javm : JourneyAlternativeDepartureStopViewModel,jajlvm : JourneyAlternativeJourneysListViewModel) {
		self.jdvm = jdvm
		self.javm = javm
		self.jajlvm = jajlvm
	}
	var body : some View {
		VStack {
			Form {
				alternativeFor
				if let journeyAlternativeViewData = javm.state.data {
					departureStop(alternativeViewData: journeyAlternativeViewData)
				}
				alternatives
			}
			.background(.secondary)
		}
		
		.onReceive(javm.$state, perform: { state in
			updateAlternativeJourneysIfNeeded(state: state)
		})
		
		.onReceive(minuteTimer, perform: { _ in
			jdvm.send(event: .didRequestReloadIfNeeded(id: jdvm.state.data.id, ref: jdvm.state.data.viewData.refreshToken, timeStatus: .active))
		})
		
		.onReceive(chewVM.$referenceDate, perform: { res in
			javm.send(event: .didUpdateJourneyData(data: jdvm.state.data.viewData, referenceDate: chewVM.referenceDate))
		})
		.onReceive(secondTimer, perform: { _ in
			javm.send(event: .didUpdateJourneyData(data: jdvm.state.data.viewData, referenceDate: chewVM.referenceDate))
		})
		.onAppear {
			javm.send(event: .didUpdateJourneyData(data: jdvm.state.data.viewData, referenceDate: chewVM.referenceDate))
		}
	}
}

extension JourneyAlternativesView {
	var alternatives : some View {
		Section(content: {
			switch jajlvm.state.status {
			case .loading:
				EmptyView()
			case .idle:
				if jajlvm.state.journeys.isEmpty {
					ErrorView(viewType: .alert, msg: Text(verbatim: "No alternatives"), action: nil)
				} else {
					List(jajlvm.state.journeys) {
						JourneyCell(
							journey: $0,
							stops: .init(
								departure: .init(),
								arrival: .init()
							)
						)
						.listStyle(.plain)
					}
				}
			case .error(let error):
				ErrorView(viewType: .error, msg: Text(verbatim: error.localizedDescription), reloadAction: {
					jajlvm.send(event: .didUpdateJourneyData(
						depStop: jajlvm.state.depStop,
						time: jajlvm.state.time,
						referenceDate: chewVM.referenceDate
					))
				})
			}
		}, header: {
			HStack {
				Text(
					"Alternatives",
					comment: "JourneyAlternativesView: alternatives section"
				)
				Button(action: {
					updateAlternativeJourneys(state: javm.state)
				}, label: {
					switch jajlvm.state.status {
					case .error:
						ReloadableButtonLabel(state: .error)
					case .loading:
						ReloadableButtonLabel(state: .loading)
					case .idle:
						ReloadableButtonLabel(state: .idle)
					}
				})
			}
		})
	}
}
extension JourneyAlternativesView {
	func updateAlternativeJourneysIfNeeded(state : JourneyAlternativeDepartureStopViewModel.State) {
		if (state.data?.alternativeDeparture.stopViewData.id != jajlvm.state.depStop.id ||
			chewVM.referenceDate.ts - jajlvm.state.lastRequestTS > 60) {
			self.updateAlternativeJourneys(state: state)
		}
	}
	func updateAlternativeJourneys(state : JourneyAlternativeDepartureStopViewModel.State) {
		if let stopViewData = javm.state.data?.alternativeDeparture.stopViewData,
			let stop = stopViewData.stop(),
			let time = Self.getTime(journeyAlternativeSVD: stopViewData),
			stop.id != jdvm.state.data.arrStop.id {
				jajlvm.send(event: .didUpdateJourneyData(
					depStop: stop,
					time: time.date,
					referenceDate: chewVM.referenceDate
				))
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
					PlatformView(isShowingPlatormWord: false, platform: alternativeViewData.alternativeDeparture.stopViewData.platforms.arrival)
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

//extension JourneyAlternativesView {
//	var searchButton : some View {
//		Button(action: {
//			if let depStopViewData = journeyAlternativeViewData?.alternativeDeparture.stopViewData,
//			   let depStop = depStopViewData.stop()
//			{
//				if let leg = journeyAlternativeViewData?.alternativeDeparture.leg,
//				   let depStopArrival = depStopViewData.time.timestamp.arrival.actual  {
//					chewVM.send(event: .didUpdateSearchData(
//						dep: .transport(leg),
//						arr: .location(jdvm.state.data.arrStop),
//						date: .init(date: .specificDate(depStopArrival), mode: .departure),
//						journeySettings: jdvm.state.data.viewData.settings)
//					)
//				} else {
//					chewVM.send(event: .didUpdateSearchData(
//						dep: .location(depStop),
//						arr: .location(jdvm.state.data.arrStop),
//						date: .init(date: .now, mode: .departure),
//						journeySettings: jdvm.state.data.viewData.settings)
//					)
//				}
//			}
//			Model.shared.sheetVM.send(event: .didRequestHide)
//		}, label: {
//			HStack {
//				Spacer()
//				if nil != journeyAlternativeViewData?.alternativeDeparture.stopViewData.stop() {
//					Text(NSLocalizedString("Search", comment: "JourneyAlternativesView: button"))
//				} else {
//					Text(NSLocalizedString("error", comment: "JourneyAlternativesView: button"))
//				}
//				Spacer()
//			}
//			.chewTextSize(.big)
//		})
//		.padding(10)
//		.disabled(journeyAlternativeViewData?.alternativeDeparture.stopViewData.stop() == nil)
//	}
//}

extension JourneyAlternativesView {
	private static func getTime(journeyAlternativeSVD : StopViewData?) -> SearchStopsDate? {
		if let depStopViewData = journeyAlternativeSVD
		{
			if let depStopArrival = depStopViewData.time.timestamp.arrival.actual {
				return .init(date: .specificDate(depStopArrival), mode: .departure)
			} else {
				return .init(date: .now, mode: .departure)
			}
		}
		return nil
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
							let jdvm = JourneyDetailsViewModel(
								followId: 0,
								data: journey!,
								depStop: .init(),
								arrStop: .init(),
								chewVM: chewVM
							)
							let javm = JourneyAlternativeDepartureStopViewModel(arrStop: jdvm.state.data.arrStop, settings: jdvm.state.data.viewData.settings)
							let jajlvm = JourneyAlternativeJourneysListViewModel(
								arrStop: jdvm.state.data.arrStop,
								 depStop: .init(),
								 time: .now,
								 settings: jdvm.state.data.viewData.settings
							 )
							JourneyAlternativesView(jdvm: jdvm, javm: javm, jajlvm: jajlvm)
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
