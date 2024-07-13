//
//  AlternativesView.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 13.07.24.
//

import Foundation
import SwiftUI

struct AlternativesView: View {
	@ObservedObject var appSetttingsVM : AppSettingsViewModel
	init(appSetttingsVM: AppSettingsViewModel) {
		self.appSetttingsVM = appSetttingsVM
	}
	var body : some View {
		Form {
			
			Section {
				Button(action: {
					UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,options: [:], completionHandler: nil)
				}, label: {
					Text("App system settings",comment: "AppSettingsView")
				})
			}
			#if DEBUG
			Section("Debug", content: {
				Button(action: {
					appSetttingsVM.send(event: .didRequestToLoadInitialData(
						settings: AppSettings(
							debugSettings: appSetttingsVM.state.settings.debugSettings,
							legViewMode: appSetttingsVM.state.settings.legViewMode,
							tips: Set(ChooTip.TipType.allCases)
						)
					))
					Model.shared.sheetVM.send(event: .didRequestHide)
				}, label: {
					Text("Reset tips")
				})
				NavigationLink(destination: {
					LogViewer()
				}, label: {
					Text("Logs")
				})
			})
			#endif
		}
	}
}
