//
//  AppRoute.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 29.08.25.
//

import Foundation
import SwiftUI

enum AppRoute {
    case main
    case journeyDetails(
        Int64,
        JourneyViewData,
        Stop,
        Stop,
        ChewViewModel?
    )
    
//    case profile(profile: ProfileProtocol, viewMode: ProfileView.ProfileViewMode)
//    case editProfile(profile: ProfileProtocol)
//    case accountManagement(currentUser: MenuTempUserModel)
//    case faq(faqData: [String: String])
//    case messenger(chatModel: ChatModel,
//                   currentUser: TempUserModel,
//                   interlocutor: TempUserModel)
}

extension AppRoute: Hashable {
    // swiftlint:disable cyclomatic_complexity
    static func == (lhs: AppRoute, rhs: AppRoute) -> Bool {
        switch (lhs, rhs) {
            case (.main, .main): return true
            case (.journeyDetails, .journeyDetails): return true
            default: return false
        }
    }
    // swiftlint:enable cyclomatic_complexity

    func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }
}
