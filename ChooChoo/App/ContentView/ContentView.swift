//
//  ContentView.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 23.08.23.
//

import SwiftUI
import TipKit
import OSLog

struct ContentView: View {
	@EnvironmentObject var chewViewModel : ChewViewModel
	@ObservedObject var alertVM = Model.shared.alertVM
	@ObservedObject var sheetVM = Model.shared.sheetVM
	@ObservedObject var topAlertVM = Model.shared.topBarAlertVM
	@ObservedObject var appSettingsVM = Model.shared.appSettingsVM
	
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
					if appSettingsVM.state.settings.debugSettings.timeSlider == true {
						VStack {
							Spacer()
							ReferenceTimeSliderView(initialReferenceDate: chewViewModel.referenceDate)
								.padding(.bottom,30)
						}
					}
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
			"",
			isPresented: Binding(
				get: { presentConfirmatioDialog(isSheet: false, thisDialogType: .base) },
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
				ZStack(alignment: .top) {
					SheetView(closeSheet: {
						sheetIsPresented = false
					})
					.alert(isPresented: $alertIsPresented, content: alert)
					.confirmationDialog(
						"",
						isPresented: Binding(
							get: { presentConfirmatioDialog(isSheet: true,thisDialogType: .sheet) },
							set: { _ in Model.shared.alertVM.send(event: .didRequestDismiss) }
						),
						actions: confirmationDialogActions,
						message: confirmationDialogMessage
					)
					if appSettingsVM.state.settings.debugSettings.timeSlider == true {
						VStack {
							Spacer()
							ReferenceTimeSliderView(initialReferenceDate: chewViewModel.referenceDate)
								.padding(.bottom,30)
						}
					}
				}
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
	enum ConfirmationDialogType : String {
		case base
		case sheet
	}
}

extension ContentView {
	func presentConfirmatioDialog(isSheet : Bool, thisDialogType: ConfirmationDialogType) -> Bool {
		switch alertState.alert {
		case .none,.info,.action:
//			Logger.presentConfirmationDialog.debug("confirmationDialog: dismissing: \(thisDialogType.rawValue)")
			return false
		case let .destructive(_,_,_,_,orderedDialogType):
			var res : Bool {
				switch orderedDialogType {
				case .base:
					return orderedDialogType == thisDialogType
				case .sheet:
					return orderedDialogType == thisDialogType && sheetIsPresented
				}
			}
//			let res = sheetIsPresented ? isSheet : !isSheet
			if res == true {
				Logger.presentConfirmationDialog.debug("confirmationDialog: showing: \(thisDialogType.rawValue)")
			}
			return res
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
		case .destructive(let destructiveAction, _, let actionDescription, _,_):
			Button(actionDescription, role: .destructive, action: destructiveAction)
		}
	}
	
	@ViewBuilder func confirmationDialogMessage() -> some View {
		switch alertState.alert {
		case .none,.info,.action:
			EmptyView()
		case .destructive(_, let description, _, _,_):
			Text(verbatim: description)
		}
	}
	
	func alert() -> Alert {
		switch alertState.alert {
		case let .destructive(destructiveAction, description, actionDescripton,_,_):
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

#if DEBUG
struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
		.environmentObject(
			ChewViewModel(
				initialState: .init(data: .init(depStop: .textOnly(""), arrStop: .textOnly(""), journeySettings: .init(), date: .init(date: .now, mode: .departure)), status: .idle),
				coreDataStore: .preview
			)
		)
	}
}
#endif
