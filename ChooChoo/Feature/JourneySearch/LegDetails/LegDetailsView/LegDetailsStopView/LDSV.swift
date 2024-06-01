//
//  LegDetailsView.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 18.09.23.
//

import Foundation
import SwiftUI

struct LegStopView : View {
	@EnvironmentObject var chewVM : ChewViewModel
	var shevronIsExpanded : Segments.ShowType
	static let timeLabelColor = Color.chewTimeLabelGray
	let legViewData : LegViewData
	let stopOver : StopViewData
	let stopOverType : StopOverType
	let showBadges : Bool
	@State var showingTimeDetails = false
	
	
	var body : some View {
		switch stopOverType {
		case .transfer,.footMiddle:
			transfer
		case .footBottom:
			footBottom
		case .footTop,.origin,.destination,.stopover:
			HStack(alignment:  .top) {
				timeLabel
				nameAndBadges
				Spacer()
			}
			.frame(height: stopOverType.viewHeight)
		}
	}
}

extension LegStopView {
	init(
		type : StopOverType,
		stopOver : StopViewData,
		leg : LegViewData,
		showBadges : Bool,
		shevronIsExpanded : Segments.ShowType
	) {
		self.showBadges = showBadges
		self.stopOver = stopOver
		self.stopOverType = type
		self.legViewData = leg
		self.shevronIsExpanded = shevronIsExpanded
	}
	init(
		stopOver : StopViewData,
		leg : LegViewData,
		showBadges : Bool,
		shevronIsExpanded : Segments.ShowType
	) {
		self.showBadges = showBadges
		self.stopOver = stopOver
		self.stopOverType = stopOver.stopOverType
		self.legViewData = leg
		self.shevronIsExpanded = shevronIsExpanded
	}
}

#if DEBUG
struct LegStopPreview : PreviewProvider {
	static var previews : some View {
		let mock = Mock.trip.cancelledMiddleStopsRE6NeussMinden.decodedData
		if let mock = mock?.trip,
		   let viewData = mock.legViewData(firstTS: .now, lastTS: .now, legs: [mock]) {
			ScrollView(.horizontal) {
				LazyHStack {
					ForEach(viewData.legStopsViewData.prefix(1),id:\.name) { leg in
						VStack {
							ForEach(StopOverType.allCases, id: \.rawValue, content: { type in
								LegStopView(
									type: type,
									stopOver: leg,
									leg: viewData,
									showBadges: true,
									shevronIsExpanded: .collapsed
								)
								.environmentObject(
									ChewViewModel(
										referenceDate: .specificDate((
											viewData.time.timestamp.departure.actual ?? 0)), coreDataStore: .preview))
								.padding(5)
								.background(Color.chewFillAccent)
								.cornerRadius(8)
							})
						}
						.frame(minWidth: 350)
					}
				}
			}
			.background(Color.chewFillPrimary)
//			.previewDevice(PreviewDevice(.iPadMini6gen))
//			.previewInterfaceOrientation(.landscapeLeft)
		} else {
			Text(verbatim: "error")
		}
	}
}
#endif
