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
    static let timeOrOffsetTime : Double = 3600 * 1
    @EnvironmentObject var chewVM : ChewViewModel
    enum TimeLabelType : String, Hashable {
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
    
    @State var timer = Timer.publish(every: Self.timeOrOffsetTime, on: .main, in: .common)
	let size : ChewTextSize
	let arragement : Arragement
    @State public var type : TimeLabelType
    
	var delayStatus : TimeContainer.DelayStatus
	var time : Prognosed<Date>
    
	var body: some View {
        HStack(spacing: 2) {
            if type != .onlyOffset || type == .timeOrOffset {
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
            if type != .onlyTime || type == .timeOrOffset, let time = time.actualOrPlannedIfActualIsNil() {
                BadgeView(.timeOffset(time: time),size == .medium ? .medium : .big)
                    .foregroundColor(.primary)
                    .badgeBackgroundStyle(size == .medium ? .secondary : .clear)
            }
        }
        .onAppear {
            evaluateTimeOrOffsetType()
        }
        .onReceive(timer, perform: { _ in
            evaluateTimeOrOffsetType()
        })
		.padding(2)
	}
}

extension TimeLabelView {
    func evaluateTimeOrOffsetType() {
        if type == .timeOrOffset {
            if  let time = time.actualOrPlannedIfActualIsNil() {
                let diff = time.timeIntervalSince1970 - chewVM.referenceDate.ts
                if diff < 0 {
                    timer = Timer.publish(every: Self.timeOrOffsetTime, on: .main, in: .common)
                    type = .onlyOffset
                } else if diff < Self.timeOrOffsetTime {
                    timer = Timer.publish(every: diff, on: .main, in: .common)
                    type = .onlyOffset
                } else {
                    type = .onlyTime
                    timer = Timer.publish(every: Self.timeOrOffsetTime, on: .main, in: .common)
                }
            } else {
                type = .onlyTime
                timer = Timer.publish(every: Self.timeOrOffsetTime, on: .main, in: .common)
            }
        }
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

extension TimeLabelView {
    init(
        size : ChewTextSize,
        arragement : Arragement,
        time : Prognosed<Date>,
        delayStatus : TimeContainer.DelayStatus,
        type : Self.TimeLabelType = .onlyTime
    ) {
        self.size = size
        self.arragement = arragement
        self.time = time
        self.delayStatus = delayStatus
        self._type = State(initialValue: type)
    }
    
    init(
        stopOver : StopViewData,
        stopOverType : StopOverType,
        type : Self.TimeLabelType = .onlyTime
    ) {
        self.delayStatus = stopOver.stopOverType.timeLabelViewDelayStatus(time: stopOver.time)
        self.size = stopOverType.timeLabelSize
        self.arragement = stopOverType.timeLabelArragament
        let time = stopOver.stopOverType.timeLabelViewTime(tsContainer: stopOver.time.date)
        self.time = Prognosed(actual: time.actual,planned: time.planned)
        self._type = State(initialValue: type)
    }
    
    init(
        stopOver : StopViewData,
        type : Self.TimeLabelType = .onlyTime
    ) {
        self.delayStatus = stopOver.stopOverType.timeLabelViewDelayStatus(time: stopOver.time)
        self.size = stopOver.stopOverType.timeLabelSize
        self.arragement = stopOver.stopOverType.timeLabelArragament
        let time = stopOver.stopOverType.timeLabelViewTime(tsContainer: stopOver.time.date)
        self.time = Prognosed(actual: time.actual,planned: time.planned)
        self._type = State(initialValue: type)
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
