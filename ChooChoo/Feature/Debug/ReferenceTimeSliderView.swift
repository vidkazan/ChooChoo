//
//  ReferenceTimeSliderView.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 14.07.24.
//

import Foundation
import SwiftUI

struct ReferenceTimeSliderView : View {
	@EnvironmentObject var chewVM : ChewViewModel
	@State var sliderValue : Double = 0
 	@State var initialReferenceDate : ChewDate = .now
	static let timeRangeInSeconds : Double = 1200
	
	var body: some View {
		HStack {
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
				Model.shared.appSettingsVM.send(event: .didRequestToUpdateAppSettings(
					settings: AppSettings(
						debugSettings: .init(
							prettyJSON: Model.shared.appSettingsVM.state.settings.debugSettings.prettyJSON,
							alternativeSearchPage: Model.shared.appSettingsVM.state.settings.debugSettings.alternativeSearchPage,
							timeSlider: false
						),
					legViewMode: Model.shared.appSettingsVM.state.settings.legViewMode,
					tips: Model.shared.appSettingsVM.state.settings.tipsToShow)
				))
			}, label: {
				Image(.xmarkCircle)
					.chewTextSize(.big)
					.tint(.gray)
				
			})
			.frame(width: 40,height: 40)
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
		return .specificDate(initialReferenceDate.ts + (Self.timeRangeInSeconds * val))
	}
}

#Preview {
	ReferenceTimeSliderView(initialReferenceDate: .now)
		.environmentObject(ChewViewModel(coreDataStore: .preview))
}
