//
//  TimeAndSettingsView.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 21.01.24.
//

import Foundation
import SwiftUI

struct TimeAndSettingsView: View {
	@Environment(\.colorScheme) var colorScheme
	@EnvironmentObject var chewViewModel : ChewViewModel
	@State var state = ChewViewModel.State()

	
	var body: some View {
		Group {
			VStack(spacing: 0) {
				HStack {
					TimeChoosingView()
					settingsBtn()
				}
			}
		}
		.onReceive(chewViewModel.$state, perform: { newState in
			state = newState
		})
	}
}

extension TimeAndSettingsView {
	@ViewBuilder func settingsBtn() -> some View {
		Button(action: {
			Model.shared.sheetVM.send(event: .didRequestShow(.journeySettings))
		}, label: {
			Image(.sliderHorizontal)
				.tint(.primary)
				.chewTextSize(.big)
				.frame(maxWidth: 40,maxHeight: 40)
				.background(Color.chewFillAccent)
				.cornerRadius(8)
				.overlay(alignment: .topTrailing) {
					chewViewModel.state.data.journeySettings.iconBadge.view
						.padding(5)
				}
		})
		.frame(maxWidth: 40,maxHeight: 40)
	}
}

#if DEBUG
struct TimeAndSettingsPreview : PreviewProvider {
	static var previews: some View {
		TimeAndSettingsView()
			.padding(10)
			.environmentObject(ChewViewModel(referenceDate: .now))
			.background(Color.chewFillPrimary)
	}
}
#endif
