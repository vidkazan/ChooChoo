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
        let controller : UIActivityViewController  = {
            return UIActivityViewController(
                activityItems: [
                    ChooShare.journey(journey: journey).urlString()
                ],
                applicationActivities: nil
            )
        }()
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ShareJourneyView>) {}
}

extension ShareJourneyView {
    static func percentEncoding(_ string : String?) -> String? {
        guard let string = string else {
            return nil
        }
        let allowedCharacterSet = CharacterSet(charactersIn: " :=#/?abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")

        if let encodedString = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) {
            print(encodedString)  // "https://example.com/some%20path%20with%20spaces"
            return encodedString
        }
        return nil
    }
}
