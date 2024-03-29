//
//  ContentView.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 23.08.23.
//

import SwiftUI

enum Tabs : Int,CaseIterable {
	case search
	case follow
//	case appSettings
}

struct FeatureView: View {
	@EnvironmentObject var chewViewModel : ChewViewModel
	@State var selectedTab = Tabs.search
		
	
	let tabSearchLabel : some View = {
		Label(
			title: {
				Text("Search",comment : "TabItem")
			},
			icon: {
				Image(systemName: "magnifyingglass")
			}
		)
	}()
	let tabFollowLabel : some View = {
		Label(
			title: {
				Text("Follow", comment : "TabItem")
			},
			icon: {
				ChooSFSymbols.bookmark.view
			}
		)
	}()
//	let tabAppSettingsLabel : some View = {
//		Label(
//			title: {
//				Text("Settings", comment : "TabItem")
//			},
//			icon: {
//				ChooSFSymbols.gearshape.view
//			}
//		)
//	}()
	var handler: Binding<Tabs> { Binding(
		get: { self.selectedTab },
		set: {
			if $0 == self.selectedTab {
				switch selectedTab {
				case .search:
					chewViewModel.send(event: .didTapCloseJourneyList)
				case .follow:
					break
				}
			}
			self.selectedTab = $0
		}
	)}
	var body: some View {
		TabView(selection: handler) {
			if #available(iOS 16.0, *) {
				NavigationStack {
					JourneySearchView()
				}
					.tabItem { tabSearchLabel }
					.tag(Tabs.search)
				NavigationStack {
					JourneyFollowView()
				}
					.tabItem { tabFollowLabel }
					.tag(Tabs.follow)
//				NavigationStack {
//					AppSettingsView()
//				}
//					.tabItem { tabAppSettingsLabel }
//					.tag(Tabs.appSettings)
			} else {
				NavigationView {
					JourneySearchView()
				}
					.tabItem { tabSearchLabel }
					.tag(Tabs.search)
				NavigationView {
					JourneyFollowView()
				}
					.tabItem { tabFollowLabel }
					.tag(Tabs.follow)
//				NavigationView {
//					AppSettingsView()
//				}
//					.tabItem { tabAppSettingsLabel }
//					.tag(Tabs.appSettings)
			}
		}
		.onReceive(chewViewModel.$state, perform: { state in
			switch state.status {
			case .checkingSearchData, .journeys:
				selectedTab = .search
			default:
				return
			}
		})
	}
}

