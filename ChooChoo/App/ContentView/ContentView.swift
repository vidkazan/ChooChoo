//
//  ContentView.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 23.08.23.
//

import SwiftUI
import TipKit

 
// SSV: all widgets depend and reload on every chewVM state change
// map picker: tip for long tap / fix animation
// dashboard with speed etc.
// nsv: fix filtering: sort types by name
// logging: put logger to choobutton protocol

// TODO: feature: ldsv: make stop tappable and show stop details and all leg stopover info
// TODO: jfv: mapCell: map without interaction, icons
// performance: main thread is blocked while updating journeys 
struct ContentView: View {
	@EnvironmentObject var chewViewModel : ChewViewModel
	@ObservedObject var alertVM = Model.shared.alertVM
	@ObservedObject var sheetVM = Model.shared.sheetVM
	@ObservedObject var topAlertVM = Model.shared.topBarAlertVM
	
	@State var state = ChewViewModel.State()
	@State var sheetState = SheetViewModel.State(status: .showing(.none, result: EmptyDataSource()))
	@State var alertState = AlertViewModel.State(alert: .none)
	@State var sheetIsPresented = false
	@State var alertIsPresented = false
	
	var body: some View {
		Group {
			switch state.status {
			case .start:
				ProgressView()
			default:
				ZStack(alignment: .top) {
					FeatureView()
					TopBarAlertsView()
				}
			}
		}
		.task {
			if #available(iOS 17.0, *) {
				try? Tips.configure([
					.displayFrequency(.immediate),
					.datastoreLocation(.applicationDefault)
				])
			}
		}
		.confirmationDialog(
			"confirmation dialog",
			isPresented: Binding(
				get: { checkConfirmatioDialog(isSheet: false) },
				set: { _ in Model.shared.alertVM.send(event: .didRequestDismiss) }
			),
			actions: confirmationDialogActions,
			message: confirmationDialogMessage
		)
		.alert(
			isPresented: Binding(
			get: { checkAlert() },
			   set: { _ in Model.shared.alertVM.send(event: .didRequestDismiss) }
		   ),
			content: alert
		)
		.sheet(
			isPresented: $sheetIsPresented,
			onDismiss: {
				sheetIsPresented = false
			},
			content: {
				SheetView(closeSheet: {
					sheetIsPresented = false
				})
				.alert(isPresented: $alertIsPresented, content: alert)
				.confirmationDialog(
					"confirmation dialog sheet",
					isPresented: Binding(
						get: { checkConfirmatioDialog(isSheet: true) },
						set: { _ in Model.shared.alertVM.send(event: .didRequestDismiss) }
					),
					actions: confirmationDialogActions,
					message: confirmationDialogMessage
				)
			}
		)
		.onAppear {
			chewViewModel.send(event: .didStartViewAppear)
			UITabBar.appearance().backgroundColor = UIColor(Color.chewFillPrimary)
		}
		.onReceive(chewViewModel.$state, perform: { newState in
			state = newState
		})
		.onReceive(sheetVM.$state, perform: { newState in
			sheetState = newState
			switch newState.status {
			case .loading(let type),.showing(let type, _):
				sheetIsPresented = type != .none
			default:
				break
			}
		})
		.onReceive(alertVM.$state, perform: { newState in
			alertState = newState
		})
	}
}

extension ContentView {
	func checkConfirmatioDialog(isSheet : Bool) -> Bool {
		switch alertState.alert {
		case .none,.info,.action:
			return false
		case .destructive:
			return sheetIsPresented ? isSheet : !isSheet
		}
	}
}

extension ContentView {
	func checkAlert() -> Bool {
		switch alertState.alert {
		case .info,.action:
			return true
		case .destructive,.none:
			return false
		}
	}
}

extension ContentView {
	@ViewBuilder func confirmationDialogActions() -> some View {
		switch alertVM.state.alert {
		case .none,.info,.action:
			EmptyView()
		case .destructive(let destructiveAction, _, let actionDescription, _):
			Button(actionDescription, role: .destructive, action: destructiveAction)
		}
	}
	
	@ViewBuilder func confirmationDialogMessage() -> some View {
		switch alertState.alert {
		case .none,.info,.action:
			EmptyView()
		case .destructive(_, let description, _, _):
			Text(verbatim: description)
		}
	}
	
	func alert() -> Alert {
		switch alertState.alert {
		case let .destructive(destructiveAction, description, actionDescripton,_):
			return Alert(
				title: Text(verbatim: description) ,
				primaryButton: .cancel(),
				secondaryButton: .destructive(
					Text(verbatim: actionDescripton),
					action: destructiveAction
				)
			)
		case let .action(action, description, actionDescripton,_):
			return Alert(
				title: Text(verbatim: description) ,
				primaryButton: .cancel(),
				secondaryButton: .default(
					Text(verbatim: actionDescripton),
					action: action
				)
			)
		case let .info(title, msg):
			return Alert(title: Text(verbatim: title),message: Text(verbatim: msg))
		case .none:
			return Alert(title: Text(verbatim: ""))
		}
	}
}
