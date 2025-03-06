//
//  JourneyResponseImplIntBahnDe+JourneyResponse.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 03.03.25.
//

import Foundation

extension JourneyResponseIntBahnDe : JourneyResponse {
    func journeyDTO() -> JourneyListDTO {
        JourneyListDTO.init(
            earlierRef: self.verbindungReference.earlier,
            laterRef: self.verbindungReference.later,
            journeys: self.verbindungen.map {
                $0.journeyDTO()
            },
            realtimeDataUpdatedAt: nil
        )
    }
}

extension Verbindung {
    func journeyDTO() -> JourneyDTO {
        return JourneyDTO(
            type: nil,
            legs: self.verbindungsAbschnitte.map {
                $0.legDTO()
            },
            refreshToken: self.ctxRecon,
            remarks: self.auslastungstexte.map {
                $0.remark()
            },
            price: nil
        )
    }
}

extension Auslastungstext {
    func remark() -> Remark {
        Remark(
            type: self.anzeigeText,
            code: self.klasse,
            text: self.langText,
            summary: self.kurzText
        )
    }
}

extension Meldung {
    func remark() -> Remark {
        Remark(
            type: nil,
            code: nil,
            text: self.text,
            summary: self.ueberschrift
        )
    }
}

extension VerbindungsAbschnitt {
    #warning("harddcode nils")
    func legDTO() -> LegDTO {
        let timeContainer = JourneyResponseIntBahnDe.timeContainer(
            depPlanned: self.abfahrtsZeitpunkt,
            dep: self.ezAbfahrtsZeitpunkt,
            arrPlanned: self.ankunftsZeitpunkt,
            arr: self.ezAnkunftsZeitpunkt,
            isCancelled: nil
        )
        let line : LineDTO? = {
            if let v = self.verkehrsmittel {
                return v.lineDTO()
            }
            return nil
        }()
        let platforms = self.platforms()
        return LegDTO(
            origin: StopDTO(
                name: self.abfahrtsOrt,
                products: nil
            ),
            destination: StopDTO(
                name: self.ankunftsOrt,
                products: nil
            ),
            line: line,
            remarks: self.himMeldungen.map { $0.remark() } + self.priorisierteMeldungen.map { $0.remark() },
            departure: timeContainer?.iso.departure.actual,
            plannedDeparture: timeContainer?.iso.departure.planned,
            arrival: timeContainer?.iso.arrival.actual,
            plannedArrival: timeContainer?.iso.arrival.planned,
            departureDelay: timeContainer?.departureStatus.value,
            arrivalDelay: timeContainer?.arrivalStatus.value,
            tripId: self.journeyId,
            tripIdAlternative: nil,
            direction: self.ankunftsOrt,
            currentLocation: nil,
            arrivalPlatform: platforms.arrival.actual,
            plannedArrivalPlatform: platforms.arrival.planned,
            departurePlatform: platforms.departure.actual,
            plannedDeparturePlatform: platforms.departure.planned,
            walking: self.distanz != nil,
            distance: self.distanz,
            stopovers: self.halte.map { $0.stopWithTimeDTO() },
            polyline: nil
        )
    }
    
    func platforms() -> DepartureArrivalPair<Prognosed<String>> {
        let firstStop = self.halte.first
        let lastStop = self.halte.last
        return DepartureArrivalPair(
            departure: Prognosed(
                actual: firstStop?.actualPlatform(),
                planned: firstStop?.plannedPlatform()
            ),
            arrival: Prognosed(
                actual: lastStop?.actualPlatform(),
                planned: lastStop?.plannedPlatform()
            )
        )
    }
}

extension Halt {
    func stopWithTimeDTO() -> StopWithTimeDTO {
        #warning("harddcode nils")
        let timeContainer = JourneyResponseIntBahnDe.timeContainer(
            depPlanned: self.abfahrtsZeitpunkt,
            dep: self.ezAbfahrtsZeitpunkt,
            arrPlanned: self.ankunftsZeitpunkt,
            arr: self.ezAnkunftsZeitpunkt,
            isCancelled: nil
        )
        return StopWithTimeDTO(
            stop: StopDTO(
                type: nil,
                id: self.id,
                name: self.name,
                address: nil,
                location: nil,
                latitude: nil,
                longitude: nil,
                poi: nil,
                products: nil,
                distance: nil,
                station: nil
            ),
            departure: timeContainer?.iso.departure.actual,
            plannedDeparture: timeContainer?.iso.departure.planned,
            arrival: timeContainer?.iso.arrival.actual,
            plannedArrival: timeContainer?.iso.arrival.planned,
            departureDelay: timeContainer?.departureStatus.value,
            arrivalDelay: timeContainer?.arrivalStatus.value,
            reachable: nil,
            arrivalPlatform: self.actualPlatform(),
            plannedArrivalPlatform: self.plannedPlatform(),
            departurePlatform: self.actualPlatform(),
            plannedDeparturePlatform: self.plannedPlatform(),
            remarks: Self.remarks(meldungen: self.himMeldungen) + Self.remarks(meldungen: self.priorisierteMeldungen),
            cancelled: self.isCancelled()
        )
    }
    
