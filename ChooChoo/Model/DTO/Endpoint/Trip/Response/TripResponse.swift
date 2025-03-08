//
//  TripResponse.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 08.03.25.
//

import Foundation

struct TripResponseIntlBahnDe: ChewDTO {
    let zugName: String?
    let halte: [Halt]?
    let zugattribute: [Zugattribute]?
    let himMeldungen: [Meldung]? // Assuming this is an array of strings; adjust if necessary
    let risNotizen: [RizNotiezen]? // Assuming this is an array of strings; adjust if necessary
    let priorisierteMeldungen: [Meldung]? // Assuming this is an array of strings; adjust if necessary
    let abfahrtsZeitpunkt: String?
    let ankunftsZeitpunkt: String?
    let auslastungsmeldungen: [Auslastungstext]?
    let ezAbfahrtsZeitpunkt: String?
    let ezAnkunftsZeitpunkt: String?
    let cancelled: Bool?
}

extension TripResponseIntlBahnDe {
    func tripDTO() -> TripDTO {
        let timeContainer = JourneyResponseIntBahnDe.timeContainer(
            depPlanned: self.abfahrtsZeitpunkt,
            dep: self.ezAbfahrtsZeitpunkt,
            arrPlanned: self.ankunftsZeitpunkt,
            arr: self.ezAnkunftsZeitpunkt,
            isCancelled: self.cancelled
        )
        #warning("tripId hardcode nil!")
        return TripDTO(
            trip: LegDTO(
                origin: nil,
                destination: nil,
                line: LineDTO(
                    type: nil,
                    id: nil,
                    fahrtNr: nil,
                    name: self.zugName,
                    linePublic: nil,
                    adminCode: nil,
                    productName: nil,
                    mode: nil,
                    product: nil
                ),
                remarks: nil,
                departure: timeContainer?.iso.departure.actual,
                plannedDeparture: timeContainer?.iso.departure.planned,
                arrival: timeContainer?.iso.arrival.actual,
                plannedArrival: timeContainer?.iso.arrival.planned,
                departureDelay: timeContainer?.departureStatus.value,
                arrivalDelay: timeContainer?.arrivalStatus.value,
                tripId: "",
                tripIdAlternative: nil,
                direction: nil,
                currentLocation: nil,
                arrivalPlatform: nil,
                plannedArrivalPlatform: nil,
                departurePlatform: nil,
                plannedDeparturePlatform: nil,
                walking: nil,
                distance: nil,
                stopovers: self.halte?.map{ $0.stopWithTimeDTO() },
                polyline: nil
            )
        )
    }
}
