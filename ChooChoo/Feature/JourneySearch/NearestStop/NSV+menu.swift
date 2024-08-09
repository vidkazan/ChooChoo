//
//  NSV+menu.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 09.08.24.
//

import Foundation
import SwiftUI

extension NearestStopView {
	@ViewBuilder func menu(stop : Stop) -> some View {
		Group {
			Button(action: {
				chewVM.send(event: .didUpdateSearchData(dep: .location(stop)))
			}, label: {
				Label(
					title: {
						Text("Set as departure", comment: "NearestStopView: stop cell: context menu")
					},
					icon: {
						Image(.location)
					}
				)
			})
			Button(action: {
				chewVM.send(event: .didUpdateSearchData(arr: .location(stop)))
			}, label: {
				Label(
					title: {
						Text("Set as arrival", comment: "NearestStopView: stop cell: context menu")
					},
					icon: {
						Image(systemName: "arrow.right.to.line")
					}
				)
			})
			Button(action: {
				if let coord = Model.shared.locationDataManager.location?.coordinate {
					Model.shared.sheetVM.send(event: .didRequestShow(
						.mapDetails(.footDirection(
							LegViewData(footPathStops: DepartureArrivalPairStop(
								departure: Stop(
								 coordinates: Coordinate(coord),
								 type: .location,
								 stopDTO: nil
							 ),
							 arrival: stop
						 ))))
					))
				}
			}, label: {
				Label(
					title: {
						Text("Foot path", comment: "NearestStopView: stop cell: context menu")
					},
					icon: {
						Image(ChooSFSymbols.figureWalk)
					}
				)
			})
		}
	}
}