    static func remarks(meldungen : [Meldung]?) -> [Remark] {
        if let meldungen = meldungen {
            return meldungen.map { $0.remark() }
        }
        return []
    }
    
    func isCancelled() -> Bool {
        if let meldungen = self.priorisierteMeldungen {
            if meldungen.first(where: {
                $0.type == "HALT_AUSFALL"
            }) != nil {
                return true
            }
        }
        if let meldungen = self.risNotizen {
            if meldungen.first(where: {
                $0.key == "text.realtime.stop.cancelled"
            }) != nil {
                return true
            }
        }
        return false
    }
    
    func plannedPlatform() -> String? {
        self.gleis
    }
    
    func actualPlatform() -> String? {
        self.ezGleis ?? self.gleis
    }
}

extension JourneyResponseIntBahnDe {
    static let formatDateAndTime = "yyyy-MM-dd'T'HH-mm-ss"
}

extension JourneyResponseIntBahnDe {
    static func timeContainer(
        depPlanned : String?,
        dep : String?,
        arrPlanned : String?,
        arr : String?,
        isCancelled : Bool?
    ) -> TimeContainer? {
        TimeContainer(
            plannedDeparture: JourneyResponseIntBahnDe.convertDateFormat(depPlanned),
            plannedArrival: JourneyResponseIntBahnDe.convertDateFormat(arrPlanned),
            actualDeparture: JourneyResponseIntBahnDe.convertDateFormat(dep ?? depPlanned),
            actualArrival: JourneyResponseIntBahnDe.convertDateFormat(arr ?? arrPlanned),
            cancelled: isCancelled
        )
    }
}

extension Verkehrsmittel {
    func lineDTO() -> LineDTO {
        LineDTO(
            type: self.produktGattung,
            id: self.nummer,
            fahrtNr: self.name,
            name: self.mittelText,
            linePublic: nil,
            adminCode: self.name,
            productName: self.langText,
            mode: nil,
            product: self.produktGattung
        )
    }
}

