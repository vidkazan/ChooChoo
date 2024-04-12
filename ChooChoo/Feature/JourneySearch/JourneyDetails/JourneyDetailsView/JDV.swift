//
//  JourneyDetails.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 11.09.23.
//

import SwiftUI
import MapKit
import TipKit

struct JourneyDetailsView: View {
	@EnvironmentObject var chewVM : ChewViewModel
	@ObservedObject var viewModel : JourneyDetailsViewModel
	@ObservedObject var appSettingsVM : AppSettingsViewModel = Model.shared.appSettingsVM
	@State var scrollToLegId : UUID?
	init(journeyDetailsViewModel : JourneyDetailsViewModel) {
		viewModel = journeyDetailsViewModel
	}
	var body: some View {
		VStack {
			ZStack {
				VStack {
					header()
						.animation(.smooth, value: viewModel.state.status)
						.padding(.horizontal,5)
						.padding(5)
					ScrollViewReader { proxy in
						ScrollView {
							LazyVStack(spacing: 0){
								ForEach(viewModel.state.data.viewData.legs) { leg in
									LegDetailsView(
										send: viewModel.send,
										referenceDate: chewVM.referenceDate,
										isExpanded: .collapsed,
										leg: leg
									)
									.background(leg.legType == LegViewData.LegType.line ? Color.chewLegDetailsCellGray : .clear )
									.cornerRadius(10)
									.id(leg.id)
								}
							}
						}
						.onChange(of: scrollToLegId, perform: { id in
							withAnimation(.easeInOut, {
								proxy.scrollTo(id, anchor: .bottom)
							})
						})
						.onAppear {
							Task {
								performOnAppear(proxy: proxy)
							}
						}
					}
					.padding(10)
				}
			}
			.background(Color.chewFillPrimary)
			.navigationBarTitle(
				Text(
					"Journey details",
					 comment: "navigationBarTitle"
				),
				displayMode: .inline
			)
			.toolbar { toolbar() }
			.onAppear {
				viewModel.send(event: .didRequestReloadIfNeeded(
					id: viewModel.state.data.id,
					ref: viewModel.state.data.viewData.refreshToken,
					timeStatus: .active
				))
			}
		}
	}
}

extension JourneyDetailsView {
	func performOnAppear(proxy : ScrollViewProxy) {
		let activeLeg : UUID?  = {
			viewModel.state.data.viewData.legs.filter({
				chewVM.referenceDate.ts > $0.time.timestamp.departure.actual ?? 0 && chewVM.referenceDate.ts < $0.time.timestamp.arrival.actual ?? 0
			}).first?.id
		}()
		withAnimation(.easeInOut, {
			proxy.scrollTo(activeLeg, anchor: .center)
		})
	}
}
//
//struct JourneyDetailsPreview : PreviewProvider {
//	static var previews: some View {
//		let mocks = [
//			Mock.journeys.journeyNeussWolfsburgFirstCancelled.decodedData!.journey,
////			Mock.journeys.journeyNeussWolfsburgMissedConnection.decodedData!.journey
//		]
////		ScrollView(.horizontal) {
////			LazyHStack {
//				ForEach(mocks.prefix(1),id: \.id) { mock in
//					let viewData = mock.journeyViewData(
//						depStop:  .init(coordinates: .init(),type: .stop,stopDTO: nil),
//						arrStop:  .init(coordinates: .init(),type: .stop,stopDTO: nil),
//						realtimeDataUpdatedAt: 0,
//						settings: .init()
//					)
//					JourneyDetailsView(
//						journeyDetailsViewModel: JourneyDetailsViewModel(
//							followId: 0,
//							data: viewData!,
//							depStop: .init(),
//							arrStop: .init(),
//							chewVM: .init()
//						))
//					.environmentObject(ChewViewModel(referenceDate: .specificDate((viewData!.time.timestamp.departure.actual ?? 0) + 1000)))
//				}
////			}
////		}
////		.previewDevice(PreviewDevice(.iPadMini6gen))
//	}
//}
