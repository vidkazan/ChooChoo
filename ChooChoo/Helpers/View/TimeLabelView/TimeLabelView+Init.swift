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
        showOffset : Bool = false
	) {
		self.size = size
		self.arragement = arragement
		self.time = time
		self.delayStatus = delayStatus
        self.showOffset = showOffset
	}
	
	init(
		stopOver : StopViewData,
		stopOverType : StopOverType,
        showOffset : Bool = false
	) {
		self.delayStatus = stopOver.stopOverType.timeLabelViewDelayStatus(time: stopOver.time)
		self.size = stopOverType.timeLabelSize
		self.arragement = stopOverType.timeLabelArragament
		let time = stopOver.stopOverType.timeLabelViewTime(tsContainer: stopOver.time.date)
		self.time = Prognosed(actual: time.actual,planned: time.planned)
        self.showOffset = showOffset
	}
	
	init(
		stopOver : StopViewData,
        showOffset : Bool = false
	) {
		self.delayStatus = stopOver.stopOverType.timeLabelViewDelayStatus(time: stopOver.time)
		self.size = stopOver.stopOverType.timeLabelSize
		self.arragement = stopOver.stopOverType.timeLabelArragament
		let time = stopOver.stopOverType.timeLabelViewTime(tsContainer: stopOver.time.date)
		self.time = Prognosed(actual: time.actual,planned: time.planned)
        self.showOffset = showOffset
	}
}
