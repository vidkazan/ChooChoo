//
//  ReferenceTimeSliderView.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 14.07.24.
//

import Foundation
import SwiftUI

enum TimeSliderRangeCases : Double, Hashable, CaseIterable {
	case tenMinutes = 600
	case thirtyMinutes = 1800
	case oneHour = 3600
	case fiveHours = 18000
	
	var description : String {
		switch self {
		case .tenMinutes:
			return "10min"
		case .thirtyMinutes:
			return "30min"
		case .oneHour:
			return "1h"
		case .fiveHours:
			return "5h"
		}
	}
}

struct ReferenceTimeSliderView : View {
	@EnvironmentObject var chewVM : ChewViewModel
	@State var sliderValue : Double = 0
	@State var disclosedSliderSettings : Bool = false
 	@State var initialReferenceDate : ChewDate = .now
	@State var timeRangeInSeconds : TimeSliderRangeCases = .tenMinutes
	
	var body: some View {
		VStack {
			HStack(spacing: 1) {
				Button("now", action: {
					sliderValue = 0
				})
				.padding(5)
				.chewTextSize(.big)
				.badgeBackgroundStyle(.accent)
				Slider(
					value: $sliderValue,
					in: -1...1
				)
				.padding(5)
				.onChange(of: sliderValue, perform: { val in
					withAnimation {
						chewVM.referenceDate = date(val: val)
					}
				})
				Text(date(val:sliderValue).date, style: .time)
					.padding(5)
					.chewTextSize(.big)
					.badgeBackgroundStyle(.secondary)
				Button(action: {
					disclosedSliderSettings.toggle()
				}, label: {
					Image(.sliderHorizontal)
						.chewTextSize(.big)
						.tint(.gray)
					
				})
				.frame(width: 40,height: 40)
				
				CloseButton(action: {
					chewVM.referenceDate = .now
					Model.shared.appSettingsVM.send(event: .didRequestToUpdateAppSettings(
						settings: AppSettings(
							debugSettings: .init(
								prettyJSON: Model.shared.appSettingsVM.state.settings.debugSettings.prettyJSON,
								alternativeSearchPage: Model.shared.appSettingsVM.state.settings.debugSettings.alternativeSearchPage,
								timeSlider: false
							),
							legViewMode: Model.shared.appSettingsVM.state.settings.legViewMode,
							tips: Model.shared.appSettingsVM.state.settings.tipsToShow
						)
					))
				})
				.frame(width: 40,height: 40)
			}
			if disclosedSliderSettings == true {
				HStack {
					Picker(selection: $timeRangeInSeconds, content: {
						ForEach(TimeSliderRangeCases.allCases,id: \.hashValue, content: {
							Text(verbatim: $0.description)
								.tag($0)
						})
					}, label: {
						Text(verbatim: "Slider time range")
					})
					.pickerStyle(.segmented)
				}
			}
		}
		.onAppear {
			self.initialReferenceDate = chewVM.referenceDate
		}
		.padding(5)
		.badgeBackgroundStyle(.accent)
		.padding(10)
		
	}
}

extension ReferenceTimeSliderView {
	func date(val : Double) -> ChewDate {
		return .specificDate(initialReferenceDate.ts + (timeRangeInSeconds.rawValue * val))
	}
}

#Preview {
	ReferenceTimeSliderView(initialReferenceDate: .now)
		.environmentObject(ChewViewModel(coreDataStore: .preview))
}