extension JourneyResponseIntBahnDe {
    static func convertDateFormat(_ input: String?) -> String? {
        guard let date = Self.date(input) else {
            return nil
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyyMMdd'T'HHmmssZ"

        return outputFormatter.string(from: date)
    }
    static func date(_ isoDateWithoutTimezone: String?) -> Date? {
        guard let isoDateWithoutTimezone = isoDateWithoutTimezone else {
            return nil
        }
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = Self.formatDateAndTime

        return inputFormatter.date(from: isoDateWithoutTimezone)
    }
}

//
//{
//    "halte": [
//        {
//            "id": "A=1@O=Koblenz Hbf@X=7588343@Y=50350928@U=80@L=8000206@i=U×008019023@",
//            "abfahrtsZeitpunkt": "2025-03-04T16:16:00",
//            "auslastungsmeldungen": [
//                {
//                    "klasse": "KLASSE_1",
//                    "stufe": 0
//                },
//                {
//                    "klasse": "KLASSE_2",
//                    "stufe": 0
//                }
//            ],
//            "gleis": "2",
//            "haltTyp": "PL",
//            "name": "Koblenz Hbf",
//            "risNotizen": [
//                {
//                    "key": "text.realtime.stop.cancelled",
//                    "value": "Stop cancelled"
//                }
//            ],
//            "bahnhofsInfoId": "3299",
//            "extId": "8000206",
//            "routeIdx": 0,
//            "priorisierteMeldungen": [
//                {
//                    "prioritaet": "HOCH",
//                    "text": "Stop cancelled",
//                    "type": "HALT_AUSFALL"
//                }
//            ],
//            "adminID": "NXRE",
//            "kategorie": "RE",
//            "nummer": "28526"
//        },
//        {
//            "id": "A=1@O=Koblenz Stadtmitte@X=7590024@Y=50357957@U=80@L=8003341@i=U×008091873@",
//            "abfahrtsZeitpunkt": "2025-03-04T16:18:00",
//            "ankunftsZeitpunkt": "2025-03-04T16:18:00",
//            "auslastungsmeldungen": [
//                {
//                    "klasse": "KLASSE_1",
//                    "stufe": 0
//                },
//                {
//                    "klasse": "KLASSE_2",
//                    "stufe": 0
//                }
//            ],
//            "gleis": "1",
//            "haltTyp": "PL",
//            "name": "Koblenz Stadtmitte",
//            "risNotizen": [
//                {
//                    "key": "text.realtime.stop.cancelled",
//                    "value": "Stop cancelled"
//                }
//            ],
//            "bahnhofsInfoId": "8258",
//            "extId": "8003341",
//            "routeIdx": 1,
//            "priorisierteMeldungen": [
//                {
//                    "prioritaet": "HOCH",
//                    "text": "Stop cancelled",
//                    "type": "HALT_AUSFALL"
//                }
//            ],
//            "adminID": "NXRE",
//            "kategorie": "RE",
//            "nummer": "28526"
//        }
//    ],
//    "himMeldungen": [
//        {
//            "ueberschrift": "Construction work. (Quelle: zuginfo.nrw)",
//            "text": "Ausfälle zw. Oberhausen Hbf und Wesel sowie zw. Friedrichsfeld (Niederrhein) und Wesel in diversen Zeiträumen vom 01.11. - 18.05.2026. Ein Ersatzverkehr (SEV) ist eingerichtet. Weitere Informationen finden Sie auf www.zuginfo.nrw - https://zuginfo.nrw?msg=108199.",
//            "prioritaet": "NIEDRIG",
//            "modDateTime": "2025-02-28T13:15:15"
//        },
//        {
//            "ueberschrift": "Disruption. (Quelle: zuginfo.nrw)",
//            "text": "Die Strecke ist zwischen Köln Hbf und Köln Süd beeinträchtigt. Das Ende können wir leider noch nicht abschätzen. Der Grund dafür ist eine Reparatur an der Strecke. In der Folge kommt es zu Verspätungen und Teilausfällen. Bitte prüfen Sie Ihre Reiseverbindung kurz vor der Abfahrt des Zuges.",
//            "prioritaet": "HOCH",
//            "modDateTime": "2025-03-04T16:34:25"
//        },
//        {
//            "ueberschrift": "Disruption. (Quelle: zuginfo.nrw)",
//            "text": "Die Reparatur an einem Zug in Dinslaken ist beendet. Die Züge verkehren auf dem Streckenabschnitt wieder ohne Einschränkungen. In der Folge kann es noch vereinzelt zu Verspätungen und ggf. zu Teilausfällen kommen. Bitte prüfen Sie den Zuglauf in der Onlinereiseauskunft.",
//            "prioritaet": "HOCH",
//            "modDateTime": "2025-03-04T18:00:40"
//        }
//    ],
//    "risNotizen": [
//        {
//            "key": "FT",
//            "value": "Signal repairs",
//            "routeIdxFrom": 2,
//            "routeIdxTo": 3
//        }
//    ],
//    "zugattribute": [
//        {
//            "kategorie": "BARRIEREFREI",
//            "key": "RG",
//            "value": "Behindertengerechtes Fahrzeug"
//        },
//        {
//            "kategorie": "BARRIEREFREI",
//            "key": "RO",
//            "value": "space for wheelchairs"
//        },
//        {
//            "kategorie": "FAHRRADMITNAHME",
//            "key": "FB",
//            "value": "Number of bicycles conveyed limited"
//        },
//        {
//            "kategorie": "INFORMATION",
//            "key": "N ",
//            "value": "\"RRX Rhein-Ruhr-Express\""
//        },
//        {
//            "kategorie": "INFORMATION",
//            "key": "LS",
//            "value": "power sockets for laptop"
//        },
//        {
//            "kategorie": "INFORMATION",
//            "key": "KL",
//            "value": "air conditioning"
//        },
//        {
//            "kategorie": "INFORMATION",
//            "key": "WV",
//            "value": "Wifi available"
//        }
//    ],
//    "priorisierteMeldungen": [
//        {
//            "prioritaet": "HOCH",
//            "text": "Signal repairs"
//        },
//        {
//            "prioritaet": "NIEDRIG",
//            "text": "Ausfälle zw. Oberhausen Hbf und Wesel sowie zw. Friedrichsfeld (Niederrhein) und Wesel in diversen Zeiträumen vom 01.11. - 18.05.2026. Ein Ersatzverkehr (SEV) ist eingerichtet. Weitere Informationen finden Sie auf www.zuginfo.nrw - https://zuginfo.nrw?msg=108199."
//        },
//        {
//            "prioritaet": "HOCH",
//            "text": "Die Strecke ist zwischen Köln Hbf und Köln Süd beeinträchtigt. Das Ende können wir leider noch nicht abschätzen. Der Grund dafür ist eine Reparatur an der Strecke. In der Folge kommt es zu Verspätungen und Teilausfällen. Bitte prüfen Sie Ihre Reiseverbindung kurz vor der Abfahrt des Zuges."
//        },
//        {
//            "prioritaet": "HOCH",
//            "text": "Die Reparatur an einem Zug in Dinslaken ist beendet. Die Züge verkehren auf dem Streckenabschnitt wieder ohne Einschränkungen. In der Folge kann es noch vereinzelt zu Verspätungen und ggf. zu Teilausfällen kommen. Bitte prüfen Sie den Zuglauf in der Onlinereiseauskunft."
//        }
//    ],
//    "abfahrtsZeitpunkt": "2025-03-04T16:16:00",
//    "ankunftsZeitpunkt": "2025-03-04T18:46:00",
//    "ezAnkunftsZeitpunkt": "2025-03-04T18:47:00",
//    "cancelled": false
//}
