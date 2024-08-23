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
            guard var ref = components.queryItems?.first(where: { $0.name == "ref" })?.value else {
                Model.shared.topBarAlertVM.send(event: .didRequestShow(.generic(msg: "Journey not found")))
                return
            }
            ref.removeLast()
            ref.removeFirst()
            guard let data = Data(base64Encoded: ref),let string = String(data: data, encoding: .utf8) else {
                Model.shared.topBarAlertVM.send(event: .didRequestShow(.generic(msg: "Journey ref error")))
                return
            }
            Model.shared.sheetVM.send(event: .didRequestShow(.shareJourneyDetails(journeyRef: string)))
        }
}
