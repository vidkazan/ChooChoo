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
    enum TimeLabelType {
        case onlyOffset
        case onlyTime
        case timeAndOffset
        case timeOrOffset
    }
	enum Arragement {
		case left
		case right
		case bottom
	}
    
	let size : ChewTextSize
	let arragement : Arragement
    let type : TimeLabelType
	var delayStatus : TimeContainer.DelayStatus
	var time : Prognosed<Date>
    
	var body: some View {
        HStack(spacing: 2) {
            if type != .onlyOffset {
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
            if type != .onlyTime, let time = time.actualOrPlannedIfActualIsNil() {
                BadgeView(.timeOffset(time: time))
                    .disabled(delayStatus == .cancelled)
                    .foregroundColor(.primary)
                    .badgeBackgroundStyle(.secondary)
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
