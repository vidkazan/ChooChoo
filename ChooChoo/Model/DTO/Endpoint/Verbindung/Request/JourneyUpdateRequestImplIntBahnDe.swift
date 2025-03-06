//
//  JourneyRequestImplIntBahnDe.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 02.03.25.
//

import Foundation


struct JourneyUpdateRequestIntBahnDe : ChewDTO {
    var klasse: String
    var reisende: [JourneyRequestIntBahnDe.Reisende]
    var ctxRecon: String
    var reservierungsKontingenteVorhanden: Bool
    var nurDeutschlandTicketVerbindungen: Bool
    var deutschlandTicketVorhanden: Bool
}

extension JourneyUpdateRequestIntBahnDe {
    init() {
        self.klasse = ""
        self.ctxRecon = ""
        self.reisende = [JourneyRequestIntBahnDe.Reisende.defaultValue]
        self.reservierungsKontingenteVorhanden = false
        self.nurDeutschlandTicketVerbindungen = false
        self.deutschlandTicketVorhanden = false
    }
}

extension JourneyUpdateRequestIntBahnDe : JourneyUpdateRequest {
    init(
        settings : JourneySettings,
        journeyRef : String
    ) {
        self.init()
        self.klasse = "KLASSE_2"
        self.ctxRecon = journeyRef
        self.nurDeutschlandTicketVerbindungen = settings.transportMode == .regional
    }
}
