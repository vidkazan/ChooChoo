//
//  UIApplication+share.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 23.08.24.
//

import Foundation
import SwiftUI

struct ShareJourneyView: UIViewControllerRepresentable {
    let journey : JourneyViewData
    
    func makeUIViewController(
        context: UIViewControllerRepresentableContext<ShareJourneyView>
    ) -> UIActivityViewController {
        let shareDTO = ShareJourneyDTO(
            journeyRef: journey.refreshToken,
            origin: journey.origin,
            destination: journey.destination,
            departureTimeTS: journey.time.timestamp.departure.actualOrPlannedIfActualIsNil(),
            arrivalTimeTS:journey.time.timestamp.arrival.actualOrPlannedIfActualIsNil()
        )
        let encodedDTO = try? JSONEncoder().encode(shareDTO)
        
        let string = encodedDTO?.base64EncodedString()
        
        let controller : UIActivityViewController  = {
            return UIActivityViewController(
                activityItems: [
                    ChooShare.journey(journey: string).urlString()
                ],
                applicationActivities: nil
            )
        }()
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ShareJourneyView>) {}
}


struct ShareJourneyDTO : Codable, Hashable {
    let journeyRef : String
    let origin : String
    let destination : String
    let departureTimeTS : Double?
    let arrivalTimeTS : Double?
}
