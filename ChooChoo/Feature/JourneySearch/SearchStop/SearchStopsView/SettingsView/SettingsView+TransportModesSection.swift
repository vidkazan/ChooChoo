//
//  SettingsView.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 25.10.23.
//

import Foundation
import SwiftUI

extension SettingsView {
	var segments : some View {
		Section(
			content: {
				ForEach(LineType.allCases, id: \.rawValue) { type in
					if type != .foot, type != .transfer {
						Toggle(
							isOn: Binding(
								get: { currentSettings.customTransferModes.contains(type) },
								set: { _ in currentSettings.customTransferModes.toogle(val: type)}
							),
							label: {
								BadgeView(.lineNumber(
									lineType: type,
									num: type.shortValue
								))
								
							}
						)
					}
				}
			},
			header: {
				Text("Custom transport types",comment: "SettingsView: segments: section header")
			})
	}
}
