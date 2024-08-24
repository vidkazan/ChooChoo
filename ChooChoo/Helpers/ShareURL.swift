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
    case journey(journey : JourneyViewData)
    
    func urlString() -> String? {
        switch self {
            case .journey(let journey):
                if let encoded = journey.refreshToken.base64Encoded(){
                    return "https://\(Constants.ApiData.Share.ghPageBase)\(Constants.ApiData.Share.shareJourneyPath)?ref=\(encoded)"
                }
        }
        return nil
    }
}
