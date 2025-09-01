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

     func createNearestStopView() -> some View {
        NearestStopView(
            viewModel: .init(container: self.container)
        )
    }
//    func createSMSView() -> some View {
//        SmsView(viewModel: SMSViewModel(router: self.router, container: self.container))
//    }
}
