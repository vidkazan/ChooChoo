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
//                    return Self.generateUrl(encoded)
                }
        }
        return nil
    }
    
    static func generateUrl(_ journeyRefEncodedWithParantheses : String) -> URL? {
        let url : URL? = {
            var components = URLComponents()
            components.path = Constants.ApiData.Share.shareJourneyPath
            components.host = Constants.ApiData.Share.ghPageBase
            components.scheme = "https"
            components.queryItems = [
                URLQueryItem(
                    name: "ref",
                    value: journeyRefEncodedWithParantheses
                )
            ]
            return components.url
        }()
        return url
    }
}
