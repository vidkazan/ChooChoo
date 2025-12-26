//
//  NavigationViewBuilder.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 29.08.25.
//

import Foundation
import SwiftUI

final class NavigationViewBuilder {
    let container: AppContainer
    let router: Router<AppRoute>

    init(
        container: AppContainer,
        router: Router<AppRoute>
    ) {
        self.container = container
        self.router = router
    }
    
    func createJourneyListView(
        date: SearchStopsDate,
        settings : JourneySettings,
        stops : DepartureArrivalPairStop,
    ) -> some View {
        let vm = JourneyListViewModel(
            date: date,
            settings: settings,
            stops: stops
        )
        return JourneyListView(jlvm: vm)
    }
    
    func createJourneyDetailsView(
        followId: Int64,
        data: JourneyViewData,
        depStop : Stop,
        arrStop : Stop,
        chewVM: ChewViewModel?
    ) -> some View {
        let vm = JourneyDetailsViewModel(
            followId: followId,
            data: data,
            depStop: depStop,
            arrStop: arrStop,
            chewVM: chewVM
        )
        return JourneyDetailsView(journeyDetailsViewModel: vm)
    }
    
    func createFeatureView() -> some View {
       FeatureView(viewBuilder: self)
    }
    
    func createSearchPage() -> some View {
       JourneySearchView(viewBuilder: self)
    }
    
    func createFollowPage() -> some View {
       JourneyFollowView()
    }
    
    func createNearestStopView() -> some View {
        NearestStopView(
            viewModel: .init(container: self.container),
            viewModelNew: .init(container: self.container,router: self.router),
        )
    }
}
