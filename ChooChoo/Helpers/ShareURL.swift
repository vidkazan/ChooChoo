//
//  ShareURL.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 23.08.24.
//

import Foundation

struct ShareJourneyData {
    let viewData : JourneyViewData
}

enum ChooShare : Hashable {
    case journey(journey : String?)
    
    func urlString() -> String? {
        switch self {
            case .journey(let journey):
                if let journey = journey {
                    return "https://\(Constants.ApiDataIntBahnDe.Share.ghPageBase)\(Constants.ApiDataIntBahnDe.Share.shareJourneyPath)?ref=\(journey)"
                }
        }
        return nil
    }
}
