//
//  AlertView.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 17.01.24.
//

import Foundation
import SwiftUI

struct TopBarAlertView: View {
	@EnvironmentObject var chewJourneyViewModel : ChewViewModel
	@ObservedObject var alertVM : TopBarAlertViewModel = Model.shared.topBarAlertVM
	
	let alert : TopBarAlertViewModel.AlertType
	
	var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 10)
				.fill(alert.bgColor.blendMode(.darken))
				.background(.ultraThinMaterial)
				.frame(height: 35)
				.cornerRadius(10)
			HStack {
				if let infoAction = alert.infoAction {
					Button(
						action: infoAction, label: {
							ChooSFSymbols.infoCircle.view
								.foregroundColor(.white.opacity(0.7))
								.chewTextSize(.big)
								.lineLimit(1)
						})
					.padding(.leading,15)
				}
				Spacer()
				if case .none = alert.action {
					EmptyView()
				} else {
					Button(action: {
						switch alert.action {
						case .dismiss:
							alertVM.send(event: .didRequestDismiss(alert))
						case .reload(let action):
							action()
						case .none:
							break
						}
					}, label: {
						Image(systemName: alert.action.iconName)
							.foregroundColor(.white.opacity(0.7))
							.chewTextSize(.big)
							.lineLimit(1)
					})
					.padding(.trailing,15)
				}
			}
			.frame(maxWidth: .infinity,maxHeight: 35)
			BadgeView(alert.badgeType)
				.foregroundColor(.white)
				.chewTextSize(.medium)
				.cornerRadius(8)
				.frame(maxWidth: .infinity,maxHeight: 35)
		}
		.frame(maxWidth: .infinity,maxHeight: 35)
	}
}
