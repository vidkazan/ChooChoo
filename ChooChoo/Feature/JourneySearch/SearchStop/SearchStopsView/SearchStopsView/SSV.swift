//
//  SearchStopsView.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 04.09.23.
//

import SwiftUI
import CoreLocation

struct SearchStopsView: View {
	@EnvironmentObject  var chewViewModel : ChewViewModel
	@ObservedObject var searchStopViewModel : SearchStopsViewModel
	@FocusState 	var focusedField : LocationDirectionType?
	
	@State var previuosStatus : ChewViewModel.Status?
	@State var status : ChewViewModel.Status = .idle
	@State var topText : String
	@State var bottomText : String
	@State var recentStopsData = [StopWithDistance]()
	@State var stops = [StopWithDistance]()
	@State var fieldRedBorder : (top: Bool,bottom: Bool) = (false,false)
	
	
	var body: some View {
		VStack(spacing: 5) {
			field(type: .departure, text: $topText)
			field(type: .arrival, text: $bottomText)
				.disabled(chewViewModel.state.data.depStop.leg != nil)
		}
		.onReceive(chewViewModel.$state, perform: onStateChange)
	}
}

extension SearchStopsView {
	init(
		searchStopViewModel: SearchStopsViewModel = Model.shared.searchStopsVM,
		focusedField: LocationDirectionType? = nil,
		previuosStatus: ChewViewModel.Status? = nil,
		topText: String = "",
		bottomText: String = "",
		recentStopsData: [StopWithDistance] = [],
		stops: [StopWithDistance] = []
	) {
		self.topText = topText
		self.bottomText = bottomText
		self.searchStopViewModel = searchStopViewModel
		self.focusedField = focusedField
		self.previuosStatus = previuosStatus
		self.recentStopsData = recentStopsData
		self.stops = stops
	}
}

extension SearchStopsView {
	func field(type : LocationDirectionType, text : Binding<String>) -> some View {
		 VStack(spacing: 0) {
			HStack {
				textField(
					type: type,
					text: text
				)
				rightButton(type: type)
			}
			.background(Color.chewFillAccent)
			.cornerRadius(10)
			.overlay(
				redStroke(type: type)
			)
			if focusedField == type {
				stopList(type: type)
			}
		}
		 .background(Color.chewStopListBG.opacity(0.8))
		.clipShape(.rect(cornerRadius: 10))
	}
	
	func redStroke(type : LocationDirectionType) -> some View {
		switch type {
		case .departure:
			RoundedRectangle(cornerRadius: 10)
				.stroke(fieldRedBorder.top == true ? .red : .clear, lineWidth: 1.5)
		case .arrival:
			RoundedRectangle(cornerRadius: 10)
				.stroke(fieldRedBorder.bottom == true ? .red : .clear, lineWidth: 1.5)
		}
	}
}

extension SearchStopsView {
	func onStateChange(state : ChewViewModel.State) {
		self.status = state.status
		topText = state.data.depStop.text
		bottomText = state.data.arrStop.text
		
		fieldRedBorder.bottom = state.data.arrStop.stop == nil && !state.data.arrStop.text.isEmpty && state.status != .editingStop(.arrival)
		fieldRedBorder.top = state.data.depStop.stop == nil && !state.data.depStop.text.isEmpty && state.status != .editingStop(.departure)
		switch state.status {
		case .editingStop(let type):
			focusedField = type
			switch type {
			case .arrival:
				bottomText = ""
			case .departure:
				topText = ""
			}
		default:
			focusedField = nil
		}
		previuosStatus = state.status
	}
}

#if DEBUG
struct SSV_Previews: PreviewProvider {
	static var previews: some View {
		let chewVM = ChewViewModel(
			coreDataStore: .preview
		)
		
		if let stopsK = Mock.stops.stopByK.decodedData,
		   let stopsL = Mock.stops.stopByD.decodedData {
			VStack {
				SearchStopsView(
//					searchStopViewModel: SearchStopsViewModel(.init(
//						previousStops: (stopsK + stopsL).compactMap({$0.stop()}),
//						stops: [],
//						status: .loading("pop")
//					)),
					searchStopViewModel: Model.shared.searchStopsVM,
					topText: "",
					bottomText: ""
				)
				.onAppear(perform: {
					chewVM.send(event: .didStartViewAppear)
				})
				.environmentObject(chewVM)
				.padding(10)
				.padding(.top,20)
				Spacer()
			}
			.background(Color(.green))
			.frame(maxWidth: .infinity, maxHeight: .infinity)
//			.environment(\.locale, .init(identifier: "de"))
		}
	}
}
#endif
