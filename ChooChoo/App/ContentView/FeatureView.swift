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
    
    @ViewBuilder
    func tabView() -> some View {
        switch self {
            case .search:
                Label(
                    title: {
                        Text("Search",comment : "TabItem")
                    },
                    icon: {
                        Image(systemName: "magnifyingglass")
                    }
                )
            case .follow:
                Label(
                    title: {
                        Text("Follow", comment : "TabItem")
                    },
                    icon: {
                        ChooSFSymbols.bookmark.view
                    }
                )
        }
    }
}

struct FeatureView: View {
    let viewBuilder: NavigationViewBuilder
    
	@EnvironmentObject var chewViewModel : ChewViewModel
	@State var selectedTab = Tabs.search

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
            ForEach(Tabs.allCases, id: \.self) { tab in
                createTabView(tab: tab)
                    .tabItem { tab.tabView() }
                    .tag(tab.rawValue)
            }
		}
        .onOpenURL(perform: {
            self.handleIncomingURL($0)
        })
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

extension FeatureView {
    
    @ViewBuilder
    func createTabView(tab: Tabs) -> some View {
        switch tab {
            case .search: viewBuilder.createSearchPage()
            case .follow: viewBuilder.createFollowPage()
        }
    }
    private func handleIncomingURL(_ url: URL) {
            guard url.scheme == "choochoo" else {
                return
            }
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                Model.shared.topBarAlertVM.send(event: .didRequestShow(.generic(msg: "Unknown URL")))
                return
            }
            guard let action = components.host, action == "journey" else {
                Model.shared.topBarAlertVM.send(event: .didRequestShow(.generic(msg: "Unknown URL, we can't handle this one!")))
                return
            }
            guard let ref = components.queryItems?.first(where: { $0.name == "ref" })?.value else {
                Model.shared.topBarAlertVM.send(event: .didRequestShow(.generic(msg: "Journey not found")))
                return
            }
            guard let data = Data(base64Encoded: ref) else {
                Model.shared.topBarAlertVM.send(event: .didRequestShow(.generic(msg: "Base64 decoding error")))
                return
            }
            guard let decoded = try? JSONDecoder().decode(ShareJourneyDTO.self, from: data) else {
                Model.shared.topBarAlertVM.send(event: .didRequestShow(.generic(msg: "Journey Decoding Error")))
                return
            }
            print(decoded.journeyRef)
            #warning("hardcoded JourneySettings()")
            Model.shared.sheetVM.send(event: .didRequestShow(.shareJourneyDetails(journeyRef: decoded.journeyRef, setting: JourneySettings())))
        }
}
