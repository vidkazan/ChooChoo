//
//  AlertView.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 17.01.24.
//

import Foundation
import SwiftUI

extension AnyTransition {
	static var moveAndOpacity: AnyTransition {
		AnyTransition.move(edge: .top).combined(with: .opacity)
	}
}

struct TopBarAlertsView: View {
	@EnvironmentObject var chewJourneyViewModel : ChewViewModel
	@ObservedObject var alertVM : TopBarAlertViewModel = Model.shared.topBarAlertVM
	let timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
	var body: some View {
		Group {
			switch alertVM.state.status {
			case .start:
				EmptyView()
			case .showing,.adding,.deleting :
					VStack(spacing: 2) {
						ForEach(
							alertVM.state.alerts.sorted(by: <),
							id: \.hashValue,
							content: { alert in
								if alert.badgeType != .offlineMode {
									TopBarAlertView(alertVM: alertVM, alert: alert)
										.transition(.moveAndOpacity)
								}
							}
						)
					}
					.padding(.horizontal,10)
//					.animation(.smooth, value: alertVM.state.alerts)
			}
		}
		.onReceive(timer, perform: { _ in
			var types = alertVM.state.alerts.filter({
				$0.action != TopBarAlertViewModel.Action.none
			})
			if let last = types.popFirst(), let event = last.action.alertViewModelEvent(alertType: last) {
				alertVM.send(event: event)
			}
		})
	}
}

struct Bla : View {
	@ObservedObject var vm : TopBarAlertViewModel
	var body: some View {
		ForEach(0..<3) { index in
			Color.random
				.frame(maxWidth: .infinity,maxHeight: 300)
				.cornerRadius(10)
				.padding(.horizontal,10)
		}
		.animation(.smooth, value: vm.state)
	}
}

#if DEBUG
struct AlertViewPreview : PreviewProvider {
	@ObservedObject var vm = TopBarAlertViewModel(.start,alerts: [.routeError,.offline,.userLocationError])
	static var previews: some View {
		
		let vm = TopBarAlertViewModel(
			.showing,
			alerts: [
				.routeError,
				.journeyFollowError(type:.adding),
				.offline,
				.userLocationError
			]
		)
		VStack {
			TopBarAlertsView(alertVM: vm)
			Bla(vm: vm)
		}
		.environmentObject(ChewViewModel())
	}
}
#endif
