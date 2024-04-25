//
//  ArrivalTrainTimeLabelView.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 25.04.24.
//

import Foundation
import SwiftUI

struct ArrivalTrainTimeLabelView: View {
	@ObservedObject var arrivingTrainVM : ArrivingTrainTimeViewModel
	let legViewData : LegViewData
	init(
		arrivingTrainVM: ArrivingTrainTimeViewModel = ArrivingTrainTimeViewModel(),
		baseTimeLabel: TimeLabelView,
		legViewData : LegViewData
	) {
		self.arrivingTrainVM = arrivingTrainVM
		self.baseTimeLabel = baseTimeLabel
		self.legViewData = legViewData
	}
	
	let baseTimeLabel : TimeLabelView
	
	var body : some View {
		VStack(spacing: 0) {
			Button(action: {
				switch arrivingTrainVM.state.status {
				case .idle,.error:
					arrivingTrainVM.send(event: .didRequestTime(leg: legViewData))
				case .loading:
					arrivingTrainVM.send(event: .didCancelRequestTime)
				}
			}, label: {
				switch arrivingTrainVM.state.status {
				case .idle:
					if let time = arrivingTrainVM.state.time {
						TimeLabelView(
							size: .medium,
							arragement: .bottom,
							delayStatus: .onTime,
							time: time
						)
						.badgeBackgroundStyle(.primary)
						.padding(.top,2)
					}
				case .loading:
					ProgressView()
						.chewTextSize(.medium)
						.padding(2)
				case .error:
					EmptyView()
				}
			})
			.transition(.slide)
			.onAppear {
				arrivingTrainVM.send(event: .didRequestTime(leg: legViewData))
			}
			baseTimeLabel
		}
	}
	
}
