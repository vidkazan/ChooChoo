//
//  UpdatedAtView.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 16.02.24.
//

import Foundation
import SwiftUI

struct UpdatedAtBadgeView : View {
	@EnvironmentObject var chewVM : ChewViewModel
	let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
	let refTime : Double
	let isLoading : Bool
	@State var updatedAt : Text?
	
	init(bgColor : Color, refTime : Double, isLoading : Bool) {
		self.refTime = refTime
		self.isLoading = isLoading
		self.updatedAt = Self.update(refTime)
	}
	
	var body : some View {
		HStack(spacing: 2) {
			if let updatedAt = updatedAt {
				OneLineText(updatedAt)
					.foregroundColor(.primary.opacity(0.6))
				if isLoading == true {
					ProgressView()
						.scaleEffect(0.65)
						.frame(width: 15, height: 15)
				}
			}
		}
		.onAppear {
			self.updatedAt = Self.update(refTime, chewDate: chewVM.referenceDate)
		}
		.onReceive(timer, perform: { _ in
			self.updatedAt = Self.update(refTime, chewDate: chewVM.referenceDate)
		})
	}
	
	static func update(_ refTime : Double, chewDate : ChewDate = .now) -> Text? {
		let minutes = DateParcer.getTwoDateIntervalInMinutes(
			date1: Date(timeIntervalSince1970: .init(floatLiteral: refTime)),
			date2: chewDate.date
		)
		
		switch minutes {
		case 0..<1:
			return Text("updated now", comment: "badge: updated at")
		default:
			if let dur = DateParcer.timeDuration(minutes) {
				return Text("updated \(dur) ago", comment: "badge")
			}
			return nil
		}
	}
}

struct TimeOffsetView : View {
	@EnvironmentObject var chewVM : ChewViewModel
	let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
	let refTime : Date
	@State var timeOffset : Text?
	
	init(refTime : Date) {
		self.refTime = refTime
		self.timeOffset = Self.update(refTime)
	}
	
	var body : some View {
		HStack(spacing: 2) {
			if let timeOffset = timeOffset {
				OneLineText(timeOffset)
			}
		}
		.onAppear {
			self.timeOffset = Self.update(refTime, chewDate: chewVM.referenceDate)
		}
		.onReceive(timer, perform: { _ in
			self.timeOffset = Self.update(refTime, chewDate: chewVM.referenceDate)
		})
	}
	
	static func update(
		_ refTime : Date,
		chewDate : ChewDate = .now
	) -> Text? {
        if let string = DateParcer.timeOffsetString(refTime,chewDate: chewDate) {
            return Text(verbatim: string)
        } else {
            return nil
        }
//		let min = DateParcer.getTwoDateIntervalInMinutes(date1: chewDate.date, date2: refTime)
//		switch min {
//		case 0..<1:
//			return Text("now", comment: "Badge: timeOffset")
//		default:
//			if let dur = DateParcer.timeDuration(min) {
//				return Text("in \(dur)", comment: "Badge: timeOffset")
//			}
//			return nil
//		}
	}
}
