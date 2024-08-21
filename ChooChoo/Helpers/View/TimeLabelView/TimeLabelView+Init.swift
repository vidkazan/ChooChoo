//
//  TimeLabelView.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 20.09.23.
//

import Foundation
import SwiftUI


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
        self.type = type
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
        self.type = type
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
        self.type = type
	}
}
