//
//  TimeLabelView.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 20.09.23.
//

import Foundation
import SwiftUI

// TODO: tests
struct TimeLabelView: View {
	enum Arragement {
		case left
		case right
		case bottom
	}
	let size : ChewTextSize
	let arragement : Arragement
	var delayStatus : TimeContainer.DelayStatus
	var time : Prognosed<Date>
	
	
	var body: some View {
		Group {
			switch delayStatus {
			case .onTime,.cancelled:
				mainTime(delay: 0)
			case .delay(let delay):
				switch arragement {
				case .left,.right:
					HStack(spacing: 2){
						switch arragement == .left {
						case true:
							optionalTime(delay: delay)
							mainTime(delay: delay)
						case false:
							mainTime(delay: delay)
							optionalTime(delay: delay)
						}
					}
				case .bottom:
					VStack(spacing: 2) {
						mainTime(delay: delay)
						optionalTime(delay: delay)
					}
				}
			}
		}
		.padding(2)
	}
}

extension TimeLabelView {
	func arrivalTrainTimeLabel(legViewData : LegViewData, isShowing: Bool = true) -> some View {
		Group {
			if isShowing {
				ArrivalTrainTimeLabelView(baseTimeLabel: self, legViewData: legViewData)
			} else {
				self
			}
		}
	}
}

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



#if DEBUG
struct TimeLabelPreviews: PreviewProvider {
	static var previews: some View {
		VStack {
			TimeLabelView(
				size: .medium,
				arragement: .bottom,
				time: .init(actual: .now, planned: .now),
				delayStatus: .onTime
			)
			.background(Color.chewFillSecondary)
			.cornerRadius(8)
			TimeLabelView(
				size: .medium,
				arragement: .right,
				time: .init(actual: .now + 600, planned: .now),
				delayStatus: .delay(10)
			)
			.background(Color.chewFillSecondary)
			.cornerRadius(8)
		}
	}
}
#endif
