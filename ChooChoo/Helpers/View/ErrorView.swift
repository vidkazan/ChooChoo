//
//  ErrorView.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 15.03.24.
//

import Foundation
import SwiftUI

struct ErrorView : View {
	enum ViewType : String,Hashable, CaseIterable {
		case error
		case alert
	}
	let viewType : ViewType
	let msg : Text
	let size : ChewPrimaryStyle = .big
	let action : (() -> Void)?
	let reloadAction : (() -> Void)?
	
	init(viewType: ViewType, msg: Text,size: ChewPrimaryStyle = .big, action: (() -> Void)?) {
		self.viewType = viewType
		self.msg = msg
		self.action = action
		self.reloadAction = nil
	}
	init(viewType: ViewType, msg: Text,size: ChewPrimaryStyle = .big, reloadAction: (() -> Void)?) {
		self.viewType = viewType
		self.msg = msg
		self.reloadAction = reloadAction
		self.action = nil
	}
	var body: some View {
		Label(
			title: {
				msg
					.foregroundStyle(.secondary)
			},
			icon: {
				if let reloadAction = reloadAction {
					Button(
						action: reloadAction,
						label: {
							Image(.arrowClockwise)
						}
					)
				} else if let action = action {
					Button(
						action: action,
						label: {
							Image(.exclamationmarkCircle)
						}
					)
				} else {
					Image(viewType == .error ? ChooSFSymbols.exclamationmarkCircle : ChooSFSymbols.infoCircle)
						.foregroundStyle(.secondary)
				}
			}
		)
		.padding(5)
		.chewTextSize(size)
	}
}
